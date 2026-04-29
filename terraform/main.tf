# A2AC Core Substrate — Terraform Deployment Module
# Users deploy this from Google Cloud Marketplace into their own GCP project.
# Provisions all infrastructure for a fully self-contained A2AC deployment.
# Billing is handled through their GCP Marketplace subscription.

variable "project_id" {
  description = "The GCP project to deploy A2AC into"
  type        = string
}

variable "region" {
  description = "GCP region for deployment"
  type        = string
  default     = "us-central1"
}

variable "a2ac_plan" {
  description = "A2AC subscription plan: community, pro, or enterprise"
  type        = string
  default     = "community"
}

# ──────────────────────────────────────────────
# Enable required APIs
# ──────────────────────────────────────────────
resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "aiplatform" {
  project = var.project_id
  service = "aiplatform.googleapis.com"
}

resource "google_project_service" "pubsub" {
  project = var.project_id
  service = "pubsub.googleapis.com"
}

resource "google_project_service" "firestore" {
  project = var.project_id
  service = "firestore.googleapis.com"
}

resource "google_project_service" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"
}

# ──────────────────────────────────────────────
# Firestore — Semantic Memory State
# Stores cube definitions, agent memory, and workflow state
# ──────────────────────────────────────────────
resource "google_firestore_database" "a2ac_brain" {
  project     = var.project_id
  name        = "a2ac-brain"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.firestore]
}

# ──────────────────────────────────────────────
# BigQuery — Q-Protocol Audit Trail
# Immutable cryptographic thought signatures for compliance
# ──────────────────────────────────────────────
resource "google_bigquery_dataset" "audit_trail" {
  project    = var.project_id
  dataset_id = "a2ac_audit"
  location   = "US"

  labels = {
    purpose = "q-protocol-audit"
  }

  depends_on = [google_project_service.bigquery]
}

resource "google_bigquery_table" "thought_signatures" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.audit_trail.dataset_id
  table_id   = "thought_signatures"

  schema = jsonencode([
    { name = "timestamp",       type = "TIMESTAMP",  mode = "REQUIRED", description = "When the thought was recorded" },
    { name = "agent_id",        type = "STRING",     mode = "REQUIRED", description = "Agent that produced the thought" },
    { name = "cube_id",         type = "STRING",     mode = "NULLABLE", description = "Cube definition that triggered the workflow" },
    { name = "action",          type = "STRING",     mode = "REQUIRED", description = "Action taken (validate, remember, recall, offer, mine)" },
    { name = "input_hash",      type = "STRING",     mode = "REQUIRED", description = "BLAKE3 hash of the input payload" },
    { name = "output_hash",     type = "STRING",     mode = "REQUIRED", description = "BLAKE3 hash of the output result" },
    { name = "thought_hash",    type = "STRING",     mode = "REQUIRED", description = "Combined deterministic signature" },
    { name = "previous_hash",   type = "STRING",     mode = "NULLABLE", description = "Hash of the previous thought in the chain" },
    { name = "duration_ms",     type = "INTEGER",    mode = "REQUIRED", description = "Execution time in milliseconds" },
    { name = "status",          type = "STRING",     mode = "REQUIRED", description = "success, failure, or timeout" },
    { name = "metadata",        type = "JSON",       mode = "NULLABLE", description = "Additional context and payload data" }
  ])

  depends_on = [google_bigquery_dataset.audit_trail]
}

resource "google_bigquery_table" "workflow_ledger" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.audit_trail.dataset_id
  table_id   = "workflow_ledger"

  schema = jsonencode([
    { name = "timestamp",     type = "TIMESTAMP", mode = "REQUIRED", description = "Block creation time" },
    { name = "block_index",   type = "INTEGER",   mode = "REQUIRED", description = "Sequential block number" },
    { name = "sender",        type = "STRING",    mode = "REQUIRED", description = "Sending agent" },
    { name = "recipient",     type = "STRING",    mode = "REQUIRED", description = "Receiving agent" },
    { name = "amount",        type = "FLOAT",     mode = "REQUIRED", description = "Transaction value" },
    { name = "proof",         type = "INTEGER",   mode = "REQUIRED", description = "Proof of work value" },
    { name = "previous_hash", type = "STRING",    mode = "REQUIRED", description = "Hash linking to previous block" },
    { name = "block_hash",    type = "STRING",    mode = "REQUIRED", description = "Hash of this block" },
    { name = "payload",       type = "JSON",      mode = "NULLABLE", description = "Transaction payload data" }
  ])

  depends_on = [google_bigquery_dataset.audit_trail]
}

# ──────────────────────────────────────────────
# Deploy A2AC Swarm Node
# ──────────────────────────────────────────────
resource "google_cloud_run_v2_service" "a2ac_swarm" {
  name     = "a2ac-swarm-node"
  location = var.region
  project  = var.project_id

  template {
    containers {
      image = "us-central1-docker.pkg.dev/a2ac-ai-platform/a2ac-images/swarm-node:latest"

      resources {
        limits = {
          memory = "1Gi"
          cpu    = "1"
        }
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }

      env {
        name  = "GOOGLE_CLOUD_REGION"
        value = var.region
      }

      env {
        name  = "A2AC_PLAN"
        value = var.a2ac_plan
      }

      env {
        name  = "A2AC_ENTITLEMENT_URL"
        value = "https://api.a2ac.ai/entitlement/check"
      }

      env {
        name  = "FIRESTORE_DATABASE"
        value = google_firestore_database.a2ac_brain.name
      }

      env {
        name  = "BIGQUERY_DATASET"
        value = google_bigquery_dataset.audit_trail.dataset_id
      }

      ports {
        container_port = 8080
      }

      startup_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 10
        period_seconds        = 3
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [
    google_project_service.run,
    google_project_service.aiplatform,
    google_firestore_database.a2ac_brain,
    google_bigquery_table.thought_signatures,
  ]
}

# Allow unauthenticated access to the service
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = google_cloud_run_v2_service.a2ac_swarm.project
  location = google_cloud_run_v2_service.a2ac_swarm.location
  name     = google_cloud_run_v2_service.a2ac_swarm.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ──────────────────────────────────────────────
# Pub/Sub — Agent-to-Agent Routing
# ──────────────────────────────────────────────
resource "google_pubsub_topic" "a2ac_events" {
  name    = "a2ac-workflow-events"
  project = var.project_id

  depends_on = [google_project_service.pubsub]
}

# ──────────────────────────────────────────────
# Outputs
# ──────────────────────────────────────────────
output "service_url" {
  description = "URL of the deployed A2AC Swarm Node"
  value       = google_cloud_run_v2_service.a2ac_swarm.uri
}

output "agent_card_url" {
  description = "URL of the A2A Agent Card"
  value       = "${google_cloud_run_v2_service.a2ac_swarm.uri}/.well-known/agent.json"
}

output "health_check_url" {
  description = "URL of the health check endpoint"
  value       = "${google_cloud_run_v2_service.a2ac_swarm.uri}/health"
}

output "firestore_database" {
  description = "Firestore database for semantic memory state"
  value       = google_firestore_database.a2ac_brain.name
}

output "bigquery_dataset" {
  description = "BigQuery dataset for Q-Protocol audit trail"
  value       = google_bigquery_dataset.audit_trail.dataset_id
}

output "audit_table" {
  description = "BigQuery table for cryptographic thought signatures"
  value       = "${google_bigquery_dataset.audit_trail.dataset_id}.${google_bigquery_table.thought_signatures.table_id}"
}
