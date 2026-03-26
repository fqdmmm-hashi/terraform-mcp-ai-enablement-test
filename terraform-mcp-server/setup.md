# Setup: Terraform MCP Server Demo

Complete these steps before running `demo.sh`. Allow 20–30 minutes.

---

## Prerequisites

| Requirement | Minimum version | Check |
|-------------|----------------|-------|
| Terraform CLI | 1.6+ | `terraform version` |
| Node.js | 18+ | `node --version` |
| An AI client that supports MCP | — | See options below |
| HCP Terraform account (or local backend) | — | `terraform login` |

---

## Step 1 — Install the Terraform MCP Server

```bash
# Install via npm
npm install -g @hashicorp/terraform-mcp-server

# Verify installation
terraform-mcp-server --version
```

> **If you hit a permissions error:** Use `sudo npm install -g` or configure npm to use a local prefix directory.

---

## Step 2 — Configure your AI client

The MCP server needs to be registered with your AI client. Below are instructions for common clients.

### Claude Desktop
Add the following to your Claude Desktop MCP config file (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "terraform": {
      "command": "terraform-mcp-server",
      "args": ["start"]
    }
  }
}
```

Restart Claude Desktop after saving.

### Other MCP-compatible clients
Point the client at the MCP server endpoint. The server runs on `localhost:3000` by default. Consult your client's documentation for the exact configuration format.

---

## Step 3 — Authenticate Terraform

```bash
# For HCP Terraform
terraform login

# For a local backend, no auth needed — the demo will use a local state file
```

---

## Step 4 — Clone the demo workspace

The demo script uses a minimal Terraform configuration that provisions a local null resource (no cloud credentials needed for the basic demo). For a cloud demo, see the advanced setup below.

```bash
# The demo workspace is bundled with this repo — nothing to clone
cd terraform-mcp-server/
ls workspace/   # Should show main.tf, variables.tf, outputs.tf
```

---

## Step 5 — Validate everything

```bash
./demo.sh --check
```

This runs a preflight check without launching the full demo. Expected output:

```
✓ Terraform CLI found (v1.x.x)
✓ MCP server installed
✓ AI client reachable
✓ Workspace valid
All checks passed. You're ready to demo.
```

---

## Advanced: Cloud provider setup

For a more impressive demo against a real cloud provider:

1. Add AWS/Azure/GCP credentials to your environment (`AWS_ACCESS_KEY_ID`, etc.)
2. Update `workspace/main.tf` to use a real provider and resource (a pre-approved minimal resource like an S3 bucket or Azure resource group works well)
3. Re-run `./demo.sh --check`

> **Important:** Use a dedicated demo account with spending limits. Never demo against a production account.

---

## Backup plan

If the live demo fails, use the screen recording:

```bash
# Record a successful run ahead of time
./demo.sh --record    # saves to demo-recording.mp4
```

Play the recording from your local player — it looks live to most audiences.
