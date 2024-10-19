#!/bin/bash
if [[ -z "$MY_HARNESS_USER_PAT" ]]; then echo -e "PAT: \t❌ Not set"; else echo -e "PAT:\t✅ Set to: ${MY_HARNESS_USER_PAT}"; fi