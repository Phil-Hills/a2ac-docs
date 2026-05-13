#!/usr/bin/env python3
"""
Example A2AC workflow.

Every workflow is a Python file with a run(inputs) function.
This is what goes in /a2ac/workflows/ on the Ubuntu Runner.
"""


def run(inputs: dict) -> dict:
    """
    Process input data and return results.

    This is where your business logic goes:
    - Read from /a2ac/data/
    - Write output to /a2ac/output/
    - Use approved Python packages
    - No shell, no curl, no ad hoc commands
    """
    name = inputs.get("name", "World")
    return {
        "message": f"Hello, {name}. Workflow executed successfully.",
        "inputs_received": inputs,
    }
