# 04 — Agentic Pipeline Architecture

## How the full pipeline fits together

The Terraform agentic AI pipeline connects a natural language interface to real infrastructure through a chain of components. Here's how each layer works.

## Architecture overview

```
User / Upstream System
        │
        │  Natural language request
        ▼
┌───────────────────┐
│   AI Orchestrator  │  ← The agent (Claude, GPT-4, etc.)
│                   │    Reasons, plans, decides what to call
└────────┬──────────┘
         │  MCP tool calls
         ▼
┌───────────────────┐
│  Terraform MCP    │  ← Translates tool calls into Terraform operations
│  Server           │
└────────┬──────────┘
         │  CLI invocations
         ▼
┌───────────────────┐
│  Terraform Core   │  ← Reads state, generates plans, applies changes
│  + State Backend  │
└────────┬──────────┘
         │  API calls
         ▼
┌───────────────────┐
│  Cloud Provider   │  ← AWS, Azure, GCP, etc.
└───────────────────┘
```

## Layer by layer

### Layer 1 — The user or upstream system
The entry point. This can be a human typing a request into a chat interface, or an upstream system (a ticketing system, a deployment pipeline, a Slack bot) that passes a structured request to the agent.

### Layer 2 — The AI orchestrator
The agent. It receives the goal, reasons about what steps are needed, calls tools via MCP, observes results, and decides what to do next. It does not have direct access to infrastructure — it can only act through the tools exposed to it.

### Layer 3 — The Terraform MCP Server
The bridge. It receives tool call requests from the agent and translates them into Terraform CLI invocations. It manages the working directory, captures output, and returns results in a format the agent can reason about.

### Layer 4 — Terraform Core
Unchanged from how customers already use it. Reads the configuration, compares desired state to actual state in the backend, and executes changes. Policy enforcement (Sentinel, OPA) runs here.

### Layer 5 — Cloud provider
The actual infrastructure. AWS, Azure, GCP, or any Terraform-supported provider.

## What a complete request looks like

> User: "Provision a dev environment in us-east-1 with the standard web-app module."

1. Agent receives the request and identifies that it needs to run Terraform.
2. Agent calls `terraform_init` → MCP server runs init → returns success.
3. Agent calls `terraform_plan` with the appropriate variables → MCP server runs plan → returns the plan output.
4. Agent reads the plan, confirms it looks correct, and either auto-applies (if configured) or returns the plan to a human for approval.
5. If approved, agent calls `terraform_apply` → infrastructure is provisioned.
6. Agent calls `terraform_output` → reads the endpoint URLs, IDs, etc. → returns a summary to the user.

Total human interaction: write the request, optionally approve the plan.

## Design considerations for enterprise deployments

- **State backend**: Terraform Cloud or HCP Terraform is strongly recommended for state locking, audit logs, and team access controls when an agent is making changes.
- **Approval gates**: Configure agents to stop before `apply` and surface the plan to a human channel (Slack, ServiceNow, email) for approval.
- **Workspace scoping**: Restrict agent access to specific workspaces to limit blast radius.
- **Variable hygiene**: Sensitive variables (credentials, secrets) should be stored in Vault or HCP Vault Secrets — never passed through the agent's context window.

---

**Next: [05 — Use Cases & Objections](./05-use-cases-and-objections.md)**  
**Back: [03 — Agentic AI Concepts](./03-agentic-ai-concepts.md)**
