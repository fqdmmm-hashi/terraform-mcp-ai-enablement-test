# SDD, orchestrators, and subagents

Spec-Driven Development (SDD) is a four-phase pipeline that produces Terraform artifacts through specialized AI subagents coordinated by an orchestrator. Each phase is owned by a specialist with a clean context window and a scoped job. Phase outputs are files on disk; downstream phases read those files directly.

## The four phases

| Phase | Owner | Output | Gate |
|-------|-------|--------|------|
| 1. Clarify | Orchestrator + research subagents | `specs/{feature}/research-*.md` | All research files exist; no `[NEEDS CLARIFICATION]` markers |
| 2. Design | Design subagent | `specs/{feature}/design.md` | Human approval; no unresolved CRITICAL findings |
| 3. Build | Developer subagent (TDD) | Tests then code, in module root and `tests/` | `terraform validate` passes; all checklist items complete |
| 4. Validate | Validator subagent | Validation report with 6-dimension score | Composite ≥ 7.0; Security & Compliance ≥ 5.0; PR created |

Phases run strictly in sequence. File-existence checks between phases are enforced by the orchestrator skill files (`tf-module-plan`, `tf-module-implement`, and the provider and consumer equivalents).

The design document produced in phase 2 is the single source of truth for everything downstream. There is no separate spec, plan, contract, or task file. See [Constitutions, templates, and the human gate](03-constitutions-templates-human-gate.md) for how the design template structures this document and how the human gate enforces review.

## Orchestrators

An orchestrator is a skill — a markdown file under `.claude/skills/<workflow>-plan/SKILL.md` or `<workflow>-implement/SKILL.md`. It runs in the foreground context when a slash command is invoked. Six entry points exist:

| Command | Workflow | Phases |
|---------|----------|--------|
| `/tf-module-plan` | Module | 1–2 |
| `/tf-module-implement` | Module | 3–4 |
| `/tf-provider-plan` | Provider | 1–2 |
| `/tf-provider-implement` | Provider | 3–4 |
| `/tf-consumer-plan` | Consumer | 1–2 |
| `/tf-consumer-implement` | Consumer | 3–4 |

For details on what each workflow produces and when to use which command, see [The three workflows](05-three-workflows.md).

Orchestrator responsibilities:

1. Manage the feature branch and tracking issue.
2. Dispatch subagents in order with the correct inputs.
3. Verify subagent outputs via Glob, not by reading contents.
4. Stop at the [human gate](03-constitutions-templates-human-gate.md#the-human-gate) between phase 2 and phase 3.
5. Trigger the [refinement loop](04-validation-quality-scoring.md#refinement-loop) on validation failure.

Orchestrators do not write code and do not read research documents into their own context. See [Context, MCP, and progressive disclosure](02-context-mcp-progressive-disclosure.md) for why this separation matters.

## Subagents

Subagents are specialized agents defined in `.claude/agents/`. Each has a scoped role, an allow-list of tools, and a prompt. The orchestrator dispatches them via the Task tool; they run in isolated context windows.

### Researcher

Reads documentation and writes findings to disk. Has read access to [MCP documentation servers](02-context-mcp-progressive-disclosure.md#mcp-servers) and the file system; no write access to module code. Outputs a research document only.

The orchestrator typically dispatches 3–4 researchers in parallel and waits for all to complete before dispatching the designer.

Files: `.claude/agents/tf-module-research.md`, `tf-provider-research.md`, `tf-consumer-research.md`.

### Designer

Reads the research files, the relevant [constitution](03-constitutions-templates-human-gate.md#constitutions) from `.foundations/memory/`, and the [design template](03-constitutions-templates-human-gate.md#design-templates) from `.foundations/templates/`. Produces `design.md` populated with concrete, justified decisions. Flags unresolved items explicitly. Does not write code.

Files: `.claude/agents/tf-module-design.md`, `tf-provider-design.md`, `tf-consumer-design.md`.

### Developer

Reads the approved `design.md` and implements it. Test files first, then resource code, one checklist item at a time, with checkpoint commits between items. Has write access to the module directory and a scoped tool set (`terraform fmt`, `terraform validate`, git, file editing). No access to research documents — research is distilled into the design by the time the developer runs.

Files: `.claude/agents/tf-module-developer.md`, `tf-provider-developer.md`, `tf-consumer-developer.md`. Test-writer variants exist for module and provider workflows (`tf-module-test-writer.md`, `tf-provider-test-writer.md`).

### Validator

Runs the [validation toolchain](04-validation-quality-scoring.md#validation-toolchain), scores output against the constitution and design, and writes a structured report. Read access to the generated code and constitution; no write access to either. Can trigger the refinement loop but cannot modify the code it evaluates.

Files: `.claude/agents/tf-module-validator.md`, `tf-provider-validator.md`, `tf-consumer-validator.md`. Scoring rubric: `.claude/skills/tf-judge-criteria/SKILL.md`.

## Concurrency patterns

**Fan-out / fan-in.** Used in the research phase. Multiple researchers dispatched concurrently, each on a different topic in its own context window. Orchestrator waits for all to complete before dispatching the designer.

**Pipeline.** Used between phases. Clarify → Design → human gate → Build → Validate runs strictly sequentially. Each phase completes before the next begins.

## File-based handoffs

Subagents do not pass context through conversation history. They write artifacts to disk, and downstream subagents read those artifacts directly.

This is enforced by the orchestrator. On subagent completion, the orchestrator calls Glob to verify the expected file exists on disk, then dispatches the next subagent with a file path argument. The next subagent opens the file itself. The orchestrator never calls `TaskOutput` to read a subagent's output into its own context.

Two reasons:

- **Context hygiene.** The orchestrator's [context window](02-context-mcp-progressive-disclosure.md#the-binding-constraint) stays small and stable across long workflows.
- **Auditability.** Every artifact exists as a real file on a real branch with checkpoint commits.

## Reading order in the repository

1. `AGENTS.md` — top-level rules and the Context Management section.
2. `.claude/skills/tf-module-plan/SKILL.md` and `.claude/skills/tf-module-implement/SKILL.md`.
3. `.claude/agents/tf-module-design.md`.
4. `.foundations/memory/module-constitution.md`.
5. `.foundations/templates/module-design-template.md`.

Continue to [Context, MCP, and progressive disclosure](02-context-mcp-progressive-disclosure.md).
