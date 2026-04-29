# A2AC Core Substrate

> Open infrastructure for agent-to-agent workflow automation.  
> Deploy natively within Google Cloud or Azure. Zero external dependencies.

[![Cloud Run](https://img.shields.io/badge/Cloud%20Run-Live-4285F4?logo=google-cloud)](https://api.a2ac.ai)
[![Azure](https://img.shields.io/badge/Azure-Ready-0078D4?logo=microsoft-azure)](azure/)
[![A2A Protocol](https://img.shields.io/badge/A2A-Compliant-34A853)](https://api.a2ac.ai/.well-known/agent.json)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

## What is A2AC?

A2AC (Agent-to-Agent Communication) is a deterministic semantic memory and orchestration layer for multi-agent systems. It gives isolated AI agents a shared memory state with bank-grade cryptographic audit trails — deployed entirely within your own cloud tenant. Whether your data gravity is in Google or Microsoft, A2AC deploys natively inside your firewall.

**The problem:** Enterprises run AI features inside each platform separately — Salesforce, Azure, Google Cloud — but nothing connects them. There is no shared audit trail across systems.

**The solution:** A2AC provides the connective infrastructure. Push expensive AI compute off the CRM, produce shared work records, and validate agent definitions before execution.

## Architecture

```
┌──────────────┐     Cube Protocol     ┌─────────────────────────────────┐
│  Edge Node   │ ──────────────────►   │      Google Cloud (Cloud Run)   │
│              │                       │                                 │
│ • Local LLM  │                       │  ┌─────────────────────────┐   │
│   (Ollama)   │                       │  │  Cube Validator         │   │
│ • Data       │                       │  │  Semantic Brain         │   │──► Enterprise
│   Compress   │                       │  │  Commerce Engine        │   │   Systems
│              │                       │  │  Workflow Ledger        │   │
│              │                       │  │  Memory Librarian       │   │  • Salesforce
│              │                       │  │  Payment Gateway        │   │  • Azure
│              │                       │  │  Entitlement Manager    │   │  • CRM
│              │                       │  └─────────────────────────┘   │
└──────────────┘                       │     ▲              ▲           │
                                       │     │              │           │
                                       │  Vertex AI     Pub/Sub        │
                                       │  Embeddings    Routing        │
                                       └─────────────────────────────────┘
                                       ┌─────────────────────────────────┐
                                       │     Immutable Audit Trail       │
                                       └─────────────────────────────────┘
```

## Live Endpoints

| Endpoint | URL | Description |
|----------|-----|-------------|
| Root | `https://api.a2ac.ai/` | Swarm status, all services |
| Agent Card | `https://api.a2ac.ai/.well-known/agent.json` | A2A protocol discovery |
| Health | `https://api.a2ac.ai/health` | Readiness probe |
| Cube | `https://api.a2ac.ai/cube/` | Cube validator |
| Brain | `https://api.a2ac.ai/brain/` | Semantic memory |
| Commerce | `https://api.a2ac.ai/commerce/` | Offer management |
| Ledger | `https://api.a2ac.ai/ledger/` | Immutable audit chain |
| Librarian | `https://api.a2ac.ai/librarian/` | Memory organization |
| Plans | `https://api.a2ac.ai/entitlement/plans` | Pricing tiers |

## Services

| Service | Purpose | GCP | Azure |
|---------|---------|-----|-------|
| **Cube Validator** | Validates Q-Protocol agent definitions | Cloud Run | Container Apps |
| **Semantic Brain** | Shared memory via vector embeddings | Vertex AI + ChromaDB | Azure OpenAI + Cosmos DB |
| **Commerce Engine** | Agent-to-agent offer creation and settlement | Cloud Run | Container Apps |
| **Workflow Ledger** | Immutable blockchain-style audit trail | Cloud Run | Container Apps |
| **Memory Librarian** | Automatic memory clustering and organization | Cloud Run | Container Apps |
| **Payment Gateway** | Direct subscription management | Stripe | Stripe |
| **Entitlement Manager** | Marketplace billing integration | Cloud Commerce API | Azure Marketplace API |

## Pricing

| Plan | Price | Includes |
|------|-------|----------|
| **Community** | Free | Cube validation, semantic memory (100 records), read-only ledger |
| **Pro** | $49/month | Unlimited memory, full ledger, commerce engine, librarian |
| **Enterprise** | $499/month | Custom agents, dedicated Pub/Sub, SLA, priority support |

## Deploy

### Google Cloud (1-Click via Marketplace)

```bash
cd terraform/
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

Provisions: Cloud Run + Vertex AI + Pub/Sub + IAM

### Azure (1-Click via Marketplace)

```bash
cd azure/
az deployment group create \
  --resource-group YOUR_RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters @parameters.json
```

Provisions: Container Apps + Cosmos DB + Service Bus + Log Analytics

## Tech Stack

| Layer | Google Cloud | Azure |
|-------|-------------|-------|
| **Compute** | Cloud Run | Container Apps |
| **Memory** | Vertex AI + ChromaDB | Azure OpenAI + Cosmos DB |
| **Routing** | Pub/Sub | Service Bus |
| **Audit** | Cloud Logging | Log Analytics |
| **Deploy** | Terraform | Bicep / ARM |
| **Billing** | GCP Marketplace | Azure Marketplace (MACC-eligible) |

- **Runtime:** Python 3.12, Flask, Gunicorn
- **Container:** Docker (same image, both clouds)

## A2A Protocol Compliance

A2AC implements Google's [Agent-to-Agent protocol](https://google.github.io/A2A/). The Agent Card at `/.well-known/agent.json` exposes 7 discoverable skills that any A2A-compatible agent can invoke.

## Legal

- [Privacy Policy](Privacy_Policy.md)
- [Terms of Service](Terms_of_Service.md)

## Provider

**A2AC LLC**  
[a2ac.ai](https://a2ac.ai) • phil@a2ac.ai

---

*Built by Phil Hills. Hardened on mortgage underwriting. Ready for the world.*
