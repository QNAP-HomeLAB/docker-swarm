#!/bin/bash
# This script STARTS (bring 'up') a single Docker container using a pre-written compose file.

# Load config variables from file
  source /share/docker/compose/compose_vars.env

# Perform scripted action(s)
  # create the '.env' file redirect (if used)
  # ln -sf "${swarm_configs}"/"${variables_file}" "${swarm_configs}"/"${stack}"/.env
  # sleep 1
  docker-compose -f /share/docker/compose/configs/${1}/${1}-compose.yml up -d
  # docker-compose -f |${compose_configs//$'\n\r\t'}|/${1}/${1}-compose.yml up -d