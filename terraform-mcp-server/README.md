# Demo: Terraform MCP Server

> **Time to run:** ~20 minutes setup, ~10 minutes demo  
> **Audience:** Technical buyers, platform engineers, DevOps leads  
> **What you'll show:** A live AI model calling Terraform operations through MCP in real time

---

## What this demo shows

You will run the Terraform MCP Server locally and connect it to an AI client. The customer will see — live — a natural language request get translated into a Terraform `plan` and `apply` through the MCP interface.

This is not a slide. This is the real thing running on your laptop.

---

## Before the demo

Complete everything in [`setup.md`](./setup.md) at least **30 minutes before** your call. Do not attempt setup for the first time during a customer meeting.

Quick checklist:
- [ ] Terraform CLI installed and authenticated
- [ ] MCP server installed and validated (`demo.sh --check`)
- [ ] AI client configured and connected to the MCP server
- [ ] Test run completed successfully

---

## Running the demo

```bash
./demo.sh
```

The script walks through the demo in stages. At each stage, there is a pause for you to narrate before the next step runs. The stages are:

| Stage | What runs | What to say |
|-------|-----------|-------------|
| 1 | Server starts, tools are listed | "The MCP server advertises its capabilities to the AI — these are the tools the model can call." |
| 2 | Natural language request is sent | "I'm typing a plain English request. No CLI flags, no scripting." |
| 3 | Agent calls `terraform_plan` | "The AI decided to run a plan first. Watch it read the output." |
| 4 | Agent calls `terraform_apply` | "It's applying. Every operation is still running through Terraform — the audit trail is the same." |
| 5 | Agent reads outputs | "And now it's reading the outputs to summarize what was created." |

---

## Talking points

**Opening hook:** "Right now, your platform team is the interface between developers and infrastructure. What if that interface could respond in seconds, at any hour, with full policy enforcement?"

**During the plan step:** "Notice the AI isn't bypassing Terraform — it's using it. Your Sentinel policies, your state backend, your module library — all of it still applies."

**On the apply:** "This is where most customers want a human approval gate, and that's easy to configure. You can make this fully autonomous, or require a Slack approval, or stop at plan — your call."

**Closing:** "The code running this demo is the same code your team would deploy. This isn't a prototype. This is the architecture."

---

## If something goes wrong

| Problem | Quick fix |
|---------|-----------|
| Server won't start | Check prerequisites in `setup.md`, run `demo.sh --check` |
| AI client not connecting | Verify MCP server URL/port in client config |
| Terraform auth error | Re-run `terraform login` and confirm workspace access |
| Demo fails mid-run | Have a screen recording of a successful run as backup — see `setup.md` |

---

## Related resources

- [Full documentation: Terraform MCP Server](../docs/02-terraform-mcp-server.md)
- [Instruqt track: Terraform MCP Server](https://instruqt.com/placeholder-track-1)
- [Setup guide](./setup.md)
