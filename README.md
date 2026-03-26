# Terraform + AI: MCP & Agentic Pipelines

> **Internal enablement resource for HashiCorp Technical Sales.**  
> Everything you need to understand, demo, and confidently sell Terraform's AI integrations.

---

## Choose your learning path

Not everyone learns the same way. Pick the path that fits your style and time.

| Path | Format | Time | Best for |
|------|--------|------|----------|
| 🎮 **[Guided — Instruqt tracks](#instruqt-tracks)** | Browser-based, interactive | 1–2 hrs | Onboarding, certification prep |
| 📖 **[Read the docs](#documentation)** | Written, self-paced | Your pace | Deep reference, pre-call prep |
| ⚡ **[MCP server demo](#local-demos)** | Locally executable | ~20 min setup | Live customer demos |
| 🤖 **[Agentic pipeline demo](#local-demos)** | Locally executable | ~20 min setup | Live customer demos |

---

## Instruqt Tracks

These tracks mirror the documentation below but are fully **trackable by your manager**, include **knowledge checks** after each section, and require **no local setup** — just a browser.

### Track 1 — Terraform MCP Server
> *~45 minutes · 4 challenges · quiz at end of each section*

Covers how Terraform exposes infrastructure operations through the Model Context Protocol, enabling AI models to plan, apply, and manage infrastructure through natural language.

🔗 **[Open Track in Instruqt →](https://instruqt.com/placeholder-track-1)**

### Track 2 — Terraform Agentic AI Pipeline
> *~60 minutes · 5 challenges · quiz at end of each section*

Walks through building and running an agentic AI pipeline where Terraform acts as the action layer for autonomous infrastructure decisions.

🔗 **[Open Track in Instruqt →](https://instruqt.com/placeholder-track-2)**

---

## Documentation

Full written documentation lives in the [`/docs`](./docs) folder. Read in order or jump to what you need.

| # | Document | What you'll learn |
|---|----------|-------------------|
| 00 | [Overview](./docs/00-overview.md) | What this repo covers and how to use it |
| 01 | [What is MCP?](./docs/01-what-is-mcp.md) | Model Context Protocol explained for a technical audience |
| 02 | [Terraform MCP Server](./docs/02-terraform-mcp-server.md) | How Terraform implements MCP and what it exposes |
| 03 | [Agentic AI Concepts](./docs/03-agentic-ai-concepts.md) | Agents, tools, and reasoning loops — the mental model |
| 04 | [Agentic Pipeline Architecture](./docs/04-agentic-pipeline-architecture.md) | How the full pipeline fits together with Terraform |
| 05 | [Use Cases & Objections](./docs/05-use-cases-and-objections.md) | Customer scenarios, value props, and objection handling |

---

## Local Demos

Two self-contained, locally executable demos built for **live customer conversations**. Each has its own setup guide, a single script to run, and a walkthrough of what to say at each step.

### ⚡ terraform-mcp-server

Spin up the Terraform MCP server locally and connect it to an AI client. Shows customers exactly how natural language maps to Terraform operations in real time.

```
terraform-mcp-server/
├── README.md      ← start here
├── setup.md       ← prerequisites and install steps
└── demo.sh        ← the demo script
```

📂 **[Go to demo →](./terraform-mcp-server/README.md)**

---

### 🤖 terraform-agentic-ai-pipeline

Run a complete agentic pipeline — from a natural language infrastructure request to a provisioned environment — entirely on your laptop.

```
terraform-agentic-ai-pipeline/
├── README.md      ← start here
├── setup.md       ← prerequisites and install steps
└── demo.sh        ← the demo script
```

📂 **[Go to demo →](./terraform-agentic-ai-pipeline/README.md)**

---

## Questions or contributions?

Open an issue or reach out in **#se-enablement** on Slack.
