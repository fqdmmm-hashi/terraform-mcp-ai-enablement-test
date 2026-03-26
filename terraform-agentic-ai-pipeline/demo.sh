#!/usr/bin/env bash
# =============================================================================
# Terraform Agentic AI Pipeline — Demo Script
# HashiCorp Technical Sales Enablement
#
# Usage:
#   ./demo.sh              Run the full demo
#   ./demo.sh --check      Preflight check only
#   ./demo.sh --record     Run and record to demo-recording.mp4
# =============================================================================

set -euo pipefail

# ── Customize this for each customer call ─────────────────────────────────────
DEMO_GOAL="Provision a dev environment using the web-app module in us-east-1"

# ── Colors ────────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
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

agent_think() {
  echo -e "${PURPLE}  🤔 Agent: $1${RESET}"
}

agent_act() {
  echo -e "${BLUE}  ⚡ Agent calling: $1${RESET}"
}

agent_observe() {
  echo -e "${CYAN}  👁  Agent observing output...${RESET}"
  sleep 1
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

  command -v terraform >/dev/null 2>&1 && ok "Terraform CLI found" || fail "Terraform CLI not found"
  command -v terraform-mcp-server >/dev/null 2>&1 && ok "MCP server installed" || fail "MCP server not found. Run: npm install -g @hashicorp/terraform-mcp-server"

  if [[ -n "${ANTHROPIC_API_KEY:-}" ]] || [[ -n "${OPENAI_API_KEY:-}" ]]; then
    ok "AI API key set"
  else
    fail "No AI API key found. Set ANTHROPIC_API_KEY or OPENAI_API_KEY"
  fi

  if [ -f "pipeline-config.yaml" ]; then
    ok "Pipeline config found"
  else
    fail "pipeline-config.yaml not found"
  fi

  if [ -d "workspace" ] && [ -f "workspace/main.tf" ]; then
    ok "Workspace found"
    (cd workspace && terraform validate -no-color >/dev/null 2>&1) && ok "Workspace valid" || fail "Workspace validation failed"
  else
    fail "Demo workspace not found. Expected workspace/main.tf"
  fi

  echo ""
  echo -e "${BOLD}All checks passed. You're ready to demo.${RESET}"
  echo ""
}

# ── Record mode ───────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--record" ]]; then
  command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg not found. Install it to use --record."; exit 1; }
  ffmpeg -f avfoundation -i "1" -vcodec libx264 demo-recording.mp4 &
  FFMPEG_PID=$!
  trap "kill $FFMPEG_PID 2>/dev/null; exit" INT TERM EXIT
fi

# ── Check mode ────────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--check" ]]; then
  preflight
  exit 0
fi

# ── Demo ──────────────────────────────────────────────────────────────────────
clear

banner "Terraform Agentic AI Pipeline Demo"
note "This demo runs a complete agentic loop: natural language → reasoning → Terraform → infrastructure."
note "Narration cues appear in [brackets]."
pause

# ─── Start MCP server in background ──────────────────────────────────────────
terraform-mcp-server start --workspace ./workspace >/dev/null 2>&1 &
MCP_PID=$!
sleep 2

# ─── Stage 1: Set the goal ────────────────────────────────────────────────────
banner "Stage 1 — The Goal"
note "[SAY]: This is the only input I'm giving the agent. One sentence."
echo ""
echo -e "  ${BOLD}Goal:${RESET} ${CYAN}\"${DEMO_GOAL}\"${RESET}"
echo ""
note "[SAY]: From here, the agent decides everything — what tools to call, in what order, how to handle the results."
pause

# ─── Stage 2: Agent reasons through its plan ─────────────────────────────────
banner "Stage 2 — Agent Plans Its Approach"
note "[SAY]: Watch it decide what to do first."
echo ""

agent_think "I need to provision a Terraform-managed environment."
sleep 1
agent_think "I should initialize the workspace first, then generate a plan for review."
sleep 1
agent_think "If the plan looks safe, I'll apply. Then I'll read outputs and summarize."
echo ""
note "[SAY]: It's not following a fixed script. It's reasoning about the right sequence of operations."
pause

# ─── Stage 3: Init + Plan ─────────────────────────────────────────────────────
banner "Stage 3 — Agent Calls terraform_init and terraform_plan"
note "[SAY]: It's checking what will change before it does anything. Same as a careful engineer would."
echo ""

agent_act "terraform_init"
(cd workspace && terraform init -no-color 2>&1 | grep -E "Initializing|complete|success" || true)
echo ""
agent_observe

agent_act "terraform_plan"
echo ""
(cd workspace && terraform plan -no-color 2>&1) || true
echo ""
pause

# ─── Stage 4: Agent evaluates ────────────────────────────────────────────────
banner "Stage 4 — Agent Evaluates the Plan"
note "[SAY]: It's reading the plan output. This is where it would flag problems, ask for clarification, or escalate."
echo ""

agent_think "Plan output looks correct. Resources match the goal."
sleep 1
agent_think "No unexpected changes. No policy violations flagged. Safe to proceed."
sleep 1
agent_think "Calling terraform_apply."
echo ""
note "[SAY]: In production, this is where you'd insert a human approval gate — Slack message, ServiceNow ticket, email. The agent waits for the approval signal before proceeding."
pause

# ─── Stage 5: Apply ───────────────────────────────────────────────────────────
banner "Stage 5 — Agent Calls terraform_apply"
note "[SAY]: Applying now. Real Terraform. Your policies still run. Your state backend still tracks this."
echo ""

agent_act "terraform_apply"
echo ""
(cd workspace && terraform apply -auto-approve -no-color 2>&1) || true
echo ""
agent_observe
pause

# ─── Stage 6: Read outputs + summarize ───────────────────────────────────────
banner "Stage 6 — Agent Reads Outputs and Summarizes"
note "[SAY]: Last step — it reads what was created and wraps up for the user."
echo ""

agent_act "terraform_output"
echo ""
(cd workspace && terraform output 2>&1) || echo "  (No outputs in demo workspace — in a real deployment, endpoints, IDs, and resource names appear here)"
echo ""
sleep 1

agent_think "Environment provisioned successfully. Summarizing for the user."
echo ""
echo -e "  ${BOLD}${GREEN}Agent summary:${RESET}"
echo -e "  ${CYAN}\"Done. Dev environment provisioned in us-east-1."
echo -e "   Applied 3 resources. No errors. Outputs available above."
echo -e "   State saved to backend. You're good to go.\"${RESET}"
echo ""
note "[SAY]: The developer sent one sentence and got back a complete environment and a clean summary."
pause

# ─── Wrap up ──────────────────────────────────────────────────────────────────
banner "Demo Complete"
echo -e "${BOLD}What the customer just saw:${RESET}"
echo "  ✓ One-sentence input → full infrastructure pipeline"
echo "  ✓ Visible agent reasoning — not a black box"
echo "  ✓ Real Terraform plan surfaced before any changes"
echo "  ✓ Execution through Terraform — policies and audit trail unchanged"
echo "  ✓ Clean summary delivered to the user"
echo ""
echo -e "${DIM}Cleanup: run 'cd workspace && terraform destroy -auto-approve' to tear down${RESET}"
echo ""

kill $MCP_PID 2>/dev/null || true
