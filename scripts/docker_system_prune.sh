#!/bin/bash

# Perform prune operation with/without '-f' option
  echo "*** PRUNING THE DOCKER SYSTEM ***"
  if [[ $1 = "-f" ]]; then
    docker system prune -f
  elif [[ $1 = "" ]]; then
    docker system prune
  fi
  echo "***** DOCKER SYSTEM PRUNE COMPLETE *****"
  echo