# Demo: Terraform Agentic AI Pipeline

> **Time to run:** ~25 minutes setup, ~15 minutes demo  
> **Audience:** Technical buyers, platform engineers, DevOps and SRE leads  
> **What you'll show:** A complete agentic loop — from natural language request to provisioned infrastructure, with the AI reasoning through each step

---

## What this demo shows

This demo runs a full agentic AI pipeline end-to-end on your laptop. An AI agent receives a plain-English infrastructure request, reasons through the required steps, calls the Terraform MCP Server at each stage, handles the results, and delivers a summary — without a human in the loop.

The customer sees the agent's **reasoning process** — not just the result. This is the differentiating moment.

---

## Before the demo

Complete everything in [`setup.md`](./setup.md) at least **30 minutes before** your call.

Quick checklist:
- [ ] Terraform CLI installed and authenticated
- [ ] MCP server installed and validated
- [ ] AI client (with agent mode) configured and connected
- [ ] Pipeline configuration validated (`demo.sh --check`)
- [ ] Test run completed successfully at least once

---

## Running the demo

```bash
./demo.sh
```

The script runs the pipeline in stages with narration cues. Stages:

| Stage | What happens | What to say |
|-------|--------------|-------------|
| 1 | Agent receives goal | "This is the only input. One sentence." |
| 2 | Agent plans its steps | "Watch it decide — on its own — what to do first." |
| 3 | Agent calls `terraform_plan` | "It's checking what will change before it does anything." |
| 4 | Agent evaluates the plan | "It's reading the plan output. If something looked wrong, it would flag it or ask." |
| 5 | Agent calls `terraform_apply` | "Now it's executing. Same Terraform. Same policies." |
| 6 | Agent reads outputs + summarizes | "It's wrapping up. Developer gets a clean summary, never touched the CLI." |

---

## Talking points

**Opening hook:** "I'm going to give the AI one sentence. It will figure out everything else."

**When the reasoning is visible:** "This is the part that's different. It's not following a script. It's deciding what to do based on what it sees."

**On the plan review step:** "Most customers configure a pause here — the agent surfaces the plan to a human channel before applying. You get AI speed on the prep work, human judgment on the commit."

**On policy enforcement:** "Sentinel is still running. OPA is still running. The agent doesn't have a backdoor. It's just a new type of requester."

**Closing:** "The story here isn't 'AI replaces your platform team.' It's 'your platform team's best practices, available to every developer, instantly, at any hour.'"

---

## Customizing for the customer

Before a call, consider updating the goal in `demo.sh` (line marked `DEMO_GOAL`) to something specific to their environment. Customers respond much more strongly to seeing their own module names or resource types.

```bash
# In demo.sh, find this line and customize it:
DEMO_GOAL="Provision a dev environment using the web-app module in us-east-1"
# Change to something like:
DEMO_GOAL="Spin up a dev instance of the payment-service in our staging workspace"
```

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
