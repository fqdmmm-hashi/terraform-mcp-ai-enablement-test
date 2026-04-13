# Constitutions, templates, and the human gate

Constitutions define what the agents must enforce. Design templates define how plans are expressed. The human gate is where humans intervene in the workflow. Together they are the governance layer that sits on top of the [SDD pipeline](01-sdd-orchestrators-subagents.md).

## Constitutions

A constitution is a markdown file of non-negotiable rules for a class of work. Three are shipped with the template:

| Constitution | Path | Scope |
|--------------|------|-------|
| Module | `.foundations/memory/module-constitution.md` | Reusable Terraform modules |
| Provider | `.foundations/memory/provider-constitution.md` | Terraform Providers (Plugin Framework) |
| Consumer | `.foundations/memory/consumer-constitution.md` | Infrastructure composed from private registry modules |

Every relevant [subagent](01-sdd-orchestrators-subagents.md#subagents) reads its constitution before generating output. The designer reads it to constrain the design. The developer reads it to enforce it in code. The [validator](04-validation-quality-scoring.md) reads it to score against it.

Each constitution uses an 8-section layout: core principles, code standards, security and compliance, version and dependency management, testing and validation, change management, operational standards, governance.

Rules use RFC 2119 keywords:

| Keyword | Severity |
|---------|----------|
| `MUST` / `MUST NOT` | CRITICAL |
| `SHOULD` / `SHOULD NOT` | HIGH |
| `MAY` | Informational |

The [severity classification](04-validation-quality-scoring.md#severity-classification) maps these keywords directly to finding priority levels in validation reports.

### Representative rules

From `module-constitution.md`:

- Security-sensitive inputs MUST default to the secure option (`public_access = false`, `encryption_enabled = true`).
- Root modules MUST NOT contain `provider {}` blocks.
- Test files (`.tftest.hcl`) MUST be written before the module code they validate.
- Provider versions MUST use `>=` in modules (not `~>`).
- No single file MAY exceed 500 lines.

From `consumer-constitution.md`:

- ALL infrastructure MUST be provisioned via private registry modules: `source = "app.terraform.io/<org>/<name>/<provider>"`.
- Raw `resource` blocks are PROHIBITED except for glue resources (`random_id`, `random_string`, `null_resource`, `terraform_data`, `time_sleep`).

For how these rules differ across the three workflows, see [The three workflows](05-three-workflows.md).

## Six security domains

Every module must address six domains in its design. Section 4 of the design template enforces this. A `[NEEDS CLARIFICATION]` marker in any of the six cells blocks phase 2 completion.

| Domain | Baseline |
|--------|----------|
| Encryption at rest | Enabled by default, customer-managed keys preferred |
| Encryption in transit | TLS 1.2+ enforced via resource policy or platform default |
| Public access | Denied by default; S3 buckets set all four `block_public_access` flags |
| IAM least privilege | Specific ARNs and actions; wildcards require documented justification |
| Logging | CloudWatch logs, S3 access logs, flow logs, audit trails as the resource supports |
| Tagging | `tags` map accepted; merged with required defaults (`Name`, `ManagedBy = "terraform"`) |

If a domain does not apply (an IAM-only module has no encryption-at-rest concern), the design must state so explicitly.

The [Security & Compliance scoring dimension](04-validation-quality-scoring.md#security-override) carries a hard floor override — scoring below 5.0 forces "Not Production Ready" regardless of composite score.

## Design templates

Three design templates under `.foundations/templates/` mirror the constitutions:

- `module-design-template.md`
- `provider-design-template.md`
- `consumer-design-template.md`

The module template has seven mandatory sections:

1. **Purpose and Requirements**
2. **Resources and Architecture**
3. **Interface Contract** — variables and outputs with name, type, default, validation, description
4. **Security Controls** — all six domains
5. **Test Scenarios** — `.tftest.hcl` files and assertions, mapped to constitution section 5.1
6. **Implementation Checklist** — step-by-step build plan, consumed one item at a time with checkpoint commits
7. **Open Questions**

The template is the contract between [phases](01-sdd-orchestrators-subagents.md#the-four-phases). Section 6 is the task list. Section 3 is the interface contract. Section 5 is the test plan. Adding a separate spec, task, or contract document is prohibited by the constitution.

## The directive + constitution + template contract

- **Directive** — the request supplied at clarification time ("S3 bucket module with versioning, encryption, access logging").
- **Constitution** — the rules that must be satisfied.
- **Template** — the form the output must take.

The design subagent produces a `design.md` that conforms to all three.

## The human gate

The human gate sits between phase 2 and phase 3 of the [SDD pipeline](01-sdd-orchestrators-subagents.md#the-four-phases). It is the only required human intervention during a workflow.

On design completion, the [orchestrator](01-sdd-orchestrators-subagents.md#orchestrators) posts a progress update to the tracking issue and stops. It does not write code. It waits.

Review `specs/{feature}/design.md` against:

- **Interface decisions.** Variable names, defaults, validation rules. Easier to fix here than after code is written.
- **Security controls.** Section 4 must explicitly address all [six domains](#six-security-domains).
- **Test coverage.** Section 5 lists scenarios by name. Add edge cases the design missed.
- **`[NEEDS CLARIFICATION]` markers.** Resolve by editing the design or re-running clarification.
- **Open Questions (section 7).** Answer in the file.

Edit `design.md` directly. The developer has no other source of intent — it does not read conversation history, it does not query hidden orchestrator state, and it does not ask questions during phase 3.

Approve by commenting `approved` on the tracking issue and running the implement command. An autonomous mode exists for low-risk changes (constitution section 6.2) and is gated on the absence of CRITICAL security findings. Production work should use manual review.

## Other human interventions

- **Clarification.** Answer the orchestrator's questions concretely before research begins.
- **PR review.** [Validation](04-validation-quality-scoring.md) passing opens a pull request; the PR enters the standard code review process.
- **Day 2.** Dependabot-flagged consumer upgrades route to human decision points (see [Day 2: consumer module uplift](06-day-2-consumer-uplift.md)).

## Modifying constitutions

The constitutions ship as starting points and will need organizational adjustment.

- **Treat them like code.** Version-controlled, PR-reviewed, platform/security team-approved. The module constitution version (`5.0.0` in the template) is bumped on rule changes and is referenced in agent prompts.
- **Keep the structure.** The 8-section layout, RFC 2119 keywords, and table-driven security baselines enable [programmatic scoring](04-validation-quality-scoring.md#six-dimension-quality-score). Free-form prose rules are not enforced.
- **Add organizational tags.** Required tags like `Environment`, `CostCenter`, `Owner` go in section 3.3, backed by tflint rules.
- **Do not weaken secure defaults.** Fix the modules, not the constitution.

Continue to [Validation and quality scoring](04-validation-quality-scoring.md).
