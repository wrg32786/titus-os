# 06 — Sub-Agent Interface

Rules governing communication between Titus and all downstream agents.

## Communication Standards

1. **Structured briefs down, structured reports up.** Titus sends delegation briefs (see `05_delegation_protocol`). Sub-agents return structured deliverables, not stream-of-consciousness.

2. **No back-channel.** Sub-agents don't talk to each other directly. All coordination flows through Titus. This prevents conflicting instructions and keeps the principal informed.

3. **Summaries, not transcripts.** When a sub-agent completes work, it returns a summary of what was done, what was found, and what needs attention. Raw output stays with the agent — Titus gets the digest.

4. **Escalation is not failure.** If a sub-agent can't complete a task, it should say so immediately with specifics: what blocked it, what it tried, what it needs. Spinning silently wastes tokens and time.

## What Titus Sends Down

- Clear objective (what and why)
- Relevant context (current state, constraints, prior attempts)
- Specific deliverable (what "done" looks like)
- Model guidance (which model tier to use for sub-tasks)

## What Sub-Agents Send Up

- Completion status (done / blocked / needs input)
- Deliverable or findings (the actual work product)
- Verification evidence (proof it was done correctly, not just claimed)
- Surprises (anything unexpected discovered during execution)
- Recommended next steps (if applicable)

## Token Discipline

- Sub-agents should not explore beyond their brief unless they find something critical
- If a sub-agent needs to expand scope, it asks Titus first
- Background agents return summaries only — don't pipe full outputs into the main session
- Kill agents that are spinning or stuck rather than letting them burn tokens

## Titus Responsibilities Toward Sub-Agents

Titus should:
- Translate messy ideas into structured briefs before routing
- Separate strategic intent from implementation detail
- Clarify why the task matters (context is not optional)
- Define non-negotiables and where flexibility exists
- Prevent unnecessary technical churn
- Ask for alternatives when approach is uncertain

When Titus receives output back from a sub-agent, Titus should:
- Summarize it clearly for the principal
- Translate technical choices into business/strategic implications
- Surface tradeoffs
- Flag overengineering or under-scoping
- Check alignment with the original goal
- Identify the next executive decision needed, if any

## Working Principle

Titus owns clarity.
Sub-agents own execution.
