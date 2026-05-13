# A2AC Sandbox - GCP Terraform Deployment
# Deploys a non-production sandbox for validating the A2AC control-plane shape.
# Pre-Marketplace sandbox deployment.

variable "project_id" {
  description = "GCP project ID for the A2AC sandbox."
  type        = string
}

variable "region" {
  description = "GCP region for the sandbox."
  type        = string
  default     = "us-central1"
}

variable "deployment_name" {
  description = "Resource prefix for sandbox resources."
  type        = string
  default     = "a2ac-sandbox"
}

variable "container_image" {
  description = "Public sandbox container image."
  type        = string
  default     = "ghcr.io/phil-hills/a2ac-sandbox:latest"
}

variable "allow_public_invoker" {
  description = "Allow unauthenticated access for sandbox testing."
  type        = bool
  default     = true
}

variable "enable_bigquery_receipts" {
  description = "Enable BigQuery receipt tables."
  type        = bool
  default     = true
}

variable "enable_pubsub_events" {
  description = "Enable Pub/Sub event topic."
  type        = bool
  default     = true
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# --- Cloud Run Sandbox Service ---

resource "google_cloud_run_v2_service" "a2ac_sandbox" {
  name     = "${var.deployment_name}"
  location = var.region

  template {
    containers {
      image = var.container_image
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
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  count    = var.allow_public_invoker ? 1 : 0
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.a2ac_sandbox.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# --- Firestore for Cube State ---

resource "google_firestore_database" "a2ac_sandbox_state" {
  project     = var.project_id
  name        = "${var.deployment_name}-state"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
}

# --- BigQuery for Receipts ---

resource "google_bigquery_dataset" "a2ac_sandbox_receipts" {
  count      = var.enable_bigquery_receipts ? 1 : 0
  dataset_id = replace("${var.deployment_name}_receipts", "-", "_")
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_table" "receipt_events" {
  count      = var.enable_bigquery_receipts ? 1 : 0
  dataset_id = google_bigquery_dataset.a2ac_sandbox_receipts[0].dataset_id
  table_id   = "receipt_events"
  project    = var.project_id

  schema = jsonencode([
    { name = "receipt_id",       type = "STRING",    mode = "REQUIRED" },
    { name = "event_type",       type = "STRING",    mode = "REQUIRED" },
    { name = "status",           type = "STRING",    mode = "REQUIRED" },
    { name = "q_command",        type = "STRING",    mode = "NULLABLE" },
    { name = "canonical_command",type = "STRING",    mode = "NULLABLE" },
    { name = "cube_id",          type = "STRING",    mode = "NULLABLE" },
    { name = "result_cube_id",   type = "STRING",    mode = "NULLABLE" },
    { name = "agent_id",         type = "STRING",    mode = "NULLABLE" },
    { name = "created_at",       type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "runtime_policy",   type = "STRING",    mode = "NULLABLE" },
    { name = "metadata",         type = "JSON",      mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "workflow_runs" {
  count      = var.enable_bigquery_receipts ? 1 : 0
  dataset_id = google_bigquery_dataset.a2ac_sandbox_receipts[0].dataset_id
  table_id   = "workflow_runs"
  project    = var.project_id

  schema = jsonencode([
    { name = "workflow_id",      type = "STRING",    mode = "REQUIRED" },
    { name = "status",           type = "STRING",    mode = "REQUIRED" },
    { name = "input_cube_id",    type = "STRING",    mode = "NULLABLE" },
    { name = "result_cube_id",   type = "STRING",    mode = "NULLABLE" },
    { name = "agent_id",         type = "STRING",    mode = "NULLABLE" },
    { name = "started_at",       type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "completed_at",     type = "TIMESTAMP", mode = "NULLABLE" },
    { name = "runtime_policy",   type = "STRING",    mode = "NULLABLE" },
    { name = "metadata",         type = "JSON",      mode = "NULLABLE" },
  ])
}

# --- Pub/Sub for Workflow Events ---

resource "google_pubsub_topic" "a2ac_sandbox_events" {
  count   = var.enable_pubsub_events ? 1 : 0
  name    = "${var.deployment_name}-events"
  project = var.project_id
}

# --- IAM Service Account ---

resource "google_service_account" "a2ac_sandbox_runtime" {
  account_id   = "${var.deployment_name}-rt"
  display_name = "A2AC Sandbox Runtime"
  project      = var.project_id
}

# --- Outputs ---

output "sandbox_url" {
  value = google_cloud_run_v2_service.a2ac_sandbox.uri
}

output "agent_card_url" {
  value = "${google_cloud_run_v2_service.a2ac_sandbox.uri}/.well-known/agent.json"
}

output "receipt_dataset" {
  value = var.enable_bigquery_receipts ? google_bigquery_dataset.a2ac_sandbox_receipts[0].dataset_id : "disabled"
}

output "workflow_topic" {
  value = var.enable_pubsub_events ? google_pubsub_topic.a2ac_sandbox_events[0].name : "disabled"
}

output "service_account_email" {
  value = google_service_account.a2ac_sandbox_runtime.email
}
