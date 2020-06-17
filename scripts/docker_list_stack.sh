#!/bin/bash

# Listing the currently active docker stacks and number of services per stack
  echo "*** LISTING CURRENT DOCKER SWARM STACKS AND SERVICES QUANTITY ***"
  if [ ! "$(docker stack ls)" = "" ]; then
    docker stack ls
  else
    echo " -> no current docker stacks exist "
  fi
  echo