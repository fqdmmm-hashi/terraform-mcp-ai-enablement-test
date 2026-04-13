# Terraform + AI: MCP & Agentic Pipelines

> **Internal enablement resource for HashiCorp Technical Sales.**  
> Everything you need to understand, demo, and confidently sell Terraform's AI integrations.

---

## Choose your learning path

Not everyone learns the same way. Pick the path that fits your style and time.

| Path | Format | Time | Best for |
|------|--------|------|----------|
| 🎮 **[Guided — Instruqt tracks](#instruqt-tracks)** | Browser-based, interactive | 1–2 hrs | Onboarding, concept enablement |
| 📖 **[Read the docs](#documentation)** | Written, self-paced | ~45 min | Deep reference, pre-call prep |
| ⚡ **[MCP server demo](#demos)** | Locally executable | > 10 min setup | Live customer demos |
| 🤖 **[Terraform agentic pipeline demo](#demos)** | Locally executable | ~10-30 min setup | Hands-on learning, High concept demonstrations |

---

## Instruqt Tracks

These tracks mirror the documentation below but fully interactive and include **knowledge checks**. **No local setup required** — just a browser.

### Track 1 — Terraform MCP Server
> *~45 minutes · 8 challenges · quiz questions*

Covers how Terraform exposes infrastructure operations through the Model Context Protocol, enabling AI models to plan, apply, and manage infrastructure through natural language.

🔗 **[Open Track in Instruqt →](https://instruqt.com/placeholder-track-1)**

### Track 2 — Terraform Agentic AI Pipeline
> *~45 minutes · 8 challenges · quiz questions*

Walks through building and running an agentic AI pipeline where Terraform acts as the action layer for autonomous infrastructure decisions.

🔗 **[Open Track in Instruqt →](https://instruqt.com/placeholder-track-2)**

---

## Architecture Guide

Conceptual documentation for Terraform Agentic Workflows lives in the [`/docs`](./docs) folder. Read in order or jump to what you need.

| # | Document | What you'll learn |
|---|----------|-------------------|
| 00 | [Overview](./docs/00-overview.md) | Scope, document index, prerequisites |
| 01 | [SDD, Orchestrators, Subagents](./docs/01-sdd-orchestrators-subagents.md) | Four-phase pipeline, agent roles, file-based handoffs |
| 02 | [Context, MCP, Progressive Disclosure](./docs/02-context-mcp-progressive-disclosure.md) | Context-window architecture and on-demand loading |
| 03 | [Constitutions, Templates, Human Gate](./docs/03-constitutions-templates-human-gate.md) | Governance-as-code, security domains, design templates |
| 04 | [Validation & Quality Scoring](./docs/04-validation-quality-scoring.md) | Toolchain, 6-dimension rubric, refinement loop |
| 05 | [The Three Workflows](./docs/05-three-workflows.md) | Module, provider, consumer — PMR and workflow selection |
| 06 | [Day 2: Consumer Module Uplift](./docs/06-day-2-consumer-uplift.md) | Dependabot pipeline, risk matrix, agent remediation |

---

## Demos

Demos built for **conceptual enablement** and bleeding edge customer demos. Each has its own demo script and setup instructions.

### ⚡ terraform-mcp-server

Spin up the Terraform MCP server locally and connect it to an AI client. Shows customers exactly how natural language maps to Terraform operations in real time.

🔗 **[Go to demo → (DDR hosted)](https://github.com/hashicorp/demo-terraform-terraform-mcp-server)**

---

### 🤖 terraform-agentic-ai-pipeline

Run a complete agentic pipeline — from a natural language infrastructure request to a provisioned environment — entirely on your laptop.

#### before the demo

Complete all steps in the [Getting Started guide](./terraform-agentic-ai-pipeline/terraform-agentic-workflows/docs/getting_started.md) up to (but not including) the **First Run** section before running this demo.

#### guided demo scripts

This framework can be a self-guided or CDL guided experience. You can choose to pull down the repository and start with some of the guidance that Advanced SA has put together. You can also utilize the CDL DDR approved guide experience, which is ideal for bleeding edge customer demonstrations.

> [!IMPORTANT]
> LLM and AI based tools often vary in experience. While we can provide some guidance, CDL and Advanced SA cannot guarantee a fully deterministic
> experience at this time. Each guide provides a high-level flow of what to expect; however, it is not recommended to demo in front of
> customers without full knowledge of the workflow and framework. Please make educated decisions around customer appropriate demonstrations.

📂 **[Go to Advanced SA framework walkthroughs (Expert) →](./terraform-agentic-ai-pipeline/terraform-agentic-workflows/specs/feat-consumer-uplift/demo/README.md)**
📂 **[Go to CDL guided demo script: Module workflow (Introductory) →](./terraform-agentic-ai-pipeline/module-script.md)**
📂 **[Go to CDL guided demo script: Consumer workflow (Introductory) →](./terraform-agentic-ai-pipeline/consumer-script.md)**

---

## If something goes wrong

| Problem | Quick fix |
|---------|-----------|
| Agent hangs at reasoning step | Ctrl+C and restart; check AI client API key |
| MCP server connection refused | Restart MCP server, verify port in client config |
| Terraform apply fails | Check credentials; switch to local null_resource backend for demo |
| Agent takes unexpected actions | Review agent system prompt in `pipeline-config.yaml` |

---

## Related resources

- [Full documentation: Agentic Pipeline Architecture](../docs/04-agentic-pipeline-architecture.md)
- [Instruqt track: Terraform Agentic AI Pipeline](https://instruqt.com/placeholder-track-2)
- [Use cases and objections](../docs/05-use-cases-and-objections.md)
- [Setup guide](./setup.md)

---

## Questions or contributions?

Open an issue or reach out in **#se-enablement** on Slack.
