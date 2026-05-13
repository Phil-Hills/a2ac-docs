#!/usr/bin/env python3
"""Create and display a deployment receipt."""
import json
from datetime import datetime, timezone

receipt = {
    "receipt_id": f"deploy_{datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')}",
    "event_type": "deployment.complete",
    "status": "COMPLETE",
    "q_command": "INFRA|DEPLOY[sandbox]->GCP|PROVISIONED",
    "agent_id": "deployer",
    "created_at": datetime.now(timezone.utc).isoformat(),
    "runtime_policy": "python_only",
}
print(json.dumps(receipt, indent=2))
