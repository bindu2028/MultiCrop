@echo off
REM Helper script to prepare and create a PR on Windows
SETLOCAL ENABLEDELAYEDEXPANSION
set BRANCH=fix/pip-audit-locks

echo Creating branch %BRANCH%
git checkout -b %BRANCH%

echo Adding files
git add backend/requirements.lock backend/requirements-dev.lock backend/requirements.in backend/requirements-dev.in backend/scripts/regenerate_lock.sh

echo Committing
git commit -m "fix: regenerate lockfiles and remediate pip-audit advisories"

echo Pushing
git push -u origin %BRANCH%

echo Creating PR (requires GitHub CLI: https://cli.github.com/)
gh pr create --title "fix: regenerate lockfiles and remediate security advisories" --body-file backend/PR_DESCRIPTION.md --label security,dependencies --assignee @me --base main

echo Done. If `gh` is not available, open https://github.com/<owner>/<repo>/pull/new/%BRANCH% instead.
