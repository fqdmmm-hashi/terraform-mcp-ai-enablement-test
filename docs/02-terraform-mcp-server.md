# 02 — Terraform MCP Server

## What it is

The **Terraform MCP Server** is an implementation of the Model Context Protocol that wraps Terraform's core operations and exposes them as callable tools for AI models. It is what allows an AI agent to plan, apply, inspect, and manage Terraform-controlled infrastructure through natural language.

## What the server exposes

The Terraform MCP Server exposes Terraform operations as discrete tools. An AI model connecting to this server can discover and call tools such as:

| Tool | What it does |
|------|--------------|
| `terraform_init` | Initializes a working directory |
| `terraform_plan` | Generates and shows an execution plan |
| `terraform_apply` | Applies changes to reach the desired state |
| `terraform_destroy` | Destroys previously created infrastructure |
| `terraform_output` | Reads output values from state |
| `terraform_state_list` | Lists resources in the current state |
| `terraform_validate` | Validates configuration files |

> **Note:** The exact set of tools may vary by version. The demo in this repo reflects the current supported toolset.

## The key capability shift

Without MCP, Terraform is operated by a human or a CI/CD pipeline running predefined scripts. The human decides what to run and when.

With MCP, an AI model can:

1. **Receive a natural language request** ("provision a dev environment in us-east-1 with a t3.medium EC2 instance")
2. **Translate that into Terraform operations** (init → plan → apply)
3. **Handle the results** — read outputs, check for errors, report back

The infrastructure intent is expressed in natural language. The execution is handled by Terraform. The MCP server is the bridge between them.

## Architecture diagram

```
┌─────────────────┐        MCP         ┌──────────────────────┐
│                 │ ──── tool calls ──▶ │                      │
│   AI Model /    │                     │  Terraform MCP       │
│   AI Client     │ ◀─── results ────── │  Server              │
│                 │                     │                      │
└─────────────────┘                     └──────────┬───────────┘
                                                   │
                                              Terraform CLI
                                                   │
                                         ┌─────────▼──────────┐
                                         │  Cloud Provider    │
                                         │  (AWS, Azure, GCP) │
                                         └────────────────────┘
```

## What to emphasize with customers

- **No rip-and-replace.** The Terraform MCP Server works with existing Terraform configurations. Customers don't rewrite their IaC — they add an AI interface on top of it.
- **Policy enforcement still applies.** Sentinel policies and OPA rules enforce guardrails regardless of whether the trigger was a human or an AI agent.
- **Auditability is unchanged.** Every operation still runs through Terraform's plan/apply cycle. The audit trail is the same.

---

**Next: [03 — Agentic AI Concepts](./03-agentic-ai-concepts.md)**  
**Back: [01 — What is MCP?](./01-what-is-mcp.md)**
