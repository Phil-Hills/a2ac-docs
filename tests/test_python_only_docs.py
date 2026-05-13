"""Test Python-only compliance across all docs and configs."""
import json
from pathlib import Path

def test_readme_no_curl():
    readme = Path("README.md").read_text()
    assert "curl " not in readme.lower(), "README contains curl examples"
    assert "curl -" not in readme.lower(), "README contains curl flags"

def test_readme_no_bash_deploy():
    readme = Path("README.md").read_text()
    assert "```bash" not in readme, "README contains bash code blocks"
    assert "```sh" not in readme, "README contains sh code blocks"

def test_readme_no_blocked_words():
    readme = Path("README.md").read_text().lower()
    for word in ["mortgage", "blockchain", "immutable", "thought signatures"]:
        assert word not in readme, f"README contains blocked word: {word}"

def test_agent_card_no_blocked_skills():
    card = json.loads(Path("agent_card.json").read_text())
    skill_ids = {s["id"] for s in card.get("skills", [])}
    blocked = {"commerce_offer", "payment_subscribe", "brain_recall", "brain_remember", "librarian_organize"}
    violations = skill_ids & blocked
    assert not violations, f"Blocked skills in agent_card: {violations}"

def test_terraform_no_blocked_language():
    tf = Path("terraform/main.tf").read_text().lower()
    assert "thought_signatures" not in tf, "Terraform contains thought_signatures"
    assert "thought_hash" not in tf, "Terraform contains thought_hash"

def test_terraform_no_production_images():
    tf = Path("terraform/main.tf").read_text()
    assert "gcr.io/deployment-2026-core" not in tf, "Terraform exposes production image"

def test_python_only_docs_exist():
    assert Path("docs/python-only-runtime.md").exists(), "Missing docs/python-only-runtime.md"
    assert Path("docs/local-docker.md").exists(), "Missing docs/local-docker.md"
    assert Path("docs/a2ac-one.md").exists(), "Missing docs/a2ac-one.md"
    assert Path("docs/a2ac-advisory.md").exists(), "Missing docs/a2ac-advisory.md"
    assert Path("docs/deployment-services.md").exists(), "Missing docs/deployment-services.md"
