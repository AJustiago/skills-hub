---
name: model-orchestrator
description: Route work to the cheapest capable Claude model. Delegates simple tasks (reading docs, grep/search, summarizing, listing, formatting) to Haiku subagents, does everything else on Sonnet, and only uses Opus for genuinely difficult tasks AFTER asking the user to confirm. Use when the user asks to save cost, pick a model, orchestrate models, or at the start of a multi-step task that mixes easy and hard work.
---

# Model Orchestrator

Goal: spend as little as possible without lowering quality. Default to the cheapest model that can do the job; escalate only with a reason.

## Tiers

| Tier | Model (`Agent` `model` param) | Use for | Confirmation |
|------|-------------------------------|---------|--------------|
| Low  | `haiku`  | Simple, mechanical, read-heavy work | None |
| Default | `sonnet` | Everything not clearly simple or clearly hard | None |
| High | `opus`   | Difficult work only (see criteria below) | **Always ask the user first** |

## Step 1: Split the request into subtasks

Break the user's request into subtasks and classify each one. Do not classify the whole request as one unit; a big task is usually mostly Low/Default work with a small hard core.

### Low tier -> Haiku subagent
- Reading and summarizing docs, READMEs, changelogs, API references
- Finding files, grepping, listing symbols, collecting usages
- Extracting facts, fields, or config values
- Reformatting, renaming, boilerplate, trivial one-file edits
- Running a command and reporting output
- Fetching and condensing web pages

Delegate with the `Agent` tool, `model: "haiku"`. Use `subagent_type: "Explore"` for read-only search. Ask for a **short, structured result** (bullets, file:line refs) so the main context stays small. Run independent Haiku tasks in parallel in one turn.

### Default tier -> Sonnet
- Normal feature work, bug fixes, refactors, tests, code review
- Multi-file edits with clear requirements
- Writing docs, analysis, planning
- Anything you are unsure about (default here, not Opus)

If the main session is already Sonnet, do this work directly. Otherwise delegate with `model: "sonnet"`.

### High tier -> Opus (confirmation required)
Only consider Opus when at least one is true:
- Architecture or design with large, hard-to-reverse consequences
- Subtle bugs: race conditions, concurrency, security, data corruption, or a bug Sonnet already failed to fix
- Deep multi-step reasoning, proofs, tricky algorithms, complex migrations
- Large cross-cutting refactor where a wrong move is expensive
- The user explicitly asks for Opus / "think hard"

Never use Opus for reading, searching, summarizing, formatting, or routine coding.

## Step 2: Opus confirmation gate

Before **any** Opus call (subagent or switching the session model), you MUST use `AskUserQuestion`. Do not proceed on assumption, and do not reuse an earlier approval for a different task.

Include in the question:
1. What the task is and why it is hard (one line)
2. Cost comparison, using the rule of thumb below
3. Your recommendation first, marked "(Recommended)"

Options:
- **Use Opus for this task** - one focused pass on the hard core
- **Stay on Sonnet** - cheaper per token, may take more attempts
- **Sonnet first, Opus only if it fails** - cheapest if the task might be easier than it looks

### Cost rule of thumb (Opus vs long Sonnet)
Cost ~ tokens x price per token. Opus costs several times more per token than Sonnet, so Sonnet is cheaper **unless Sonnet needs many more tokens**. Estimate:

- If Sonnet would likely solve it in 1-2 passes -> Sonnet is cheaper. Recommend Sonnet.
- If Sonnet would need a **long** run (many retries, large context re-reads, long exploratory loops, repeated failed fixes) -> total Sonnet tokens can exceed one Opus pass. Opus can then be the **cheaper and faster** choice. Recommend Opus and say so.
- If Sonnet already failed once on the same problem -> recommend Opus (further Sonnet retries are likely wasted spend).
- If unsure -> recommend "Sonnet first, Opus only if it fails".

Verify current prices with the `claude-api` skill rather than quoting numbers from memory. State the comparison qualitatively (e.g. "roughly N x per token, but Sonnet would need ~M passes") unless you have checked prices.

If the user declines Opus, continue on Sonnet and do not ask again for the same task.

## Step 3: Run it

1. Announce the plan in a short table: subtask -> model -> reason.
2. Launch independent Haiku/Sonnet subagents in parallel.
3. Keep Opus work minimal and well scoped: give it the distilled context that Haiku/Sonnet gathered, not the raw files, so it reads less.
4. Opus does the hard reasoning; hand the mechanical follow-up (apply edits, run tests, format) back to Sonnet/Haiku.
5. Report the result and, in one line, which models were used.

## Escalation and de-escalation

- Haiku result is vague, wrong, or missing detail -> redo that subtask on Sonnet (not Opus).
- Sonnet fails twice on the same problem -> propose Opus through the confirmation gate.
- A task turns out simpler than expected -> drop to a cheaper tier.

## Rules

- Never use Opus without a fresh `AskUserQuestion` approval.
- Never pick a more expensive model "to be safe". Escalate on evidence.
- Keep subagent prompts self-contained and ask for compact output.
- Do not mention model names in commit messages, PRs, or code.
