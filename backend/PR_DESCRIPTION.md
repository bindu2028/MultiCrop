PR title: fix: regenerate lockfiles and remediate security advisories

Summary
-------
This PR finalizes dependency remediation by regenerating `requirements.lock` and `requirements-dev.lock` after iteratively addressing high/critical advisories reported by `pip-audit`. It contains the deterministic lockfiles and a short explanation of the changes, tests to run, and the commands to create and push the branch + PR.

Files included
--------------
- `backend/requirements.lock`
- `backend/requirements-dev.lock`
- `backend/requirements.in` (toplevel inputs)
- `backend/requirements-dev.in` (dev inputs)
- `backend/scripts/regenerate_lock.sh` (helper for future regenerations)

Testing instructions
--------------------
1. Create and activate a venv in `backend`.
2. Install `pip-tools` and `pip-audit`:

   pip install pip-tools pip-audit

3. Run the project's tests and E2E test:

   pytest -q

4. Optionally re-run `pip-audit` against the lockfiles to verify:

   pip-audit -r backend/requirements.lock

Why this change
---------------
Automated `pip-compile` + `pip-audit` iterations were used to remove or upgrade packages with high/critical advisories while keeping resolver conflicts minimal. The changes are limited to inputs and generated lockfiles; runtime behavior should be unchanged aside from patched transitive dependencies.

Notes for reviewers
------------------
- Focus review on the `requirements.in` top-level inputs for any unexpected version pins or removals.
- Run the test suite and `pip-audit` locally before approving.
- If the CI reports unresolved advisories, see `backend/scripts/regenerate_lock.sh` for the standard regeneration steps.

Suggested commit message
------------------------
Regenerate `requirements.lock` and `requirements-dev.lock` to remediate pip-audit advisories; update top-level inputs as needed.

Suggested PR metadata
---------------------
- Labels: `security`, `dependencies`
- Reviewers: `@<your-github-username>`
