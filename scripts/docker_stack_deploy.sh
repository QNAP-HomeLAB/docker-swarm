#!/bin/bash

# Help message for script
helpFunction(){
  echo 
  echo "This script deploys a single or pre-defined list of Docker Swarm stack"
  echo
  echo "SYNTAX: # dsd stack_name"
  echo "SYNTAX: # dsd -option"
  echo "  VALID OPTIONS:"
  echo "        -all          Deploys all stacks with a corresponding folder inside the '../configs/' path."
  echo "        -listed       Deploys stacks listed in the '../configs/swarm_stacks.conf' config file 'stacks_listed' array."
  echo "        -default      Deploys the 'default' list of stacks defined in the '../configs/swarm_vars.conf' variable file"
  echo "        -h || -help   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Load config variables from file
  source /share/swarm/configs/swarm_stacks.conf
  source /share/swarm/scripts/script_vars.conf
  deploy_list=""

# Make sure the $swarm_folder structure is usable by the `dockuser` username and group
  chown -R $var_usr:$var_grp $swarm_folder
  chmod -R 640 $swarm_folder # OWNER: Read/Write, GROUP: Read

# Define which stack(s) to load using command options
  if [[ $1 = "-all" ]]; then
    if [[ "${bounce_list[@]}" = "" ]]; then
      IFS=$'\n' deploy_list=( "${stacks_all[@]}" );
    else
      IFS=$'\n' deploy_list=( "${bounce_list[@]}" );
    fi
  elif [[ $1 = "-listed" ]]; then
    IFS=$'\n' deploy_list=( "${stacks_listed[@]}" );
  elif [[ $1 = "-default" ]]; then
    IFS=$'\n' deploy_list=( "${stacks_default[@]}" );
  elif [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] ; then
    # Print helpFunction in case parameters are empty
    helpFunction
  else
    deploy_list=("$@")
  fi

# Display list of stacks to be deployed
  echo "*** DEPLOYING LISTED STACK(S) ***"
  # Remove duplicate entries in deploy_list
    deploy_list=(`for stack in "${deploy_list[@]}" ; do echo "$stack" ; done | sort -u`)
  # Remove 'traefik' from the deploy_list array
    for i in "${!deploy_list[@]}"; do
      if [[ "${deploy_list[i]}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
        unset 'deploy_list[i]'
      fi
    done
  # Add 'traefik' stack as first item in deploy_list array
    if [ "$(docker service ls --filter name=traefik -q)" = "" ]; then
      deploy_list=( "traefik" "${deploy_list[@]}" )
      echo " -> ${deploy_list[@]}"
      echo
      echo "*** TRAEFIK MUST BE THE FIRST DEPLOYED SWARM STACK ***"
      echo
    else
      echo " -> ${deploy_list[@]}"
      echo
    fi
  # Create the 'traefik_public' overlay network if it does not already exist
    if [ "$(docker network ls --filter name=traefik -q)" = "" ]; then
      echo "*** CREATING OVERLAY NETWORK ***"
      docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable traefik_public
      echo "***** OVERLAY NETWORK CREATED, WAITING 15 SECONDS *****"
      sleep 15
      echo
    fi

# Deploy indicated stack(s)
  for stack in "${deploy_list[@]}"; do
    echo "*** DEPLOYING '$stack' ***"
    ln -sf ../$variables_file $configs_folder/${stack}/.env
    docker stack deploy $stack -c ${configs_folder}/${stack}/${stack}.yml
    echo "**** '$stack' DEPLOYED, WAITING 10 SECONDS ****"
    sleep 10
  done

# Clear the 'deploy_list' array now that we are done with it
  unset deploy_list IFS

# Print script complete message
  echo
  echo "****** STACK DEPLOY SCRIPT COMPLETE ******"
  echo