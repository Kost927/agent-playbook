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

*Why: asked separately because the answer depends on question 3; hosting rules out some stacks.*

**Human:** We have a small Linux VM with Docker. Everyone signs in with Google Workspace.

---

**Agent:** **5. Will notes contain customer personal data?** If yes, we'd need encryption at rest and audit logging from the start.

*Why: a compliance answer changes the route of every later task, so it has to be settled now, not assumed.*

**Human:** No customer data, only internal procedures. But it must require company login.

---

**Agent:** **6. Is there any budget for paid services, or any tool the company requires?** My assumption: no paid services, and Google sign-in is the only standard.

*Why: budget and organization standards are grouped because both have an obvious default; one question with a stated assumption costs less than two.*

**Human:** Right, no budget and nothing else required.

---

**Agent:** **7. For the first milestone I propose:** notes you can create, edit, and delete; full-text search; Google sign-in; deployed on the VM. Importing the Google Doc would be manual. Does that match?

*Why: the milestone is stated as a proposal because every part of it follows from the earlier answers.*

**Human:** Yes, manual import is fine.

---

**Agent:** That's enough to write the brief. Here are three stack options:

| Option | Trade-offs | Fit with your constraints |
| --- | --- | --- |
| **A. TypeScript: Node.js server with server-rendered pages, SQLite with built-in full-text search, one Docker container** | Few moving parts; SQLite search is plenty for six users; you write the sign-in integration yourself | Matches your strongest language; runs on the VM; no paid services |
| B. Python: Django with SQLite | Built-in admin, auth, and migrations; more framework to learn | Your Python is weaker; otherwise fits |
| C. A self-hosted open-source wiki | No code to write; little control over search and layout; another product to upgrade | Fits hosting and budget; the team must adapt to its model |

**I recommend A:** it fits the language you know best and the VM you already have, and it keeps everything in one container. Which do you want?

*Why: the decision belongs to the human; the agent gives a recommendation tied to the stated constraints, not a preference.*

**Human:** You decide.

---

**Agent:** I'll record option A in `docs/adr/0001-stack.md` with status `proposed`, not `accepted`, because you deferred the decision. The scaffolding task stays blocked until you confirm it. I'm writing the product brief, the project and capability maps (every entry is `planned` until code exists), and the scaffolding task card now.

*Why: `greenfield.md` says a deferred decision is not treated as accepted.*

---

## What the agent deliberately did not ask

- What the product is and who it is for: the README answers both.
- Detailed feature lists: they belong to later tasks, not to initialization.
- Database or framework preferences: the human talked about outcomes, so the agent made those calls inside the stack proposal.
