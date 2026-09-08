# Workflow

This project will utilize the following process for implementation.

- Discussion with principal regarding requirements and changes should result in an update to the requirements document, `Design/Mobster.md`. This file describes the process, not the requirements.
- Tasks to produce source based on those requirements will be itemized as Github issues via the `gh` command.
- Coding agents will be managed and dispatched by the "chat host" agent using the material of those tasks in combination with the requirements document where necessary.
    - Agents will be segregated using `cycleworktree`
    - Agents will deliver code to the "chat host" agent, the "chat host" agent will dispatch a `requirements-analyst` to provide whole changeset reconciliation against the dispatch for that work.
    - Implementation agents should be kept open and accessible for re-tasking on an open task until it is accepted by the "chat host" as the result of a favorable reading from the `requirements-analyst`. New github issues are not required for this task compliance work.
    - Accepted code will be merged into a `develop` branch by the "chat host" agent and the principal will be notified of changes - and if UAT is required, a summary of the work that needs to be reviewed and / or tested.
    - Issues will be closed and `cycleworktree` will be used to clean up completed worktree branches
- The results of UAT that require fixing, omission recovery, or change orders from the principal will be submitted as new github issues against the original issue (where applicable)
- When a substantial amount of work is complete (user's discretion) develop will be submitted for PR merge to `main` and the "chat host" agent will issue a release tag with change notes and any updated documentation for downstream consumers.