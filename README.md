# A2AC

A2AC is a connection and execution layer that turns local or cloud work environments into executable workflows.

It connects data, folders, scripts, tools, models, permissions, and receipts so approved workflows can run safely and be tracked.

A2AC does not need AI to work. AI can sit on top of it.

## Simple way to think about it

| | |
|---|---|
| **JSON** | The language systems use to describe the work |
| **Python** | The controlled workflow that does the work |
| **A2AC** | Routes the JSON into the right Python workflow and records what happened |

## What A2AC does

- **Connect** - Register systems: local files, cloud services, scripts, databases, SaaS tools, AI models.
- **Execute** - Turn workflows into governed Python agents. No shell. No ad hoc commands.
- **Receipt** - Every action writes proof. What data was used, what changed, who approved, what ran.

## Run it

```bash
# Local - single Docker container
docker compose up

# GCP Enterprise - Terraform
python3 scripts/04_gcp_apply.py
```

## Deployment options

| Mode | For |
|---|---|
| **Local** | Single Docker container. No cloud required. |
| **Hosted** | A2AC managed for you. |
| **Your Cloud** | AWS, Azure, or GCP. Runs in your environment. |
| **Enterprise** | Tenant-owned GCP. BigQuery receipts. Firestore state. Terraform. |

## Links

- **Website**: [a2ac.ai](https://a2ac.ai)
- **Agent Card**: [api.a2ac.ai/.well-known/agent.json](https://api.a2ac.ai/.well-known/agent.json)
- **Contact**: phil@a2ac.ai

## Created by

**Phil Hills** - AI Systems Architect, Seattle WA
[philhills.ai](https://philhills.ai) | [GitHub](https://github.com/Phil-Hills) | [LinkedIn](https://linkedin.com/in/philhills)

---

2026 A2AC LLC. All rights reserved.
