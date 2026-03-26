# Setup: Terraform Agentic AI Pipeline Demo

Complete these steps before running `demo.sh`. Allow 20–30 minutes.

---

## Prerequisites

| Requirement | Minimum version | Check |
|-------------|----------------|-------|
| Terraform CLI | 1.6+ | `terraform version` |
| Node.js | 18+ | `node --version` |
| Python | 3.10+ | `python3 --version` |
| Terraform MCP Server | latest | `terraform-mcp-server --version` |
| AI client API key | — | See Step 3 |

---

## Step 1 — Install the Terraform MCP Server

If you've already set up the MCP server demo, skip this step.

```bash
npm install -g @hashicorp/terraform-mcp-server
terraform-mcp-server --version
```

---

## Step 2 — Install pipeline dependencies

```bash
cd terraform-agentic-ai-pipeline/
pip3 install -r requirements.txt
```

The requirements file includes the agent orchestration library and MCP client SDK.

---

## Step 3 — Configure your AI API key

The pipeline demo uses an AI model as the agent's reasoning engine. Set your API key as an environment variable.

```bash
# For Anthropic Claude (recommended)
export ANTHROPIC_API_KEY="your-key-here"

# Or for OpenAI
export OPENAI_API_KEY="your-key-here"
```

> **Security note:** Never commit API keys to this repo. Use environment variables or a secrets manager.

---

## Step 4 — Configure the pipeline

The pipeline configuration lives in `pipeline-config.yaml`. For the basic demo, the defaults work without changes. Review the key settings:

```yaml
# pipeline-config.yaml
agent:
  model: claude-3-5-sonnet-20241022   # AI model to use
  max_steps: 10                        # Max reasoning steps before stopping
  require_plan_approval: false         # Set to true to pause before apply

terraform:
  workspace_dir: ./workspace
  auto_apply: true                     # Set to false for plan-only demos

mcp_server:
  host: localhost
  port: 3000
```

---

## Step 5 — Authenticate Terraform

```bash
terraform login      # For HCP Terraform
# or skip for local backend
```

---

## Step 6 — Validate everything

```bash
./demo.sh --check
```

Expected output:

```
✓ Terraform CLI found
✓ MCP server installed
✓ AI API key set
✓ Pipeline config valid
✓ Workspace valid
All checks passed. You're ready to demo.
```

---

## Advanced: Using your own Terraform workspace

To demo against a workspace that's more relevant to the customer:

1. Copy your `main.tf` (and supporting files) into `workspace/`
2. Update `DEMO_GOAL` in `demo.sh` to match what the workspace does
3. Re-run `./demo.sh --check`

Keep it simple — a single module call or 2–3 resources is ideal for a demo.

---

## Backup plan

Record a successful run before the customer call:

```bash
./demo.sh --record    # Saves to demo-recording.mp4
```

The recording includes all terminal output and timestamps. It looks live to most audiences.
