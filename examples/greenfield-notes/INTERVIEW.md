# Greenfield Interview

> **Synthetic example.** Both sides of this conversation were written by the playbook authors to show the interview described in [`greenfield.md`](../../greenfield.md). It is not a transcript of a real session.

Starting state: the repository contains only `README.md`. The request was "Initialize the agent workflow for Claude Code and Codex in this repository using the Agent Playbook."

---

**Agent:** The repository has no code or manifests, so I'm treating this as a new project. Your README already tells me what you're building (a shared how-to notes app), who uses it (your six-person support team), and why (the current Google Doc is hard to search). I won't ask about those again. I'll ask a few questions, one at a time, then propose a stack.

**1. What would tell you, after the first month, that this is working?** My suggestion: the team stops editing the Google Doc and finds an answer by search in under a minute.

*Why: success criteria are the one product topic the README leaves open, and they decide what the first milestone must prove.*

**Human:** Yes, that. And new hires can find things without asking someone.

---

**Agent:** **2. What should it explicitly not do in the first version?** I'd leave out public sharing, real-time co-editing, and a mobile app.

*Why: non-goals keep the scaffolding small; real-time editing in particular would change the architecture.*

**Human:** Agreed. Also no comments on notes.

---

**Agent:** **3. Who will maintain this, and which languages are they comfortable with?**

*Why: team skills weigh more than anything else in the stack choice, so this comes before hosting.*

**Human:** Me, mostly. I know TypeScript well and some Python.

---

**Agent:** **4. Where can it run?** If the company already has a server or container host, I'd reuse it rather than add a hosted service.

*Why: hosting rules out some stacks, and nothing in the README hints at it.*

**Human:** We have a small Linux VM with Docker. Everyone signs in with Google Workspace.

---

**Agent:** **5. Will notes contain customer personal data?** If yes, we'd need encryption at rest and audit logging from the start.

*Why: a compliance answer changes the route of every later task, so it has to be settled now, not assumed.*

**Human:** No customer data, only internal procedures. But it must require company login.

---

**Agent:** **6. I'm assuming there is no budget for paid services and no required tool beyond Google sign-in. Is that correct?**

*Why: one confirmation of a stated assumption instead of two open questions; budget and organization standards both have an obvious default here.*

**Human:** Correct.

---

**Agent:** **7. For the first milestone I propose:** notes you can create, edit, and delete; full-text search; Google sign-in; deployed on the VM. Importing the Google Doc would be manual. Does that match?

*Why: the milestone is stated as a proposal because every part of it follows from the earlier answers.*

**Human:** Yes, manual import is fine.

---

**Agent:** That's enough to write the brief. Here are three stack options:

| Option | Trade-offs | Fit with your constraints |
| --- | --- | --- |
| **A. TypeScript: Node.js server with server-rendered pages, SQLite with FTS5 full-text search, one Docker container** | Few moving parts; FTS5 search is plenty for six users; full control over search and layout; you write the Google sign-in integration yourself | Matches your strongest language; runs on the VM; no paid services |
| B. Python: Django with SQLite | Built-in admin, auth, and migrations; more framework to learn | Your Python is weaker; otherwise fits |
| C. A self-hosted open-source wiki | Fastest path to the milestone: search and Google/OAuth sign-in usually come built in, no code to write; little control over search ranking and layout; another product to keep upgraded | Fits hosting, budget, and sign-in; the team adapts to the wiki's model |

**I recommend A:** your success criterion is finding an answer in under a minute, and A gives you control over how search ranks and displays notes, with no third-party upgrades for a one-person maintainer. Choose **C** if getting something running this week matters more than shaping search. Which do you want?

*Why: the decision belongs to the human; the agent gives a recommendation tied to the stated constraints, not a preference.*

**Human:** You decide.

---

**Agent:** Before I write the files, four onboarding questions the brief does not settle, one at a time. No tools are recommended yet: there is no code, CI, or tracker to connect to; I'll revisit this when update mode runs after scaffolding.

```text
Risk zone (1 of 4): every page requires company sign-in (answer 5). Should the
planned sign-in module be a risk zone?

a) Yes, minimum route Full (Recommended)
b) No
(or write your own answer)
```

**Human:** a.

```text
Staging (2 of 4): is there a staging environment besides the VM?

a) None for now (Recommended)
b) Yes: say how to reach it
```

**Human:** a.

*Why: with no staging, the question about using it for acceptance checks is moot and is skipped.*

```text
Independent review (3 of 4): what should review Standard and Full changes?

a) A different vendor's agent in a fresh session (Recommended)
b) The same agent in a fresh session
(or write your own answer)
```

**Human:** Claude Code in a fresh session.

```text
Models (4 of 4): which models serve deep, standard, and fast work?

a) session default for all three (Recommended)
(or name them)
```

**Human:** a.

*Why: `onboarding.md` follows the interview in greenfield, skips what the brief settles (hosting, data, budget), and asks one decision at a time; risk zones name planned areas instead of paths.*

---

**Agent:** I'll record option A in `docs/adr/0001-stack.md` with status `proposed`, not `accepted`, because you deferred the decision. The scaffolding task stays blocked until you confirm it. I'm writing the product brief, the project and capability maps (every entry is `planned` until code exists), and the scaffolding task card now.

*Why: `greenfield.md` says a deferred decision is not treated as accepted.*

---

**Agent (final report):**

- Recorded: the product brief (`draft` until you confirm it), ADR-0001 (`proposed`), project and capability maps with every entry `planned` or `unknown`, the scaffolding task (`blocked`), the onboarding answers (risk zone, staging, review), and the entry points `AGENTS.md` and `CLAUDE.md`.
- **Please confirm two things:** (1) the brief in `docs/agent/product-brief.md` matches what you said; (2) option A in ADR-0001, or tell me to switch to C. Once you confirm, I'll mark both accepted and unblock the scaffolding task.
- Open question: who besides you can deploy to the VM.

*Why: `greenfield.md` asks for the stack status and open questions in the final report, and confirmation of a deferred decision.*

---

## What the agent deliberately did not ask

- What the product is and who it is for: the README answers both.
- Detailed feature lists: they belong to later tasks, not to initialization.
- Database or framework preferences: the human talked about outcomes, so the agent made those calls inside the stack proposal.
