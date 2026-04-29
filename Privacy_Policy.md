# A2AC Platform Privacy Policy

**Effective Date:** 2026-04-29
**Entity:** A2AC LLC

## 1. Data Processing

A2AC provides workflow automation infrastructure. The platform processes data in two modes:

- **Edge Processing:** Data processed by locally-deployed agents (e.g., via Ollama) remains on the user's hardware. A2AC LLC does not access, collect, or transmit locally-processed data unless the user explicitly configures cloud synchronization.

- **Cloud Processing:** When users deploy cloud-based agents on Google Cloud Platform, data is governed by the user's own Google Cloud IAM policies and access controls. A2AC LLC does not intercept, mirror, or retain user data processed through cloud-deployed agents.

## 2. Data Collection

A2AC LLC collects only:
- **Account Information:** Email address and organization name for service access.
- **Usage Metrics:** Anonymized, aggregate service usage data (API call counts, latency metrics) for performance monitoring. No prompt content or workflow payloads are logged.

## 3. Data Storage

Workflow records (`.cube` files) are stored in the user's own Google Cloud Storage buckets. A2AC LLC does not maintain copies of user workflow data outside the user's configured environment.

## 4. Data Deletion

Users may delete all associated data by removing their `.cube` files and cloud resources. A2AC LLC will delete account information upon written request within 30 days.

## 5. Third-Party Services

A2AC integrates with Google Cloud Vertex AI for embedding generation. Usage of Vertex AI is governed by [Google Cloud's Privacy Terms](https://cloud.google.com/terms/cloud-privacy-notice).

## 6. Contact

For privacy inquiries: phil@a2ac.ai
