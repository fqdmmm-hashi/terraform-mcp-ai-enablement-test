# Validation and quality scoring

Validation is phase 4 of the [SDD pipeline](01-sdd-orchestrators-subagents.md#the-four-phases). It combines a fixed toolchain with a six-dimension quality rubric. A module ships when the toolchain passes, the composite score clears 7.0, and Security & Compliance clears 5.0.

## Test-driven build

Every workflow that generates code writes tests before resource code. The [module constitution](03-constitutions-templates-human-gate.md#constitutions) section 1.3 states: *"Test files (`.tftest.hcl`) MUST be written before the module code they validate."*

The [developer subagent](01-sdd-orchestrators-subagents.md#developer) reads test scenarios from section 5 of `design.md`, writes a test file per scenario group, then implements resources. Checkpoint commits via `.foundations/scripts/bash/checkpoint-commit.sh` capture each checklist item.

### Module test categories

Constitution section 5.1 defines three categories:

| Category | Provider | Command | Credentials |
|----------|----------|---------|:-----------:|
| Unit | `mock_provider` | `terraform test` (plan) | No |
| Acceptance | Real | `terraform test` (plan) | Yes |
| Integration | Real | `terraform test` (apply) | Yes |

Unit tests must cover secure defaults, full-feature coverage, feature toggle combinations, and validation errors with `expect_failures`. Boundary-pass cases live in `unit_validation.tftest.hcl` alongside failure cases.

Acceptance and integration tests run against a sandbox HCP Terraform workspace with the naming pattern `sandbox_<module>_<example>`. Ephemeral workspaces must be deleted after testing.

### Provider and consumer workflows

**Provider** — Tests use Go acceptance tests with `TF_ACC=1`, not `.tftest.hcl`. Test stubs are written and must compile before CRUD implementation begins. See `.foundations/memory/provider-constitution.md` section 1.3 and [Provider workflow](05-three-workflows.md#provider-workflow).

**Consumer** — No `.tftest.hcl` files. Validation uses `terraform validate`, sandbox plan/apply, and clean destroy. See `.foundations/memory/consumer-constitution.md` section 5.1 and [Consumer workflow](05-three-workflows.md#consumer-workflow).

## Validation toolchain

The [validator subagent](01-sdd-orchestrators-subagents.md#validator) runs the same toolchain on every workflow output:

| Check | Tool | Blocks |
|-------|------|:------:|
| Formatting | `terraform fmt -check` | Yes |
| Syntax | `terraform validate` | Yes |
| Tests | `terraform test` (or `go test` for providers) | Yes |
| Linting | `tflint` with `.tflint.hcl` rules | Yes |
| Security scan | `trivy config .` — no Critical or High findings | Yes |
| Documentation | `terraform-docs` — README is current | Yes |

Pre-commit hooks enforce most of these locally. `.pre-commit-config.yaml` configures `terraform_fmt`, `terraform_validate`, `terraform_docs`, `terraform_tflint`, `terraform_trivy`, end-of-file and YAML checks, large-file rejection, merge-conflict detection, private-key detection, and `vault-radar-scan`. The `no-commit-to-branch` hook provides local protection for `main`.

### tflint plugins

- **AWS 0.46.0** — All auto-enabled resource validations, plus `aws_resource_missing_tags`.
- **Azure 0.31.1** — All auto-enabled validations.
- **Terraform built-in** — All 20 rules explicitly configured (19 enabled, 1 disabled). See `.tflint.hcl`.

### trivy

`trivy config` scans for misconfigurations: missing encryption, overly permissive IAM, public access, exposed credentials. Threshold is no Critical and no High. Medium findings appear in the report but do not block.

### terraform-docs

`terraform-docs` regenerates the README from variables, outputs, and resources. Divergence between the committed README and the generated output fails the check. The pre-commit hook normally rewrites the README automatically.

## Six-dimension quality score

A passing toolchain is necessary but not sufficient. The validator also produces a weighted quality score from `.claude/skills/tf-judge-criteria/SKILL.md`. The six dimensions sum to 100%, each scored 1–10, composite threshold **7.0**.

### Module workflow

| # | Dimension | Weight | Evaluates |
|---|-----------|:-----:|-----------|
| 1 | Resource Design | 25% | Raw resources with secure defaults, conditional creation, dependencies |
| 2 | Security & Compliance | 30% | Encryption, IAM least privilege, no credentials, audit logs |
| 3 | Code Quality | 15% | Formatting, naming, validation, DRY, file organization |
| 4 | Variables & Outputs | 10% | Type constraints, validation rules, secure defaults, descriptions |
| 5 | Testing | 10% | `.tftest.hcl` coverage, mock providers, assertion quality |
| 6 | Constitution Alignment | 10% | Matches `design.md` and [constitution](03-constitutions-templates-human-gate.md#constitutions) `MUST` rules |

Composite: `(D1 × 0.25) + (D2 × 0.30) + (D3 × 0.15) + (D4 × 0.10) + (D5 × 0.10) + (D6 × 0.10)`

### Consumer workflow

Dimension 1 is "Module Usage" (25%), dimension 5 is "Wiring & Integration" (10%). Weights and formula identical. See [Consumer workflow](05-three-workflows.md#consumer-workflow).

### Provider workflow

Dimension 1 is "Schema Design" (25%), dimension 4 is "CRUD Operations" (10%), dimension 5 is acceptance test coverage. Full rubric in `tf-judge-criteria/SKILL.md`. See [Provider workflow](05-three-workflows.md#provider-workflow).

## Production-readiness scale

| Score | Level | Action |
|-------|-------|--------|
| 9.0–10.0 | Exceptional | Use as reference |
| 8.0–8.9 | Excellent | Optional refinement |
| 7.0–7.9 | Good | Address high-priority issues |
| 6.0–6.9 | Adequate | Fix critical issues before production |
| 5.0–5.9 | Below standard | Rework required |
| 4.0–4.9 | Poor | Substantial redesign needed |
| 1.0–3.9 | Unacceptable | Complete rework |

## Security override

If Security & Compliance (D2) scores below 5.0, the module is forced to "Not Production Ready" regardless of composite score. A composite of 8.5 with D2 at 4.9 still fails. This is tied to the [six security domains](03-constitutions-templates-human-gate.md#six-security-domains) enforced by the constitutions.

## Severity classification

Individual findings map to [RFC 2119 keywords](03-constitutions-templates-human-gate.md#constitutions) from the constitution:

| Severity | Source | Examples |
|----------|--------|----------|
| CRITICAL (P0) | Constitution `MUST` violations | Hardcoded credentials, public databases, missing encryption |
| HIGH (P1) | Constitution `SHOULD` violations | Overly permissive IAM, missing audit logging |
| MEDIUM (P2) | Code quality | Formatting, incomplete tests, missing validation coverage |
| LOW (P3) | Style, docs, refactoring | — |

Every finding in the report includes evidence (file path, line number, code quote) and a remediation block with before/after. The `tf-judge-criteria` skill rejects findings without both.

## Refinement loop

Scores below 7.0 trigger a refinement round:

1. Validator categorizes findings as auto-fixable or requires-rework.
2. Auto-fixable findings (formatting, descriptions, simple lint failures, missing tags) are fixed in place.
3. Validation re-runs.
4. If composite clears 7.0, proceed to PR creation.
5. Otherwise, run another round.

**Maximum three rounds.** After three failed refinements, the validator escalates via the tracking issue with a structured failure report. A human either fixes the issues, returns the workflow to design via the [human gate](03-constitutions-templates-human-gate.md#the-human-gate), or reverts the branch.

The cap exists because refinement-resistant failures usually indicate a broken design rather than broken code.

## Reading a validation report

The report template is at `.claude/skills/tf-report-template/template/tf-module-template.md`. It contains:

- **Summary** — composite score, per-dimension scores, readiness verdict.
- **Per-dimension findings** — tagged by severity, with evidence and remediation.
- **Toolchain output** — full results from each tool.
- **Refinement history** — auto-fixes applied, by round.

For passing PRs, scan the dimension breakdown. A module with one dimension at 9.5 and another at 6.2 is uneven even though the composite passed; review the weak dimension's findings.

For failing PRs, start at the security findings regardless of which dimension failed. Refinement-resistant failures typically trace to a security control the design underspecified.

Continue to [The three workflows](05-three-workflows.md).
