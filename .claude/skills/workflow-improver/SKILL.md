---
name: workflow-improver
description: Retrospective on how the workflow performed in actual use. Captures friction points and lessons learned, updates the workflow's own files, and occasionally suggests leveling up. Use after running the built workflow, not just after building it.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion
---

# Workflow Improver Skill

You are helping the user reflect on how their workflow performed in actual use, and improve it based on what was learned.

This is the retrospective step in the loop: **build → use → improve → use again**. Unlike `workflow-reviewer` (which checks code quality, security, and best practices regardless of whether the workflow has been run), this is about capturing what you *learned* from actually using the thing.

**Reference files:**
- `.claude/knowledge/component-decision-guide.md` - where a given fix belongs, and the "leveling up" menu
- `.claude/knowledge/workflow-patterns.md` - patterns and anti-patterns to recognize

## Best run right after using the workflow – and mine that session

**The ideal moment for this is the end of the session in which the workflow just
ran.** Everything that went wrong is right there in the conversation above you: the
places the user had to clarify, the output they asked you to redo, the step that
needed three attempts, the question you had to ask because something wasn't written
down.

**So look before you ask.** If the workflow ran earlier in this conversation, read
back over it and come to the user with observations rather than a blank question:

"I noticed a few things while we were running it:
- You had to tell me the report goes to the GM, not the owner – I should have known that
- We went back and forth twice on the labour format
- The sales export path was wrong the first time

Do those match what bugged you? Anything else?"

That is a far better retrospective than "how did it go?", because friction is
extremely easy to forget five minutes after you've worked around it. The user
smoothed over three things without really noticing; the transcript didn't.

**If the workflow didn't run in this session**, fall back to the interview in Step 1
– but say which you're doing, so they know whether to jog their own memory.

## The one rule

**The user is reporting on a real experience. Believe them, and be specific back.**

A vague retrospective produces vague notes that nobody acts on. The whole value is
turning "it was a bit annoying" into "the workflow asks for the date every time even
though it's always last week, so default it and let them override."

## Your Task

### Step 0: Read the room before asking anything

Do this silently, before the first question. It's what lets you ask specific
questions instead of generic ones.

1. **Check this workflow exists**: `project-plan/project-design.md`. If missing, this
   folder hasn't been through `/create-agent` – say so and stop.
2. **Read the workflow's own command file** (`.claude/commands/[workflow-name].md`) so
   you know its actual steps and can ask about them by name.
3. **Read `project-plan/IMPROVEMENTS.md`** if it exists, especially any
   `## Lessons from using this workflow` section. You need to know:
   - What's already been reported (don't re-log it as if it's new)
   - What was promised but never done
   - **Whether something is being reported repeatedly** – see Step 5
4. **Check whether the workflow has actually been run**: look for output in its
   session directory, or recent modifications. If there's no sign it's ever run, ask
   before proceeding: "Have you had a chance to use it yet? This works best after a
   real run – if you haven't, we can wait."

5. **Re-read this session, if the workflow ran in it.** This is the richest source
   available and it disappears when the window closes. Collect: corrections the user
   made, output they asked you to change, anything you had to ask that should have
   been written down, retries, and steps that visibly took longer than they should.
   Bring these to Step 1 as observations rather than starting from a blank question.

### Step 1: Ask about the most recent run

**If you gathered observations from this session in Step 0**, lead with those (see
"Best run right after using the workflow" above) and use the question below only as
a follow-up. Observations first, question second – it's easier to react than recall.

**Otherwise**, open with one question, specific to their workflow:

"Tell me about the last time you ran `/[workflow-name]`. What worked, what didn't,
and did anything surprise you?"

Then follow up **one at a time**, choosing what fits rather than asking all of these:

- Did you have to explain something I should have already known?
- Did you fix or redo anything by hand afterwards?
- Was there a step that felt slower or clunkier than it should be?
- Did it produce what you needed, or did you touch up the output?
- Did you skip any part of it? (Skipped steps are strong signals)
- Was anything wrong rather than just awkward? (Correctness beats polish)

**If the answer is "it was fine"**, believe it. Log it briefly and go to Step 6.
Don't interrogate someone into inventing problems.

### Step 2: Turn the complaint into a diagnosis

This is the part that makes the skill worth running. A user reports a *symptom*; your
job is to locate the *cause* and know where the fix belongs.

| What they say | Usually means | Where the fix goes |
|---|---|---|
| "I had to tell it X again" | Missing durable context | `CLAUDE.md`, or a knowledge file |
| "I had to fix the output" | Format/quality criteria not written down | Knowledge file with an example of "good" |
| "It asked me things it should know" | Input that should be defaulted or derived | The command file |
| "It was slow" | Serial work that could be parallel | The command file – see `workflow-patterns.md` |
| "It got the numbers wrong" | Missing validation step | Add a check before output |
| "I skipped that step" | The step isn't earning its place | Cut it, or make it optional |
| "I did part of it by hand" | Scope gap between design and reality | Extend the workflow, or update the design doc |
| "It broke" | A real bug | Fix it now, before anything else |

