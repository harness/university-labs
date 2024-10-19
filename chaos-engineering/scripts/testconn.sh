#!/bin/bash

URL="https://app.harness.io/v1/orgs/$MY_HARNESS_ORG/projects/$MY_HARNESS_PROJECT/connectors/myk8sclusterconnector/test-connection"
curl -i -X GET $URL \
  -H 'Harness-Account:'"$MY_HARNESS_ACCOUNT" \
  -H 'x-api-key:'"$MY_HARNESS_USER_PAT"