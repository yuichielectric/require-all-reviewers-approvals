#!/bin/bash

set -x

NOT_APPROVED_REVIEWERS=$(gh api -X GET "repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/reviews" --jq '[.[] | select(.state != "APPROVED")] | length')
REQUESTED_REVIEWERS=$(gh api -X GET "repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/requested_reviewers" --jq ".users | length")

if [ "${NOT_APPROVED_REVIEWERS}" -eq "0" ] && [ "${REQUESTED_REVIEWERS}" -eq "0" ]; then
  STATE="success"
else
  STATE="failure"
fi

gh api -X POST "/repos/${OWNER}/${REPO}/statuses/${STATUS_SHA}" -f state=${STATE} context="Require all reviewers' approvals"
