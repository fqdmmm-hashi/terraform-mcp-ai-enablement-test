# 01 — What is MCP?

## The short version

**Model Context Protocol (MCP)** is an open standard that defines how AI models communicate with external tools and systems. Think of it as a universal plug — instead of every AI application building its own custom integration with every tool, MCP provides a shared language that any AI client can use to talk to any MCP-compatible server.

## The problem MCP solves

Before MCP, connecting an AI model to an external tool (a database, a cloud API, an infrastructure platform) required custom integration work on both sides. Every connection was bespoke. This created:

- **Fragmentation** — every AI vendor integrated with tools differently.
- **Duplication** — tool vendors had to build and maintain separate integrations for every AI platform.
- **Limited reuse** — a great integration built for one AI assistant couldn't be used by another.

MCP changes this by standardizing the interface. A tool that speaks MCP works with any AI client that speaks MCP.

## How MCP works (the mental model)

An MCP setup has two sides:

**MCP Server** — a process that wraps a tool or system and exposes its capabilities in a structured, standardized way. It advertises what it can do (its "tools") and accepts requests to use those tools.

**MCP Client** — an AI model or AI-powered application that connects to one or more MCP servers, discovers their tools, and calls them as part of its reasoning process.

When an AI model needs to take an action — say, run a Terraform plan — it sends a structured request to the MCP server. The server executes the operation and returns the result. The AI uses that result to decide what to do next.

## Why this matters for Terraform

Terraform is fundamentally an action system — it reads state, compares desired state to actual state, and makes changes. That is exactly the kind of capability an AI agent needs to manage infrastructure autonomously.

By implementing MCP, Terraform becomes something an AI model can *call* — not just something a human runs from a terminal. The implications for infrastructure automation, AI-assisted operations, and agentic workflows are significant.

## Key terms to know

| Term | What it means |
|------|---------------|
| **MCP** | Model Context Protocol — the open standard |
| **MCP Server** | The process that wraps a tool and speaks MCP |
| **MCP Client** | The AI or application that connects to MCP servers |
| **Tool** | A discrete capability exposed by an MCP server (e.g., `terraform_plan`, `terraform_apply`) |
| **Tool call** | When an AI model invokes a tool through MCP |

---

**Next: [02 — Terraform MCP Server](./02-terraform-mcp-server.md)**  
**Back: [00 — Overview](./00-overview.md)**
