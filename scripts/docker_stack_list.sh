#!/bin/bash

# Listing the currently active docker stacks and number of services per stack
  echo "*** LISTING CURRENT DOCKER SWARM STACKS AND SERVICES ***"
  docker stack ls
  echo