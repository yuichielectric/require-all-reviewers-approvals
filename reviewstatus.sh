#!/bin/bash

OWNER=$1
REPO=$2
NUMBER=$3
SHA=$4

echo ${GITHUB_TOKEN} | gh auth login --with-token
NOT_APPROVED_REVIEWERS=$(gh api -X GET 'repos/${OWNER}/${REPO}/pulls/${NUMBER}/reviews' --jq '[.[] | select(.state != "APPROVED")] | length')
REQUESTED_REVIEWERS=$(gh api -X GET 'repos/${OWNER}/${REPO}/pulls/${NUMBER}/requested_reviewers' --jq ".users | length")

if [ ${NOT_APPROVED_REVIEWERS} -eq 0 ] && [ ${REQUESTED_REVIEWERS} -eq 0]; then
  STATE="success"
else
  STATE="failure"
fi

gh api -X POST '/repos/${OWNER}/${REPO}/statuses/${SHA}' -f state=${STATE}
