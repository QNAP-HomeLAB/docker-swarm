#!/bin/bash

# Help message for script
helpFunction(){
  echo 
  echo "This script leaves a Docker Swarm environment and removes a list of stacks on QNAP Container Station architecture."
  echo
  echo "SYNTAX: # dwlv"
  echo "SYNTAX: # dwlv -option"
  echo "  VALID OPTIONS:"
  echo "        -all          Removes all stacks with a corresponding folder inside the '../configs/' path, then laves the Docker Swarm."
  echo "        -noremove     Does *NOT* remove any currently deployed stacks, but still leaves the swarm"
  echo "        -h || -help   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Load config variables from file
  source /share/swarm/configs/swarm_vars.conf

# Check for '-noremove' command options
  if [[ "$1" = "-noremove" ]] ; then
    input=no;
  elif [[ $1 = "-all" ]] ; then
    input=yes;
  elif [[ $1 = "-h" ]] || [[ $1 = "-help" ]] ; then
    helpFunction
  else
    # Query if all stacks should be removed before leaving swarm
    read -r -p "Do you want to remove all Docker Swarm stacks (highly recommended)? [(Y)es/(N)o] " input
    echo
  fi

# Remove stacks if input is Yes
  case $input in
    [yY][eE][sS]|[yY])
      # Query if all stacks should be removed before leaving swarm
      read -r -p "Are you certain you want all Docker Swarm stacks removed? [(Y)es/(N)o] " confirm
      case $confirm in 
        [yY][eE][sS]|[yY])
        # remove all services in docker swarm
        . ${scripts_folder}/docker_stack_remove.sh -all
        ;;
        *)
        exit 1
      esac
      ;;
    [nN][oO]|[nN])
      echo "** DOCKER SWARM STACKS WILL NOT BE REMOVED **";
      # Pruning the system is optional but recommended
        . ${scripts_folder}/docker_system_prune.sh -f
      ;;
    *) echo "INVALID INPUT: Must be any case-insensitive variation of 'yes' or 'no'." break ;;
  esac

# Leave the swarm
  docker swarm leave -f

  echo
  echo "******* DOCKER SWARM LEAVE SCRIPT COMPLETE *******"
  echo