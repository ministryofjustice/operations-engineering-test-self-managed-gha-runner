#!/usr/bin/env bash

set -euo pipefail

ACTIONS_RUNNER_DIRECTORY="/actions-runner"

echo "Runner parameters:"
echo "  Organisation: ${ORG_NAME}"
echo "  Runner Name: $(hostname)"
echo "  Runner Labels: ${RUNNER_LABELS}"

echo "Obtaining registration token"
getRegistrationToken=$(
  curl \
    --silent \
    --location \
    --request "POST" \
    --header "X-GitHub-Api-Version: 2022-11-28" \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    https://api.github.com/orgs/${ORG_NAME}/actions/runners/registration-token | jq -r '.token'
)
export getRegistrationToken

echo "Checking if registration token exists"
if [[ -z "${getRegistrationToken}" ]]; then
  echo "Failed to obtain registration token"
  exit 1
else
  echo "Registration token obtained successfully"
  ORG_TOKEN="${getRegistrationToken}"
fi

whoami
echo "Configuring runner"
bash "${ACTIONS_RUNNER_DIRECTORY}/config.sh" \
  --unattended \
  --disableupdate \
  --url "https://github.com/${ORG_NAME}" \
  --token "${ORG_TOKEN}" \
  --name "$(hostname)" \
  --labels "${RUNNER_LABELS}"

echo "Starting runner"
bash "${ACTIONS_RUNNER_DIRECTORY}/run.sh"