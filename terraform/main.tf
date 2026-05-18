# A2AC Enterprise Cloud Deploy — Terraform Root Module
# One-click Marketplace deployment into customer's GCP project
# Architecture: 4 Cloud Run services + Firestore + BigQuery + Pub/Sub + IAM

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ─── Variables ─────────────────────────────────────────────

variable "project_id" {
  description = "Customer's GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region for deployment."
  type        = string
  default     = "us-central1"
}

variable "deployment_name" {
  description = "Resource prefix (e.g. 'a2ac')."
  type        = string
  default     = "a2ac"
}

variable "container_registry" {
  description = "Container registry base path."
  type        = string
  default     = "ghcr.io/phil-hills"
}

variable "image_tag" {
  description = "Container image tag."
  type        = string
  default     = "latest"
}

variable "enable_vertex_ai" {
  description = "Enable optional Vertex AI integration."
  type        = bool
  default     = false
}

# ─── Provider ──────────────────────────────────────────────

provider "google" {
  project = var.project_id
  region  = var.region
}

# ─── IAM: Service Account ─────────────────────────────────

resource "google_service_account" "a2ac_runtime" {
  account_id   = "${var.deployment_name}-runtime"
  display_name = "A2AC Runtime Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "bigquery_writer" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.a2ac_runtime.email}"
}

resource "google_project_iam_member" "firestore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.a2ac_runtime.email}"
}

resource "google_project_iam_member" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.a2ac_runtime.email}"
}

resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.a2ac_runtime.email}"
}

# ─── Cloud Run: Cube Hub ───────────────────────────────────

resource "google_cloud_run_v2_service" "cube_hub" {
  name     = "${var.deployment_name}-cube-hub"
  location = var.region

  template {
    service_account = google_service_account.a2ac_runtime.email
    containers {
      image = "${var.container_registry}/a2ac-gateway:${var.image_tag}"
      ports {
        container_port = 8080
      }
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "DEPLOYMENT_NAME"
        value = var.deployment_name
      }
      env {
        name  = "SERVICE_ROLE"
        value = "cube-hub"
      }
      resources {
        limits = { cpu = "1", memory = "512Mi" }
      }
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 4
    }
  }
}

# ─── Cloud Run: Q Gateway ─────────────────────────────────

resource "google_cloud_run_v2_service" "q_gateway" {
  name     = "${var.deployment_name}-q-gateway"
  location = var.region

  template {
    service_account = google_service_account.a2ac_runtime.email
    containers {
      image = "${var.container_registry}/a2ac-gateway:${var.image_tag}"
      ports {
        container_port = 8080
      }
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "DEPLOYMENT_NAME"
        value = var.deployment_name
      }
      env {
        name  = "SERVICE_ROLE"
        value = "q-gateway"
      }
      resources {
        limits = { cpu = "1", memory = "512Mi" }
      }
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 4
    }
  }
}

# ─── Cloud Run: Agent Registry / Executor ──────────────────

resource "google_cloud_run_v2_service" "agent_registry" {
  name     = "${var.deployment_name}-agent-registry"
  location = var.region

  template {
    service_account = google_service_account.a2ac_runtime.email
    containers {
      image = "${var.container_registry}/a2ac-executor:${var.image_tag}"
      ports {
        container_port = 8080
      }
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "DEPLOYMENT_NAME"
        value = var.deployment_name
      }
      env {
        name  = "SERVICE_ROLE"
        value = "agent-registry"
      }
      resources {
        limits = { cpu = "2", memory = "1Gi" }
      }
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 8
    }
  }
}

# ─── Cloud Run: Receipt API ────────────────────────────────

resource "google_cloud_run_v2_service" "receipt_api" {
  name     = "${var.deployment_name}-receipt-api"
  location = var.region

  template {
    service_account = google_service_account.a2ac_runtime.email
    containers {
      image = "${var.container_registry}/a2ac-receipt-api:${var.image_tag}"
      ports {
        container_port = 8080
      }
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "DEPLOYMENT_NAME"
        value = var.deployment_name
      }
      env {
        name  = "SERVICE_ROLE"
        value = "receipt-api"
      }
      env {
        name  = "BQ_DATASET"
        value = google_bigquery_dataset.receipts.dataset_id
      }
      resources {
        limits = { cpu = "1", memory = "512Mi" }
      }
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 4
    }
  }
}

