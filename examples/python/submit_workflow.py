#!/usr/bin/env python3
"""Submit a workflow request to the A2AC Gateway."""
import json, sys, urllib.request

gateway = sys.argv[1] if len(sys.argv) > 1 else "https://a2ac-gateway-235894147478.us-central1.run.app"

request_data = {
    "workflow": "echo",
    "inputs": {"message": "Hello from A2AC"},
    "source": "example-script",
}

req = urllib.request.Request(
    f"{gateway}/workflow",
    data=json.dumps(request_data).encode(),
    headers={"Content-Type": "application/json"},
)
r = urllib.request.urlopen(req, timeout=30)
print(json.dumps(json.loads(r.read()), indent=2))
