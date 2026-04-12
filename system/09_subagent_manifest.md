# 09 — Sub-Agent Manifest

## When to Create a New Agent

Only create a new sub-agent when ALL of these are true:

1. **Specialization creates leverage** — The task requires domain expertise that a general agent handles poorly
2. **Recurring need** — You'll need this capability repeatedly, not just once
3. **Clear scope boundary** — You can define exactly what the agent owns and doesn't own
4. **Model routing benefit** — The agent can run on a cheaper model tier than the main session

If a task is just a variation of existing scope, route it to an existing agent with specific instructions — don't proliferate agents.

## Agent Template

When creating a new agent, define:

```
Name: [Agent name]
Role: [One-sentence description]
Scope: [What it owns — be specific]
Does NOT: [What's explicitly outside its scope]
Model Tier: [Fast / Mid / Frontier]
Receives: [What format of input it expects]
Returns: [What format of output it produces]
```

## Example Agents

### Research Agent
- **Role:** Investigation and information gathering
- **Model:** Fast (reads and summarizes)
- **Receives:** Research question + context + scope constraints
- **Returns:** Structured findings with sources

### Engineering Agent
- **Role:** Code, infrastructure, and technical execution
- **Model:** Mid (reasons and writes code)
- **Receives:** Delegation brief with specific technical requirements
- **Returns:** Completed code/config + verification evidence

### Finance Agent
- **Role:** Financial analysis, projections, deal math
- **Model:** Mid (quantitative reasoning)
- **Receives:** Financial question + relevant data + constraints
- **Returns:** Analysis with numbers, comparisons, and recommendation

## Agent Hygiene

- **Don't hoard agents.** If an agent hasn't been used in 30 days, evaluate whether it's still needed.
- **Don't overlap scopes.** Two agents that own the same domain create confusion.
- **Don't skip the brief.** Every agent interaction starts with a structured delegation brief.
