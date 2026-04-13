# Context, MCP, and progressive disclosure

The pipeline's architecture is shaped by a single constraint: the model's context window is finite, and agent output quality degrades as the window fills.

## The binding constraint

A context window is the total token budget a model processes at once. Every token counts: system prompt, conversation history, loaded files, tool definitions, tool results, and the model's own reasoning.

Two failure modes emerge as the window fills:

- **Reasoning collapse.** Past roughly 80–90% capacity, output quality drops sharply. [Constitutional rules](03-constitutions-templates-human-gate.md#constitutions) are skipped, checklist items are dropped, earlier decisions are forgotten.
- **Compaction and the treadmill effect.** Near the limit, older content is dropped or summarized. Information authoritative at turn 3 is paraphrased or gone by turn 30.

A naive workflow that preloads a constitution, a dozen skills, several research documents, templates, and prior examples will cross 70% before the agent writes any code. Mid-build, the model forgets that encryption-by-default was required and produces an unencrypted resource.

This is the most common failure mode in agentic coding — context bloat, not model quality.

## Strategy 1 — context isolation

Split the work across [subagents](01-sdd-orchestrators-subagents.md#subagents), each running in its own isolated context window. Each window receives only the inputs that subagent needs.

| Subagent | Typical window use |
|----------|-------------------|
| Orchestrator | 5–10% |
| Researcher | 25–35% |
| Designer | 40–50% |
| Developer | ≤ 50% (grows per checklist item) |
| Validator | 35–45% |

Handoffs go through disk via [file-based handoffs](01-sdd-orchestrators-subagents.md#file-based-handoffs). When a researcher finishes, it writes `research-aws-docs.md`. The orchestrator verifies the file via Glob and dispatches the designer with a path argument. The designer reads the file into its own clean window.

`AGENTS.md` is explicit: never call `TaskOutput` to read subagent results into the orchestrator. Every such read is a permanent draw against the orchestrator's context budget.

## Strategy 2 — progressive disclosure

Even within a single window, content loads on demand rather than up front. A research subagent does not preload every AWS doc; it queries an MCP server for specific pages as it needs them and loads only those pages into its window.

Progressive disclosure combined with context isolation keeps every window lean for the entire workflow.

## MCP servers

The Model Context Protocol (MCP) is an open standard for AI agents to communicate with external tools and information sources. An MCP server wraps a tool — documentation, registry, API — and exposes its capabilities in a structured form the model can call.

The template ships with two MCP servers, declared in `devcontainer.json` under `customizations.vscode.mcp` for the `vscode-agent` variant:

| Server | Purpose |
|--------|---------|
| `terraform` | HCP Terraform workspace management, run execution, public and private registry lookups, variable management |
| `aws-documentation-mcp-server` | AWS service documentation search, page retrieval, regional availability |

The `terraform` MCP server is how the [consumer workflow's](05-three-workflows.md#consumer-workflow) researcher discovers modules available in the private registry and fetches their interfaces. The `aws-documentation-mcp-server` is how a [module workflow](05-three-workflows.md#module-workflow) researcher retrieves current documentation for resources like `aws_s3_bucket_server_side_encryption_configuration`.

MCP tools are scoped per subagent. Researchers get documentation tools. Designers do not. Developers get file editing, `terraform fmt`, `terraform validate`, and git. Scopes are declared in each agent definition under `.claude/agents/`.

## End-to-end window usage

1. Orchestrator starts at 5–10% with the workflow skill loaded.
2. Researchers A–D dispatch in parallel, each starting at 8–12%, peaking at 25–35% after MCP lookups.
3. Each researcher writes to disk and exits. Orchestrator context is unchanged.
4. Designer starts fresh, reads the research files and [constitution](03-constitutions-templates-human-gate.md#constitutions), writes `design.md`. Peaks at 40–50%.
5. [Human gate](03-constitutions-templates-human-gate.md#the-human-gate). No agent context involved.
6. Developer dispatched with the design path. Reads the design, looks up provider attributes via MCP as needed, writes tests and code one checklist item at a time. Rarely exceeds 50%.
7. Validator reads the generated code and constitution, runs the [toolchain](04-validation-quality-scoring.md#validation-toolchain), writes a report. Peaks at 35–45%.

No single window crosses 60%. A single-agent attempt at the same workflow would be at 95% by the end of research and would produce degraded output thereafter.

## Rules for extension

- Never inline subagent outputs into the orchestrator's context. Verify with Glob and dispatch with a path.
- Scope MCP tools per subagent. Researchers read; developers edit.
- Prefer multiple narrow subagents over one wide one.
- Persist cross-phase state in the design document or constitution, never in conversation history.
- If a subagent regularly crosses 60% of its window, split its job.

Continue to [Constitutions, templates, and the human gate](03-constitutions-templates-human-gate.md).
