#!/bin/bash

# Help message for script
helpFunction(){
  echo 
  echo "This script performs Docker Swarm initial setup tasks on QNAP Container Station architecture."
  echo
  echo "SYNTAX: # dwinit"
  echo "SYNTAX: # dwinit -option"
  echo "  VALID OPTIONS:"
  echo "    -all          Creates the Docker Swarm, then deploys all stacks with a corresponding folder inside the '../configs/' path."
  echo "    -listed       Creates the Docker Swarm, then deploys the 'listed' array of stacks defined in '../configs/swarm_stacks.conf'"
  echo "    -default      Creates the Docker Swarm, then deploys the 'default' array of stacks defined in '../configs/swarm_stacks.conf'"
  echo "    -h || -help   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Load config variables from file
  source /share/swarm/configs/swarm_vars.conf

# Stack deployment confirmation query
  if [[ "$1" = "-h" ]] || [[ "$1" = "-help" ]] ; then
    helpFunction
  elif [[ "$1" = "" ]] ; then
    #while true do
      read -r -p "Do you want to deploy the '-default' list of Docker Swarm stacks? [(Y)es/(N)o] " input
      case $input in 
        [yY]|[yY][eE][sS]) ;;
        [nN]|[nN][oO])
          # Query if Traefik should still be deployed
            #while true do
              read -r -p "  Should Traefik still be installed? [(Y)es/(N)o] " confirm
              case $input in 
                [yY]|[yY][eE][sS]) ;;
                [nN]|[nN][oO]) ;;
                *) echo "INVALID INPUT: Must be any case-insensitive variation of 'yes' or 'no'." break ;;
              esac
            #done
          ;;
        *) echo "INVALID INPUT: Must be any case-insensitive variation of 'yes' or 'no'." break ;;
      esac
      echo
    #done
  fi

# Swarm folder creation
  bash mkdir -pm 775 "${swarm_folder}"/{appdata,configs,runtime,scripts,secrets}
  #setfacl -Rdm g:docker:rwx "${swarm_folder}"
  chmod -R 775 "${swarm_folder}"
  echo

# Swarm initialization
  echo "*** INITIALIZING SWARM ***"
  docker swarm init --advertise-addr "${var_nas_ip}"
  echo "***** SWARM INITIALIZED, WAITING 10 SECONDS *****"
  sleep 10
  echo

# Traefik overlay network creation
  echo "*** CREATING OVERLAY NETWORK ***"
  docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable traefik_public
  echo "***** OVERLAY NETWORK CREATED, WAITING 15 SECONDS *****"
  sleep 15
  echo
  # Required networks creation verification
  if [ "$(docker network ls --filter name=traefik -q)" = "" ] || [ "$(docker network ls --filter name=gwbridge -q)" = "" ]; then
    docker network ls
    echo
    echo "*** THE ABOVE LIST MUST INCLUDE THE 'docker_gwbridge' AND 'traefik_public' NETWORKS ***"
    echo "*** IF EITHER OF THOSE NETWORKS ARE NOT LISTED, YOU MUST LEAVE, THEN RE-INITIALIZE THE SWARM ***"
    echo "*** IF YOU HAVE ALREADY ATTEMPTED TO RE-INITIALIZE, ASK FOR HELP HERE: https://discord.gg/KekSYUE ***"
    echo
    echo "** DOCKER SWARM STACKS WILL NOT BE DEPLOYED **"
    echo
    echo "******* ... ERROR ... DOCKER SWARM SETUP WAS NOT SUCCESSFUL *******"
    exit 1 # Exit script here
  fi

# Stack deployment
  if [[ "$1" = "" ]]; then
    case "${input}" in
      [yY]|[yY][eE][sS])
        . "${scripts_folder}"/docker_stack_deploy.sh -default
        ;;
      [nN]|[nN][oO])
        case "${confirm}" in 
          [yY]|[yY][eE][sS])
            . "${scripts_folder}"/docker_stack_deploy.sh traefik
          ;;
          *) echo "** DOCKER SWARM STACKS WILL NOT BE DEPLOYED **" ;;
        esac
        ;;
    esac
  elif [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] || [[ $1 = "--help" ]] ; then
    helpFunction
  else
    . "${scripts_folder}"/docker_stack_deploy.sh "$1"
  fi

# Script completion message
  echo
  echo "******* DOCKER SWARM SETUP SCRIPT COMPLETE *******"
  echo