# ─── Firestore: Cube State + Workflow Metadata ─────────────

resource "google_firestore_database" "cube_state" {
  project     = var.project_id
  name        = "${var.deployment_name}-state"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
}

# ─── BigQuery: Receipt Ledger (Immutable) ──────────────────

resource "google_bigquery_dataset" "receipts" {
  dataset_id = replace("${var.deployment_name}_receipts", "-", "_")
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_table" "receipt_events" {
  dataset_id = google_bigquery_dataset.receipts.dataset_id
  table_id   = "receipt_events"
  project    = var.project_id

  schema = jsonencode([
    { name = "receipt_id", type = "STRING", mode = "REQUIRED" },
    { name = "event_type", type = "STRING", mode = "REQUIRED" },
    { name = "status", type = "STRING", mode = "REQUIRED" },
    { name = "q_command", type = "STRING", mode = "NULLABLE" },
    { name = "canonical_command", type = "STRING", mode = "NULLABLE" },
    { name = "cube_id", type = "STRING", mode = "NULLABLE" },
    { name = "result_cube_id", type = "STRING", mode = "NULLABLE" },
    { name = "agent_id", type = "STRING", mode = "NULLABLE" },
    { name = "blake3_hash", type = "STRING", mode = "NULLABLE" },
    { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "runtime_policy", type = "STRING", mode = "NULLABLE" },
    { name = "metadata", type = "JSON", mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "workflow_runs" {
  dataset_id = google_bigquery_dataset.receipts.dataset_id
  table_id   = "workflow_runs"
  project    = var.project_id

  schema = jsonencode([
    { name = "workflow_id", type = "STRING", mode = "REQUIRED" },
    { name = "status", type = "STRING", mode = "REQUIRED" },
    { name = "input_cube_id", type = "STRING", mode = "NULLABLE" },
    { name = "result_cube_id", type = "STRING", mode = "NULLABLE" },
    { name = "agent_id", type = "STRING", mode = "NULLABLE" },
    { name = "started_at", type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "completed_at", type = "TIMESTAMP", mode = "NULLABLE" },
    { name = "runtime_policy", type = "STRING", mode = "NULLABLE" },
    { name = "metadata", type = "JSON", mode = "NULLABLE" },
  ])
}

# ─── Pub/Sub: Workflow Events ──────────────────────────────

resource "google_pubsub_topic" "workflow_events" {
  name    = "${var.deployment_name}-workflow-events"
  project = var.project_id
}

resource "google_pubsub_topic" "marketplace_entitlements" {
  name    = "${var.deployment_name}-entitlements"
  project = var.project_id
}

# ─── Outputs ───────────────────────────────────────────────

output "cube_hub_url" {
  value       = google_cloud_run_v2_service.cube_hub.uri
  description = "A2AC Cube Hub URL"
}

output "q_gateway_url" {
  value       = google_cloud_run_v2_service.q_gateway.uri
  description = "Q Protocol Gateway URL"
}

output "agent_registry_url" {
  value       = google_cloud_run_v2_service.agent_registry.uri
  description = "Agent Registry / Executor URL"
}

output "receipt_api_url" {
  value       = google_cloud_run_v2_service.receipt_api.uri
  description = "Receipt API URL"
}

output "agent_card_url" {
  value       = "${google_cloud_run_v2_service.q_gateway.uri}/.well-known/agent.json"
  description = "A2A Protocol Agent Card"
}

output "receipt_dataset" {
  value       = google_bigquery_dataset.receipts.dataset_id
  description = "BigQuery receipt ledger dataset"
}

output "service_account_email" {
  value       = google_service_account.a2ac_runtime.email
  description = "Runtime service account"
}
