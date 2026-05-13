"""
A2AC Local Hub - Flask application
Provides Cube, Q, Receipt, and Agent endpoints for local development.
"""

import hashlib
import json
import os
import uuid
from datetime import datetime, timezone
from pathlib import Path

from flask import Flask, jsonify, request

app = Flask(__name__)

DATA_DIR = Path(os.environ.get("DATA_DIR", "/app/data"))
CUBES_DIR = DATA_DIR / "cubes"
RECEIPTS_FILE = DATA_DIR / "receipts" / "receipts.jsonl"
AGENTS_DIR = DATA_DIR / "agents"

for d in [CUBES_DIR, RECEIPTS_FILE.parent, AGENTS_DIR]:
    d.mkdir(parents=True, exist_ok=True)


AGENT_CARD = {
    "name": "A2AC Local",
    "description": "Local A2AC sandbox for validating Cube envelopes, Q commands, and receipts.",
    "url": "http://localhost:8080",
    "version": "1.0.0",
    "provider": {"organization": "A2AC LLC", "url": "https://a2ac.ai"},
    "skills": [
        {"id": "cube_validate", "name": "Cube Validation"},
        {"id": "q_parse", "name": "Q Command Parse"},
        {"id": "receipt_record", "name": "Receipt Record"},
        {"id": "agent_register", "name": "Agent Register"},
        {"id": "local_status", "name": "Local Status"},
    ],
}


@app.route("/health")
def health():
    return jsonify({"status": "healthy", "timestamp": datetime.now(timezone.utc).isoformat()})


@app.route("/.well-known/agent.json")
def agent_card():
    return jsonify(AGENT_CARD)


@app.route("/cube/make", methods=["POST"])
def cube_make():
    """Create a Cube envelope and store it."""
    data = request.get_json(silent=True) or {}

    cube_id = f"cube_{uuid.uuid4().hex[:12]}"
    ts = datetime.now(timezone.utc).isoformat()

    cube = {
        "cube_id": cube_id,
        "created_at": ts,
        "payload": data.get("payload", {}),
        "metadata": data.get("metadata", {}),
        "hash": hashlib.blake2b(json.dumps(data, sort_keys=True).encode(), digest_size=16).hexdigest(),
    }

    cube_file = CUBES_DIR / f"{cube_id}.json"
    cube_file.write_text(json.dumps(cube, indent=2))

    return jsonify({"cube_id": cube_id, "status": "created", "hash": cube["hash"]}), 201


@app.route("/cube/<cube_id>")
def cube_get(cube_id):
    """Retrieve a Cube by ID."""
    cube_file = CUBES_DIR / f"{cube_id}.json"
    if not cube_file.exists():
        return jsonify({"error": "Cube not found"}), 404

    cube = json.loads(cube_file.read_text())
    return jsonify(cube)


@app.route("/q/parse", methods=["POST"])
def q_parse():
    """Parse a Q command string into structured form."""
    data = request.get_json(silent=True) or {}
    q_command = data.get("q_command", "")

    if not q_command:
        return jsonify({"error": "q_command is required"}), 400

    try:
        # Format: DOMAIN|SEQUENCE[ARG]->TARGET|OUTCOME
        parts = q_command.split("->")
        left = parts[0] if len(parts) > 0 else ""
        right = parts[1] if len(parts) > 1 else ""

        left_parts = left.split("|")
        domain = left_parts[0] if len(left_parts) > 0 else ""

        sequence_raw = left_parts[1] if len(left_parts) > 1 else ""
        if "[" in sequence_raw:
            sequence = sequence_raw.split("[")[0]
            arg = sequence_raw.split("[")[1].rstrip("]")
        else:
            sequence = sequence_raw
            arg = None

        right_parts = right.split("|")
        target = right_parts[0] if len(right_parts) > 0 else ""
        outcome = right_parts[1] if len(right_parts) > 1 else ""

        return jsonify({
            "q_command": q_command,
            "parsed": {
                "domain": domain,
                "sequence": sequence,
                "arg": arg,
                "target": target,
                "outcome": outcome,
            },
            "valid": True,
        })
    except Exception as e:
        return jsonify({"q_command": q_command, "valid": False, "error": str(e)}), 400


@app.route("/receipt/write", methods=["POST"])
def receipt_write():
    """Write a receipt to the local ledger."""
    data = request.get_json(silent=True) or {}

    receipt_id = data.get("receipt_id", f"rcpt_{uuid.uuid4().hex[:12]}")
    ts = datetime.now(timezone.utc).isoformat()

    receipt = {
        "receipt_id": receipt_id,
        "event_type": data.get("event_type", "workflow.action"),
        "status": data.get("status", "COMPLETE"),
        "q_command": data.get("q_command", ""),
        "cube_id": data.get("cube_id", ""),
        "result_cube_id": data.get("result_cube_id", ""),
        "agent_id": data.get("agent_id", "local"),
        "created_at": ts,
        "runtime_policy": "python_only",
    }

    with open(RECEIPTS_FILE, "a") as f:
        f.write(json.dumps(receipt) + "\n")

    return jsonify({"receipt_id": receipt_id, "status": "recorded"}), 201


@app.route("/receipts")
def receipts_list():
    """List recent receipts."""
    if not RECEIPTS_FILE.exists():
        return jsonify({"receipts": []})

    receipts = []
    for line in RECEIPTS_FILE.read_text().strip().split("\n"):
        if line.strip():
            receipts.append(json.loads(line))

    # Return last 50
    return jsonify({"receipts": receipts[-50:], "total": len(receipts)})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