Say the diagnosis out loud and check it: "Sounds like the issue is X – it's asking
for the date every time when it could just assume last week. Does that match?"

Getting this wrong and being corrected is fine and useful. Guessing silently is not.

### Step 3: Record the lesson

Append to `project-plan/IMPROVEMENTS.md` under `## Lessons from using this workflow`,
creating the section if it doesn't exist. Use this format every time:

```markdown
### [YYYY-MM-DD] - [Short symptom, in the user's own words]

- **What happened**: [What they actually experienced, concretely]
- **Diagnosis**: [The underlying cause you agreed on]
- **Change**: [What was done, or what should be done]
- **Status**: Fixed | Deferred | Won't fix | Watching
```

Rules:
- **Newest entries at the top** of the section, so recent history reads first
- **Use their words for the symptom.** "The date thing is annoying" is more useful in
  six months than "suboptimal parameter handling"
- Log it even when the fix is immediate – the record is how recurrence gets spotted
- If they had nothing to report: one line, `Status: Watching`, and move on

### Step 4: Offer to make the change

If there's a concrete fix, offer it now – one at a time, most impactful first:

"Want me to make that change now?"

When they say yes:
1. Make the edit in the right place (Step 2's table)
2. Show what changed, briefly
3. Update that entry's **Status** to `Fixed`
4. **Say how to verify it**: "Next time you run it, it should skip straight to the
   summary. If it still asks, tell me and we'll look again."

If they'd rather not now, set `Status: Deferred` and leave it. Don't push.

**Don't batch up five changes and apply them silently.** One at a time, each
confirmed, so they can follow what's happening to their own tool.

### Step 5: Notice repeats – this is the highest-value thing here

Before finishing, compare against what you read in Step 0.

**If the same issue appears 2+ times**, stop patching and say so plainly:

```
This is the third time the date handling has come up. Patching it again probably
isn't the answer – something about that part of the design isn't right. Want to
rethink that step properly instead of adjusting it again?
```

Repeated symptoms mean the design is wrong, not that the fix was too small. Naming
that is worth more than any individual edit – and nobody notices it themselves,
because each instance feels minor in isolation.

**If a previously "Deferred" item comes up again**, that's the signal it wasn't
actually optional. Raise it.

### Step 6: Occasionally offer a "level up"

Only if **all** of these hold:
- This is at least the 2nd or 3rd `/improve-workflow` run (count the entries)
- Recent runs have been reasonably smooth – no open `Fixed`-pending problems
- You have a *specific* idea tied to what this workflow actually does

Then offer exactly one, low-pressure. The menu is in
`.claude/knowledge/component-decision-guide.md`: prose logic that's earned becoming a
real script, a small local web page for something it already outputs, `/workflows`
for a job that's grown multi-stage.

Skip this entirely if things are still rough. Someone fighting a broken workflow does
not want an upsell.

🧭 Guide's note: This mirrors the real habit of running a retrospective after using
something you built, not just when you build it. Most tools rot because nobody ever
asks "how did that actually go?" – this is that question, made routine.

### Step 7: Offer to save

"Want me to commit these changes with `/save-workflow`?"

## Worked example

```
Claude: Tell me about the last time you ran /close-out. What worked, what didn't?

User:   Mostly fine. But it kept asking me which week, and it's always last week.
        And I had to reformat the labour section for the GM again.

Claude: Two things then. The week question is easy - it can default to last week
        and let you override when you need a different one.

        The labour formatting is more interesting: is it that it gets the numbers
        right but lays them out wrong, or that it's showing the wrong things?

User:   Layout. He wants hours by department, not one total.

Claude: Got it - so the report format needs to say that explicitly, otherwise I'll
        keep guessing. That belongs in a knowledge file, not the command.

        Logged both. Want me to fix them now?
```

Recorded as:

```markdown
### 2026-08-04 - "It keeps asking which week" + labour section reformatting

- **What happened**: Prompted for the week on every run, always answered "last week".
  Labour section showed a single total; GM wants hours broken out by department.
- **Diagnosis**: Week should default rather than be asked. Report format never
  documented the department breakdown, so it was being guessed each run.
- **Change**: Default the week to the previous one, overridable. Added the expected
  labour layout to `.claude/knowledge/report-format.md`.
- **Status**: Fixed
```

## Error Handling

**No `project-plan/project-design.md`**: this folder hasn't been through
`/create-agent`. Say so and stop – don't improvise a retrospective for a workflow
that doesn't exist.

**No `IMPROVEMENTS.md` yet**: create it with the `## Lessons from using this
workflow` section and carry on.

**They haven't run the workflow yet**: say this works best after a real run, and
offer `/review-workflow` instead – that one doesn't need a run to be useful.

**Nothing to report**: don't push. One line, `Status: Watching`, done quickly. The
goal is the habit of checking in, not manufacturing work.

**They report something outside this workflow** (Claude Code itself, a connector,
another tool entirely): note it if useful, but don't try to fix it here. Say where it
actually belongs.
