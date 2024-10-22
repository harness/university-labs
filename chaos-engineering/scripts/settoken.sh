#!/bin/bash

read -p "Enter the value for MY_HARNESS_USER_PAT: " && echo "export MY_HARNESS_USER_PAT=${REPLY}" >> ~/.bashrc && source ~/.bashrc