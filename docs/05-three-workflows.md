# The three workflows

The same [SDD pipeline](01-sdd-orchestrators-subagents.md) drives three workflows: module, provider, and consumer. Each targets a different use case of the Terraform stack and produces a different artifact.

## The Private Module Registry

The PMR is the bridge between workflows. Module output flows in; consumer input flows out. Provider output extends what modules can build with.

When a module passes [validation](04-validation-quality-scoring.md), it receives a registry path (`app.terraform.io/<org>/<name>/<provider>`) and a semantic version. Consumers in the same organization discover it through the `terraform` [MCP server](02-context-mcp-progressive-disclosure.md#mcp-servers), pin to a version with `~> X.Y`, and compose it into deployments.

The PMR is a security boundary as much as a discovery layer. Every module in it has passed the same SDD pipeline, the same [constitution](03-constitutions-templates-human-gate.md#constitutions), the same validation, and the same [human gate](03-constitutions-templates-human-gate.md#the-human-gate). This is why the consumer constitution forbids raw resources — the composition model collapses if consumers mix PMR modules with ad-hoc resources.


## Selecting a workflow

| Task | Workflow |
|------|----------|
| Reusable component for other teams | Module |
| Wrap a custom API or add resource coverage | Provider |
| Deploy real infrastructure for an application | Consumer |

If a task crosses workflows — for example, deploying infrastructure that depends on a module not yet in the PMR — run them in sequence. Ship the module first, then the consumer. Do not combine workflows in a single feature branch.

## Module workflow

| | |
|---|---|
| Plan | `/tf-module-plan` |
| Implement | `/tf-module-implement` |
| Constitution | `.foundations/memory/module-constitution.md` |
| Design template | `.foundations/templates/module-design-template.md` |
| Produces | Publishable Terraform module, ready for the Private Module Registry |

Designed to create module for the Private Module Registry. Suitable for "Producer" types -- maintainers of the Terraform ecosystem. Research scans provider documentation, cloud service best practices, and prior art in the private registry. The designer specifies variables (types and validation), resources (secure defaults), outputs, and test scenarios across the five constitution categories (secure defaults, full features, feature interactions, validation errors, validation boundaries).

### File layout

```
/
├── main.tf               # Primary resource definitions
├── variables.tf          # Input variable declarations
├── outputs.tf            # Output value declarations
├── locals.tf             # Local value computations
├── versions.tf           # Terraform and provider version constraints
├── data.tf               # Data source definitions (if needed)
├── README.md             # Auto-generated via terraform-docs
├── CHANGELOG.md          # Version history
├── examples/
│   ├── basic/            # Minimal usage; provider config here
│   └── complete/         # All features enabled; provider config here
└── tests/                # .tftest.hcl files
```

### Distinguishing rules

- **No `provider {}` blocks in the root module.** Modules inherit providers from consumers. Provider configuration lives only in `examples/`.
- **Provider versions use `>=`, not `~>`.** Modules maximize compatibility with consumer constraints.
- **Tests precede code.** `.tftest.hcl` files are written before any resource code. See [Test-driven build](04-validation-quality-scoring.md#test-driven-build).
- **No file exceeds 500 lines.** Split monoliths into `data.tf`, `iam.tf`, `monitoring.tf`, etc.

### Versioning and release

Semantic versioning with a `v` prefix (`v1.0.0`). Releases require a passing CHANGELOG, deployable examples, and current `terraform-docs` output.

## Provider workflow

| | |
|---|---|
| Plan | `/tf-provider-plan` |
| Implement | `/tf-provider-implement` |
| Constitution | `.foundations/memory/provider-constitution.md` |
| Design template | `.foundations/templates/provider-design-template.md` |
| Produces | Terraform Provider (Go, Plugin Framework) with schema, CRUD, plan modifiers, validators, acceptance tests, sweep functions, documentation |

Designed to assist with Provider creation and publishing. Suitable for "Producer" types --  maintainers of the Terraform ecosystem or those looking to distribute its tools. The developer writes Go, not HCL. Tests are Go acceptance tests (`TF_ACC=1`). The [validation toolchain](04-validation-quality-scoring.md#validation-toolchain) swaps `terraform test` for `go test` and adds `golangci-lint`.

### Distinguishing rules

- **Plugin Framework only.** Resources implement `resource.Resource`. Schema uses `schema.StringAttribute`, `schema.Int64Attribute`, etc. State uses `types.*` values. SDKv2 is not permitted.
- **Plan modifiers are mandatory.** `RequiresReplace()` for ForceNew attributes, `UseStateForUnknown()` for computed attributes that should not show as drift.
- **Validators on every constrained user-facing attribute.**
- **Test stubs before implementation.** Stubs contain function signatures, config functions, and check functions with `t.Skip("not implemented")` bodies. `go test -c` must compile from the first checklist item onward.
- **No secrets in errors, diagnostics, or logs.** Sensitive attributes marked `Sensitive: true`.

### File layout

```
internal/service/<service>/
├── <resource_name>.go              # Resource (schema, CRUD, model)
├── <resource_name>_test.go         # Acceptance tests
├── find.go                         # findByID, findByName helpers
├── status.go                       # Status functions
├── wait.go                         # Waiter functions
├── exports_test.go
├── sweep_test.go                   # Sweep functions for test cleanup
└── service_package_gen.go          # Auto-generated registration

website/docs/r/
└── <service>_<resource_name>.html.markdown
```

### Scoring dimensions

Schema Design (25%), Security & Compliance (30%), Code Quality (15%), CRUD Operations (10%), Testing (10%), Constitution Alignment (10%). Same [7.0 threshold and security override](04-validation-quality-scoring.md#security-override) as the module workflow.

## Consumer workflow

| | |
|---|---|
| Plan | `/tf-consumer-plan` |
| Implement | `/tf-consumer-implement` |
| Constitution | `.foundations/memory/consumer-constitution.md` |
| Design template | `.foundations/templates/consumer-design-template.md` |
| Produces | Consumer Terraform configuration composing private registry modules, deployed to an HCP Terraform workspace |

Designed to wire pre-existing modules together to create cohesive infrastructure components. Suitable for "Consumer" types -- application developers, service maintainers, individuals with very little Terraform experience. The consumer does not write resources. It imports modules from the Private Module Registry and wires them together.

### The defining rule

> ALL infrastructure MUST be provisioned via private registry modules: `source = "app.terraform.io/<org>/<name>/<provider>"`. Raw `resource` blocks are PROHIBITED except for glue resources (`random_id`, `random_string`, `null_resource`, `terraform_data`, `time_sleep`).

Enforced at design time, build time, and validation time. A consumer importing a raw `aws_s3_bucket` fails validation regardless of the rest of the configuration.

### File layout

```
/
├── main.tf                          # Module calls and glue resources
├── variables.tf                     # Input variable declarations
├── outputs.tf                       # Output value declarations
├── locals.tf                        # Wiring and naming computations
├── versions.tf                      # Required versions
├── providers.tf                     # Provider config (region, default_tags, assume_role)
├── backend.tf                       # HCP Terraform cloud {} block
├── data.tf                          # Data sources (if needed)
├── README.md
└── terraform.auto.tfvars.example
```

### Distinguishing rules

- **`providers.tf` exists.** Consumers are where providers are configured.
- **`backend.tf` contains the `cloud {}` block.** Never a local backend.
- **Module versions use `~>`, not `>=`.** Consumers want pessimistic constraints.
- **`default_tags` required.** Keys: `ManagedBy = "terraform"`, `Environment`, `Project`, `Owner`.
- **Dynamic provider credentials.** Static AWS keys are prohibited. OIDC federation between the HCP Terraform workspace and the cloud account is required.

### Validation

No `.tftest.hcl` files. Validation runs `terraform fmt`, `validate`, `tflint`, `trivy`, and a sandbox deploy: real HCP Terraform plan and apply against `sandbox-{project}-{feature}`, followed by clean destroy. Deploy failures block promotion.

### Scoring dimensions

Module Usage (25%) replaces Resource Design. Wiring & Integration (10%) replaces Testing. Same [7.0 threshold and security override](04-validation-quality-scoring.md#security-override).

## Side-by-side comparison

| Aspect | Module | Provider | Consumer |
|--------|--------|----------|----------|
| Produces | Reusable HCL module | Go provider binary | Deployed infrastructure |
| Plan command | `/tf-module-plan` | `/tf-provider-plan` | `/tf-consumer-plan` |
| Implement command | `/tf-module-implement` | `/tf-provider-implement` | `/tf-consumer-implement` |
| Constitution | `module-constitution.md` | `provider-constitution.md` | `consumer-constitution.md` |
| Design file | `specs/{feat}/design.md` | `specs/{feat}/provider-design-{resource}.md` | `specs/{feat}/consumer-design.md` |
| Test format | `.tftest.hcl` (mock + real) | Go acceptance tests | None (sandbox deploy) |
| Test command | `terraform test` | `go test` with `TF_ACC=1` | `terraform plan/apply` in sandbox |
| Linter | `tflint` | `tflint` + `golangci-lint` | `tflint` |
| Provider blocks | Forbidden in root | N/A | Required in `providers.tf` |
| Backend | Forbidden | N/A | Required (`cloud {}`) |
| Raw resources | Yes | Go CRUD | Forbidden except glue |
| Output | Private Module Registry | Terraform Registry or internal | HCP Terraform workspace |
| Module version constraint | `>=` | N/A | `~>` |


Continue to [Day 2: consumer module uplift](06-day-2-consumer-uplift.md).
