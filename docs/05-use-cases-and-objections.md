# 05 — Use Cases & Objections

## Top customer use cases

### 1. Self-service developer environments
**The scenario:** A developer asks an AI assistant to "spin up a dev environment for the checkout service." The agent provisions the correct workspace, applies the right module, and returns the endpoint — no ticket, no waiting for platform team approval.

**Why customers care:** Reduces platform team toil. Developers get environments faster. The company gets consistent, policy-compliant infrastructure.

**Who to target:** Platform engineering teams, DevEx-focused orgs, companies with high developer headcount.

---

### 2. Autonomous incident remediation
**The scenario:** A monitoring alert fires. An AI agent is paged, assesses the situation, and executes a predefined Terraform runbook to scale the affected resource or replace a failed instance — before a human is even out of bed.

**Why customers care:** Reduces MTTR. Reduces on-call burden. Keeps humans in the loop for decisions, not execution.

**Who to target:** SRE teams, cloud ops, organizations with high-severity SLA commitments.

---

### 3. AI-assisted infrastructure review
**The scenario:** A developer opens a Terraform PR. An AI agent reads the plan, checks it against internal standards and past incidents, and posts a structured review — flagging cost implications, security concerns, and policy violations.

**Why customers care:** Speeds up PR reviews. Catches issues that humans miss under time pressure. Scales the platform team's knowledge.

**Who to target:** Any org doing code review on IaC. Especially useful for teams where infrastructure review is a bottleneck.

---

### 4. Natural language infrastructure queries
**The scenario:** A product manager asks "how many instances are we running in production right now, and what are they costing?" The agent queries Terraform state and returns a plain-language answer.

**Why customers care:** Democratizes infrastructure visibility without giving everyone console access.

**Who to target:** Orgs with mixed technical/non-technical stakeholders, FinOps-focused teams.

---

## Common objections and how to handle them

### "We don't trust AI to touch production infrastructure."

**Response:** That's the right instinct, and the architecture supports it. You can configure the agent to plan but never apply — every `apply` requires a human approval step. Think of it as AI-assisted drafting, not autonomous execution. Most customers start there and expand the automation scope as confidence grows.

---

### "How do we know what the AI actually did?"

**Response:** The audit trail is identical to what you have today. Every operation runs through Terraform's plan/apply cycle. HCP Terraform logs every run, who (or what) triggered it, the plan output, and the apply results. The agent is just a new type of trigger — the traceability doesn't change.

---

### "We're worried about the AI making expensive mistakes."

**Response:** Sentinel and OPA policies still run. Cost estimation still runs. If an operation would exceed a cost threshold or violate a policy, it gets blocked — regardless of whether the requester was a human or an agent. You're not removing guardrails; you're adding a new interface in front of them.

---

### "We already have automation with scripts and CI/CD. Why do we need this?"

**Response:** Scripts handle the paths you anticipated. Agents handle the paths you didn't. When something unexpected happens in a pipeline — an error, a missing variable, an ambiguous state — a script fails and pages someone. An agent can reason about the situation, try a recovery step, and escalate only when it genuinely needs a human. It's not a replacement for pipelines; it's an intelligent layer on top.

---

### "Is this GA? Is it production-ready?"

**Response:** [Update this with the current product status at time of use.] The pattern is being used in production by early customers. The Terraform MCP Server is [status]. Recommended starting point is non-production environments while the team builds familiarity.

---

**Back: [04 — Agentic Pipeline Architecture](./04-agentic-pipeline-architecture.md)**  
**Return to: [Repository Home](../README.md)**
