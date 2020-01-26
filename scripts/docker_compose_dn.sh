#!/bin/bash
# This script STOPS (bring 'down') a single Docker container using a pre-written compose file.

# Load config variables from file
  source /share/swarm/scripts/script_vars.conf

# Perform scripted action(s)
docker-compose -f ${configs_folder}/"$1"/"$1".yml down