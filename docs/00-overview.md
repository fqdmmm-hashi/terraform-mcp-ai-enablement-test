# Overview

Terraform Agentic Workflows is a template repository that drives AI coding agents through a fixed, four-phase pipeline for producing production-grade Terraform. The pipeline is called Spec-Driven Development (SDD). It is invoked from GitHub Copilot CLI using slash commands and produces modules, providers, or consumer compositions as pull requests.

The template enforces guardrails through [constitutions](03-constitutions-templates-human-gate.md#constitutions), [design templates](03-constitutions-templates-human-gate.md#design-templates), scoped [MCP tool access](02-context-mcp-progressive-disclosure.md#mcp-servers), and a [quality score](04-validation-quality-scoring.md#six-dimension-quality-score) that must clear a fixed threshold before a pull request is created.

> **Supported AI assistant:** GitHub Copilot. Use the `vscode-agent` devcontainer variant. Other assistants are not currently recommended.

## Scope

These docs cover the pipeline architecture, the three supported [workflows](05-three-workflows.md), the governance artifacts, and the [Day 2 consumer uplift pipeline](06-day-2-consumer-uplift.md). They assume working knowledge of Terraform, HCL, and cloud IAM. They do not assume prior experience with agentic coding workflows.

Agentic infrastructure development presumes mature IaC practice. A [private module registry](05-three-workflows.md#the-private-module-registry), server-side branch protection, dynamic provider credentials, and policy-as-code in HCP Terraform are prerequisites — the pipeline enforces them but does not create them.

## Document index

| # | Document | Purpose |
|---|----------|---------|
| 01 | [SDD, orchestrators, subagents](01-sdd-orchestrators-subagents.md) | Pipeline structure, four phases, agent roles, file-based handoffs |
| 02 | [Context, MCP, progressive disclosure](02-context-mcp-progressive-disclosure.md) | Context-window architecture, MCP servers, on-demand loading |
| 03 | [Constitutions, templates, human gate](03-constitutions-templates-human-gate.md) | Governance-as-code, six security domains, design templates, steering the agent |
| 04 | [Validation and quality scoring](04-validation-quality-scoring.md) | Toolchain, 6-dimension rubric, refinement loop, reading reports |
| 05 | [The three workflows](05-three-workflows.md) | Module, provider, consumer reference, PMR, workflow selection |
| 06 | [Day 2: consumer module uplift](06-day-2-consumer-uplift.md) | Dependabot-driven upgrade pipeline, risk matrix, agent remediation |
