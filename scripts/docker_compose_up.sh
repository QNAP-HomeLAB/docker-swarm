#!/bin/bash
# This script STARTS (bring 'up') a single Docker container using a pre-written compose file.

# Load config variables from file
source /share/swarm/scripts/swarm_vars.conf

# Perform scripted action(s)
docker-compose -f ${configs_folder}/"$1"/"$1".yml up -d