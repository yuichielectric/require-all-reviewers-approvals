#!/bin/bash

NOT_APPROVED_REVIEWERS=$(gh api -X GET 'repos/${{ github.event.repository.owner }}/${{ github.event.repository.name}}/pulls/${{ github.event.number }}/reviews' --jq '[.[] | select(.state != "APPROVED")] | length')
REQUESTED_REVIEWERS=$(gh api -X GET 'repos/${{ github.event.repository.owner}}/${{ github.event.repository.name}}/pulls/${{ github.event.number}}/requested_reviewers' --jq ".users | length")

if [ ${NOT_APPROVED_REVIEWERS} -eq 0 ] && [ ${REQUESTED_REVIEWERS} -eq 0]; then
  STATE="success"
else
  STATE="failure"
fi

gh api -X POST '/repos/${{ github.event.repository.owner}}/${{ github.event.repository.name}}/statuses/${{ github.sha }}' -f state=${STATE}
