#!/usr/bin/env python3
"""Execute a workflow directly on the A2AC Ubuntu Runner."""
import json, sys, urllib.request

executor = sys.argv[1] if len(sys.argv) > 1 else "https://a2ac-executor-235894147478.us-central1.run.app"

request_data = {
    "workflow": "verify_environment",
    "inputs": {},
    "source": "example-script",
}

req = urllib.request.Request(
    f"{executor}/execute",
    data=json.dumps(request_data).encode(),
    headers={"Content-Type": "application/json"},
)
r = urllib.request.urlopen(req, timeout=30)
result = json.loads(r.read())
print(json.dumps(result, indent=2))
print(f"\nReceipt: {result.get('receipt_id')}")
print(f"Status:  {result.get('status')}")
