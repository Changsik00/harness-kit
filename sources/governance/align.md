# 🚀 Session Kickoff
I am starting a new session in this project.
Prior to taking any action, you MUST:

1. **Read Rules**: Read `.agent/agent.md` and `.agent/constitution.md` (if they exist) to understand the operating protocols.
2. **Context Check**: 
   - Run `git branch` and `git log -1 --oneline` to check the latest state.
   - Run `ls -R specs/` (or equivalent documentation folder) to locate active specifications.
3. **Queue Check**: Read `backlog/queue.md` (or the active task list) to identify the next priority.
4. **Behavior Lock**: 
   - **Language Rule**: 
     - Chat, Specs, Plans, and PR Descriptions MUST be in **Korean**.
     - Agent System Docs and Code Comments should be in **English**.
   - **Process & Visualization**:
     - Follow the **SDD Process** (Spec -> Plan -> Task) strictly.
     - **TDD Enforcement**: Write Test -> Fail -> Implement -> Pass -> Commit.
     - **Progress Tracking**: Immediately mark completed items in `task.md` with `[x]` after every commit to visualize progress to the user.

Once you have read the rules and checked the context, summarize the current status and ask: "Which context should we continue with?"
