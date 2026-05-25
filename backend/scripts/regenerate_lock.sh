#!/usr/bin/env bash
set -euo pipefail

# Regenerate requirements.lock from requirements.txt using pip-tools.
# Usage: ./regenerate_lock.sh

python -m pip install --upgrade pip
python -m pip install pip-tools pip-audit

# By default regenerate production lock from requirements.in
echo "Generating production lock from requirements.in"
pip-compile --generate-hashes --output-file=requirements.lock requirements.in

# Optionally generate dev lock if requested
if [ "${1-}" = "--dev" ] || [ "${BUILD_DEV-}" = "1" ]; then
	echo "Generating dev lock from requirements-dev.in"
	pip-compile --generate-hashes --output-file=requirements-dev.lock requirements-dev.in
fi

# Run pip-audit on the production lock
echo "Running pip-audit on requirements.lock"
pip-audit -r requirements.lock || true

echo "Regeneration complete. Inspect requirements.lock (and requirements-dev.lock if generated) and commit if acceptable."
