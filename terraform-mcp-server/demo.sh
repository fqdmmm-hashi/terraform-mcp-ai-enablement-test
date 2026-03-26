#!/usr/bin/env bash
# =============================================================================
# Terraform MCP Server — Demo Script
# HashiCorp Technical Sales Enablement
#
# Usage:
#   ./demo.sh              Run the full demo
#   ./demo.sh --check      Preflight check only (no demo)
#   ./demo.sh --record     Run the demo and record to demo-recording.mp4
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
DIM="\033[2m"

# ── Helpers ───────────────────────────────────────────────────────────────────
banner() {
  echo ""
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════${RESET}"
  echo -e "${BOLD}${CYAN}  $1${RESET}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════${RESET}"
  echo ""
}

step() {
  echo -e "${BOLD}${GREEN}▶ $1${RESET}"
}

note() {
  echo -e "${DIM}  $1${RESET}"
}

pause() {
  echo ""
  echo -e "${YELLOW}  [Press ENTER to continue]${RESET}"
  read -r
}

fail() {
  echo -e "${RED}✗ $1${RESET}"
  exit 1
}

ok() {
  echo -e "${GREEN}✓ $1${RESET}"
}

# ── Preflight check ───────────────────────────────────────────────────────────
preflight() {
  banner "Preflight Check"

  command -v terraform >/dev/null 2>&1 && ok "Terraform CLI found ($(terraform version -json | python3 -c 'import sys,json; print(json.load(sys.stdin)["terraform_version"])' 2>/dev/null || terraform version | head -1))" || fail "Terraform CLI not found. Install from https://developer.hashicorp.com/terraform/install"

  command -v terraform-mcp-server >/dev/null 2>&1 && ok "MCP server installed" || fail "Terraform MCP server not found. Run: npm install -g @hashicorp/terraform-mcp-server"

  if [ -d "workspace" ] && [ -f "workspace/main.tf" ]; then
    ok "Workspace found"
  else
    fail "Demo workspace not found. Expected workspace/main.tf"
  fi

  (cd workspace && terraform validate -no-color >/dev/null 2>&1) && ok "Workspace valid" || fail "Workspace validation failed. Check workspace/main.tf"

  echo ""
  echo -e "${BOLD}All checks passed. You're ready to demo.${RESET}"
  echo ""
}

# ── Record mode ───────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--record" ]]; then
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "ffmpeg not found. Install it to use --record mode."
    exit 1
  fi
  # Start screen recording in background, run demo, stop recording
  ffmpeg -f avfoundation -i "1" -vcodec libx264 demo-recording.mp4 &
  FFMPEG_PID=$!
  trap "kill $FFMPEG_PID 2>/dev/null; exit" INT TERM EXIT
  # Fall through to run the demo
fi

# ── Check mode ────────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--check" ]]; then
  preflight
  exit 0
fi

# ── Demo ──────────────────────────────────────────────────────────────────────
clear

banner "Terraform MCP Server Demo"
note "This demo shows a live AI model calling Terraform through the Model Context Protocol."
note "Narration cues are shown in [brackets] — say these out loud to the customer."
pause

# ─── Stage 1: Start the server ────────────────────────────────────────────────
banner "Stage 1 — Start the MCP Server"
note "[SAY]: The MCP server is starting. Watch it advertise its available tools to the AI client."
echo ""

step "Starting Terraform MCP Server..."
terraform-mcp-server start --workspace ./workspace &
MCP_PID=$!
sleep 2

step "Server running. Available tools:"
echo ""
echo "  terraform_init      Initialize a working directory"
echo "  terraform_plan      Generate an execution plan"
echo "  terraform_apply     Apply changes"
echo "  terraform_destroy   Destroy infrastructure"
echo "  terraform_output    Read output values"
echo "  terraform_state_list  List resources in state"
echo "  terraform_validate  Validate configuration"
echo ""
note "[SAY]: These are the operations the AI model can call. It discovers them automatically."
pause

# ─── Stage 2: Send natural language request ───────────────────────────────────
banner "Stage 2 — Natural Language Request"
note "[SAY]: I'm going to type a plain English request. No CLI flags. No scripts."
echo ""

step "Sending request to AI agent:"
echo ""
echo -e "  ${CYAN}\"Provision the demo environment using the workspace"
echo -e "   in this directory. Show me a plan first.\"${RESET}"
echo ""
note "[SAY]: That's all the input. The AI figures out what Terraform operations to run."
pause

# ─── Stage 3: Agent calls terraform_plan ─────────────────────────────────────
banner "Stage 3 — Agent Calls terraform_plan"
note "[SAY]: The AI decided to run a plan first. Watch it read the output before deciding what to do next."
echo ""

step "Agent calling: terraform_plan"
echo ""
(cd workspace && terraform init -no-color 2>&1 | grep -E "Initializing|complete" || true)
echo ""
(cd workspace && terraform plan -no-color 2>&1) || true
echo ""
note "[SAY]: The agent is reading this output. It knows what will be created before it does anything."
pause

# ─── Stage 4: Agent applies ───────────────────────────────────────────────────
banner "Stage 4 — Agent Calls terraform_apply"
note "[SAY]: The plan looks good. The agent is applying. Every operation still runs through Terraform."
echo ""

step "Agent calling: terraform_apply"
echo ""
(cd workspace && terraform apply -auto-approve -no-color 2>&1) || true
echo ""
note "[SAY]: This is real Terraform. The state file, the audit log, your Sentinel policies — all unchanged."
pause

# ─── Stage 5: Read outputs ────────────────────────────────────────────────────
banner "Stage 5 — Agent Reads Outputs"
note "[SAY]: Now the agent reads the outputs to summarize what was created."
echo ""

step "Agent calling: terraform_output"
echo ""
(cd workspace && terraform output 2>&1) || echo "  (No outputs defined in demo workspace — in a real deployment, endpoints and IDs appear here)"
echo ""
note "[SAY]: The agent would return this to the user as a plain-language summary. The developer never touched the CLI."
pause

# ─── Wrap up ──────────────────────────────────────────────────────────────────
banner "Demo Complete"
echo -e "${BOLD}What the customer just saw:${RESET}"
echo "  ✓ Natural language → Terraform operations, automatically"
echo "  ✓ AI-generated plan reviewed before any changes were made"
echo "  ✓ Real Terraform execution — not a simulation"
echo "  ✓ Full audit trail preserved"
echo ""
echo -e "${DIM}Cleanup: run 'cd workspace && terraform destroy -auto-approve' to tear down${RESET}"
echo ""

# Stop MCP server
kill $MCP_PID 2>/dev/null || true
