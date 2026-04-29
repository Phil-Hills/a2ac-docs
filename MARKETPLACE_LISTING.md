# A2AC Marketplace Listing — Ready to Publish

Everything below maps directly to Producer Portal fields. Copy-paste when portal is enabled.

---

## Product Details Tab

### Product Name
```
A2AC Workflow Agent
```

### Tagline (max 80 chars)
```
Open infrastructure for agent-to-agent workflow automation
```

### Short Description (max 160 chars)
```
Connect AI workflows across Salesforce, Azure, and Google Cloud with shared work records, semantic memory, and cube-based validation.
```

### Full Description

```
A2AC (Agent-to-Agent Communication) is open infrastructure that lets approved AI workflows execute across platforms and leave a shared work record.

THE PROBLEM
Enterprises run AI features inside each platform separately — Salesforce, Azure, Google Cloud — but nothing connects them. Heavy compute runs inside the CRM where it's expensive and slow. There is no shared audit trail across systems.

THE SOLUTION
A2AC provides a connective layer that:

• Pushes AI compute to where it's cheap — run document generation, condition review, and analysis on Google Cloud, then send clean results back to CRM and LOB systems.
• Produces shared work records — every workflow leaves an auditable record: who triggered it, how long it took, what the outcome was, and what happens next.
• Validates agent definitions — the Cube format ensures workflows are well-formed before execution.
• Stores semantic memory — agents remember context across sessions via Vertex AI embeddings and vector search.

CORE SERVICES
• Cube Validator: Validates Q-Protocol agent definitions for structure and correctness
• Semantic Brain: Stores and recalls agent memories using Vertex AI text-embedding-004
• Commerce Engine: Creates, tracks, and settles binding offers between agents
• Workflow Ledger: Immutable blockchain-style record of all agent transactions
• Memory Librarian: Automatically organizes and clusters memories across agent swarms

DEPLOYMENT MODEL
A2AC supports a hybrid cloud/edge architecture:
• Cloud (The Hive): Runs on Google Cloud Run. Hosts the Brain, Ledger, and Validator.
• Edge (The Worker): Runs locally on your machine via Ollama. Compresses private data into Cubes before sending them to the cloud. Ensures data privacy and reduces cloud inference costs.

USE CASES
• Financial Services: Automate mortgage workflows — from referral through closing — across Salesforce and cloud compute
• Operations: Replace manual back-office processes with measured, recorded agent workflows
• Cross-Platform Integration: Connect Microsoft, Salesforce, and Google Cloud with one shared workflow layer
```

### Product Category
```
AI & Machine Learning > AI Agents
```

### Product Logo
```
assets/logo_128.png (128x128 PNG)
```

### Product Icon (for search results)
```
assets/logo_128.png
```

---

## Highlights (3 required)

### Highlight 1
**Title:** Cross-Platform Workflow Automation
**Description:** Connect Salesforce, Azure, and Google Cloud with shared work records. Push expensive AI compute off the CRM and onto cloud infrastructure where it costs 90% less.

### Highlight 2
**Title:** Immutable Audit Trail
**Description:** Every agent workflow produces a verifiable ledger entry. Track who triggered it, how long it took, what the outcome was, and what happens next — across systems.

### Highlight 3
**Title:** A2A Protocol Native
**Description:** Fully compliant with Google's Agent-to-Agent protocol. Agent Card at /.well-known/agent.json defines 6 skills that any A2A-compatible agent can discover and invoke.

---

## Architecture Diagram

```
assets/architecture_diagram.png
```

![A2AC Architecture](file:///home/phil/projects/ai-summary-cube/a2ac_platform/assets/architecture_diagram.png)

---

## Live Endpoint Screenshots

### Screenshot 1: Swarm Status
**Caption:** All 5 A2AC services running on Cloud Run
```json
{
    "system": "A2AC Agent Swarm",
    "version": "1.0.0",
    "status": "operational",
    "provider": "A2AC LLC",
    "agent_card": "/.well-known/agent.json",
    "nodes": [
        {"name": "cube_service", "status": "online"},
        {"name": "brain_service", "status": "online"},
        {"name": "commerce_service", "status": "online"},
        {"name": "ledger_service", "status": "online"},
        {"name": "librarian_service", "status": "online"}
    ]
}
```

### Screenshot 2: Agent Card
**Caption:** A2A-compliant Agent Card with 6 discoverable skills
```
https://api.a2ac.ai/.well-known/agent.json
```

### Screenshot 3: Semantic Brain
**Caption:** Vertex AI-powered semantic memory with vector search
```json
{
    "service": "A2AC Semantic Brain",
    "status": "online",
    "backend": "Vertex AI + ChromaDB",
    "memory_count": 0
}
```

---

## Pricing Tab

### Pricing Model
```
Free (with optional upgrade path)
```

### Plan Details

| Tier | Price | Includes |
|------|-------|----------|
| **Community** | Free | Core workflow automation, Cube validation, Semantic memory, Workflow ledger |
| **Enterprise** | Usage-based (via Marketplace billing) | Priority support, SLA, dedicated Pub/Sub metering, custom integrations |

### Pricing Notes
```
Community tier is free with no time limit. Enterprise tier is metered via Google Cloud Pub/Sub usage analytics. Contact phil@a2ac.ai for enterprise pricing details.
```

---

## Technical Integration Tab

### Deployment Type
```
Cloud Run (Container-based)
```

### Service URL
```
https://api.a2ac.ai
```

### Agent Card URL
```
https://api.a2ac.ai/.well-known/agent.json
```

### Health Check
```
https://api.a2ac.ai/health
```

### GCP Project
```
a2ac-ai-platform (541686670088)
```

### Region
```
us-central1
```

### Runtime
```
Python 3.12, Flask, Gunicorn
```

### Dependencies
```
- Google Cloud Vertex AI (text-embedding-004)
- Google Cloud Pub/Sub (q-protocol-bus)
- Google Cloud Artifact Registry
- ChromaDB (ephemeral, in-container)
```

---

## Support Tab

### Support Description
```
Community support via email. Enterprise tier includes SLA-backed support.
```

### Support URL
```
https://a2ac.ai
```

### Support Email
```
phil@a2ac.ai
```

### Documentation URL
```
https://a2ac.ai/docs
```

### Terms of Service
```
https://a2ac.ai/terms (file: a2ac_platform/Terms_of_Service.md)
```

### Privacy Policy
```
https://a2ac.ai/privacy (file: a2ac_platform/Privacy_Policy.md)
```

---

## Assets Checklist

| Asset | File | Status |
|-------|------|--------|
| Logo (128x128) | `assets/logo_128.png` | ✅ |
| Architecture Diagram | `assets/architecture_diagram.png` | ✅ |
| Agent Card JSON | `agent_card.json` | ✅ |
| Privacy Policy | `Privacy_Policy.md` | ✅ |
| Terms of Service | `Terms_of_Service.md` | ✅ |
| Screenshot: Swarm Status | Capture from `api.a2ac.ai/` | ✅ |
| Screenshot: Agent Card | Capture from `api.a2ac.ai/.well-known/agent.json` | ✅ |
| Screenshot: Brain Service | Capture from `api.a2ac.ai/brain/` | ✅ |
