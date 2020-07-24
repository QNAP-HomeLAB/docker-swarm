#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/bash-colors.env

# Listing the currently active docker stacks and number of services per stack
  echo -e "${blu}[-> LISTING CURRENT DOCKER SWARM STACKS <-]${DEF} "
  if [ ! "$(docker stack ls)" = "NAME                SERVICES" ]; then
    docker stack ls
  else
    echo -e "${YLW} -> no current docker stacks exist${DEF} "
  fi
  echo