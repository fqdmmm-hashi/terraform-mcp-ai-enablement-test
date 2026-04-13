# Day 2: consumer module uplift

The consumer module uplift pipeline handles module version upgrades automatically. It combines Dependabot, a deterministic risk matrix, and an AI remediation agent to keep consumers current without requiring manual work on every version bump.

## Pipeline flow

1. Dependabot detects a new module version in the [Private Module Registry](05-three-workflows.md#the-private-module-registry).
2. Dependabot opens a PR with the version bump.
3. A classifier identifies the bump as patch, minor, or major.
4. The pipeline runs the full Terraform [validation chain](04-validation-quality-scoring.md#validation-toolchain) against the upgraded configuration.
5. A deterministic risk matrix scores the change. No AI is involved at this step.
6. The pipeline chooses one of four actions: auto-close, auto-merge, needs review, or breaking change.
7. Breaking changes invoke a remediation agent that patches the [consumer code](05-three-workflows.md#consumer-workflow) in place.
8. On merge, a post-merge workflow applies the change to the live workspace.
9. On apply failure, the workflow opens an incident issue and drafts a rollback PR.

## Configuration files

| File | Purpose |
|------|---------|
| `.github/dependabot.yml` | Monthly scan of the private Terraform registry |
| `.github/workflows/terraform-consumer-uplift.yml` | Classify → validate → risk → decision |
| `.github/workflows/terraform-apply.yml` | Post-merge apply |
| `.github/workflows/terraform-claude-review.yml` | Remediation trigger on `@claude` PR comments |
| `.claude/agents/module-upgrade-remediation.md` | Remediation agent prompt |
| `.foundations/scripts/bash/classify-version-bump.sh` | Semver classification |

Dependabot requires a separate token from the one in the devcontainer. Configure `TFE_TOKEN_DEPENDABOT` under **Repository Settings → Secrets and variables → Dependabot** with read-only access to the private module registry. Without it, Dependabot cannot see the registry and the pipeline never starts.

## Step-by-step

### 1. Detect

`.github/dependabot.yml` runs a monthly scan against the private registry. When Dependabot finds a module whose pinned version no longer matches the latest available, it opens a PR labeled for the uplift workflow.

### 2. Classify

`classify-version-bump.sh` parses the git diff to identify which modules changed and what kind of semver bump each represents.

### 3. Validate

The pipeline runs `terraform fmt -check`, `terraform init`, `terraform validate`, `tflint`, and `terraform plan` against the upgraded configuration. Plan output is captured for the risk assessment.

### 4. Risk matrix

The matrix is a deterministic lookup table. No AI involvement.

| Plan impact | Patch / Minor | Major |
|-------------|---------------|-------|
| No plan changes | Auto-merge | Auto-merge |
| Adds only | Needs review (low) | Needs review (medium) |
| Changes to existing | Needs review (medium) | Needs review (high) |
| Destroy / Replace | Breaking (high) | Breaking (critical) |
| Plan fails | Breaking (high) | Breaking (critical) |

### 5. Decision

| Verdict | Action |
|---------|--------|
| No plan changes | Auto-close the PR — nothing to ship |
| Auto-merge | Squash-merge; post-merge apply takes over |
| Needs review | Label and comment with plan diff and risk level; human decides |
| Breaking change | Block merge; post `@claude review and make a recommendation` as a PR comment to trigger remediation |

### 6. Agent remediation

When the matrix flags a breaking change or the plan fails, `terraform-claude-review.yml` invokes the `module-upgrade-remediation` agent. The agent performs four steps:

1. Fetch both module interfaces — old and new — from the private registry via the `terraform` [MCP server](02-context-mcp-progressive-disclosure.md#mcp-servers).
2. Diff the interfaces: missing inputs, removed outputs, type changes, renamed fields, added required arguments.
3. Patch the consumer code in place: add required inputs with sensible defaults, update output references, adjust type coercions.
4. Push the fix to the same PR branch. The pipeline re-runs validation automatically on the new commit.

The remediation agent is bounded to **one round per PR**. If one pass is insufficient, the PR stays in the breaking-change state and a human takes over.

> The pattern works with any coding agent that integrates with GitHub PRs. The template ships with an `@claude` trigger; you may need to swap the trigger and agent definition for your environment.

### 7. Post-merge apply

On merge to `main`, `terraform-apply.yml`:

1. Uploads the configuration to the HCP Terraform workspace.
2. Creates a run and applies it.
3. On success, comments on the merged PR with a link to the run.
4. On failure, opens an incident issue and generates a draft rollback PR.

The rollback PR is intentionally a draft. Rolling back live infrastructure requires human review of the failure mode.

## Why the matrix is deterministic

- **Auditability.** Every decision traces to a single matrix row. Regulator and security-review questions answer to a table, not to a model's inference.
- **Consistency.** The same upgrade produces the same verdict every time. Model drift does not affect policy.
- **Defensible separation.** Agents are a poor fit for strict policy enforcement under audit. The matrix is policy; the agent is tooling.

The agent enters only where policy says "this needs remediation by something that can read both module interfaces and diff them."

## Expected steady-state distribution

For a workload of several dozen modules and several dozen consumers:

- 80%+ of Dependabot PRs auto-close or auto-merge with no human involvement.
- 10–15% land in "needs review" — a human reads the plan diff and merges or rejects.
- A few percent are breaking changes. The remediation agent resolves most in one pass.
- Post-merge apply failures produce incident issues and draft rollbacks within minutes.

The pipeline does not make upgrades zero-cost. It makes them constant-cost regardless of consumer count.

## Extending the pipeline

Reference material for extending the template:

- `.claude/skills/` — skill definitions
- `.claude/agents/` — agent prompts
- `.foundations/memory/` — [constitutions](03-constitutions-templates-human-gate.md#constitutions)
- `.foundations/templates/` — [design templates](03-constitutions-templates-human-gate.md#design-templates)
- `reference/agent-authoring-guide.md`
- `reference/skill-authoring-guide.md`
