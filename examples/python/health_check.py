#!/usr/bin/env python3
"""Check the health of all A2AC services."""
import json, urllib.request

services = {
    "Gateway":    "https://a2ac-gateway-235894147478.us-central1.run.app/health",
    "Executor":   "https://a2ac-executor-235894147478.us-central1.run.app/health",
    "Receipt API": "https://a2ac-receipts-235894147478.us-central1.run.app/health",
}

for name, url in services.items():
    try:
        r = urllib.request.urlopen(url, timeout=10)
        data = json.loads(r.read())
        print(f"  ✓ {name:12s} | {data.get('status', 'unknown')}")
    except Exception as e:
        print(f"  ✗ {name:12s} | {e}")
