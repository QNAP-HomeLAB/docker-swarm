#!/bin/bash

# Listing the unused docker volumes
  echo "*** LISTING UNUSED DOCKER VOLUMES ***"
  if [ ! "$(docker volume ls -qf dangling=true)" = "" ]; then
    docker volume ls -qf dangling=true
  else
    echo " -> no 'dangling' volumes exist "
  fi
  echo