#!/bin/bash
# This script STOPS (bring 'down') a single Docker container using a pre-written compose file.

# Load config variables from file
  source /share/docker/compose/compose_vars.env

# Perform scripted action(s)
  docker-compose -f /share/docker/compose/configs/${1}/${1}-compose.yml down
  # docker-compose -f ${compose_configs}/${1}/${1}-compose.yml down