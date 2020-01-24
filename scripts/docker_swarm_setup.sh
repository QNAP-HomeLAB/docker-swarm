#!/bin/bash

# Help message for script
helpFunction(){
  echo 
  echo "This script creates a Docker Swarm environment and deploys a list of stacks on QNAP Container Station architecture."
  echo
  echo "SYNTAX: # dwup"
  echo "SYNTAX: # dwup -option"
  echo "  VALID OPTIONS:"
  echo "        -all          Creates the Docker Swarm, then deploys all stacks with a corresponding folder inside the '../configs/' path."
  echo "        -listed       Creates the Docker Swarm, then deploys stacks listed in the '../configs/swarm_stacks.conf' config file 'stacks_listed' array."
  echo "        -default      Creates the Docker Swarm, then deploys a default list of stacks defined in the '../configs/swarm_vars.conf' variable file."
  echo "        -h || -help   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Load config variables from file
  source /share/swarm/configs/swarm_vars.conf

# Query which list of stacks the user wants to load.
  if [[ "$1" = "" ]]; then
    read -r -p "Do you want to deploy the '-default' list of Docker Swarm stacks? [Y/n] " input
    echo
  fi

# Swarm initialization
  echo "*** INITIALIZING SWARM ***"
  docker swarm init --advertise-addr $var_nas_ip
  echo "***** SWARM INITIALIZED, WAITING 10 SECONDS *****"
  sleep 10
  echo

# Overlay network creation
  echo "*** CREATING OVERLAY NETWORK ***"
  docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable traefik_public
  echo "***** OVERLAY NETWORK CREATED, WAITING 15 SECONDS *****"
  sleep 15
  echo

# Deploy the list of pre-defined stacks
  if [[ "$1" = "" ]]; then
    case $input in
      [yY][eE][sS]|[yY])
        . ${scripts_folder}/docker_stack_deploy.sh -default
        ;;
      [nN][oO]|[nN])
        echo "** DOCKER SWARM STACKS WILL NOT BE DEPLOYED **";
        ;;
      *)
        echo "INVALID INPUT: Must be any case-insensitive variation of 'yes' or 'no'."
        exit 1
        ;;
    esac
  elif [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] ; then
    helpFunction
  else
    . ${scripts_folder}/docker_stack_deploy.sh "$1"
  fi

# List out current docker networks to ensure required networks were created
  if [ "$(docker network ls --filter name=traefik -q)" = "" ] || [ "$(docker network ls --filter name=gwbridge -q)" = "" ]; then
    docker network ls
    echo
    echo "*** THE ABOVE LIST MUST HAVE 'docker_gwbridge' AND 'traefik_public' LISTED ***"
    echo "*** IF EITHER OF THOSE NETWORKS ARE NOT LISTED, YOU MUST RE-INITIALIZE THE SWARM ***"
    echo "*** IF YOU HAVE ALREADY ATTEMPTED TO RE-INITIALIZE, ASK FOR HELP HERE: https://discord.gg/KekSYUE ***"
  fi

  echo
  echo "******* DOCKER SWARM SETUP SCRIPT COMPLETE *******"
  echo