#!/bin/bash

# Help message for script
helpFunction(){
  echo 
  echo "This script bounces (removes then re-deploys) a single or pre-defined list of Docker Swarm stack"
  echo
  echo "SYNTAX: # dsb stack_name"
  echo "SYNTAX: # dsb -option"
  echo "  VALID OPTIONS:"
  echo "        -all          Re-deploys all stacks with a corresponding folder inside the '../configs/' path."
  echo "        -listed       Re-deploys stacks listed in the '../configs/swarm_stacks.conf' config file 'stacks_listed' array."
  echo "        -default      Re-deploys a default list of stacks defined in the '../configs/swarm_vars.conf' variable file."
  echo "        -h || -help   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Load config variables from file
  source /share/swarm/configs/swarm_stacks.conf
  source /share/swarm/scripts/script_vars.conf
  bounce_list=""

  if [[ $1 = "-all" ]]; then
    IFS=$'\n' bounce_list=( $(docker stack ls --format {{.Name}}) ); 
  elif [[ $1 = "-listed" ]]; then
    IFS=$'\n' bounce_list=( "${stacks_listed[@]}" );
  elif [[ $1 = "-default" ]]; then
    IFS=$'\n' bounce_list=( "${stacks_default[@]}" );
  elif [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] ; then
    helpFunction
  else
    bounce_list=("$@")
  fi

# Remove all stacks in list defined above
  . ${scripts_folder}/docker_stack_remove.sh "${bounce_list[@]}"

# Deploy all stacks in list defined above
  . ${scripts_folder}/docker_stack_deploy.sh "${bounce_list[@]}"

# Clear the 'bounce_list' array now that we are done with it
  unset bounce_list IFS

  echo "****** BOUNCE (REMOVE & REDEPLOY) STACK SCRIPT COMPLETE ******"
  echo