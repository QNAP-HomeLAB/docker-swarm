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
  echo "        -listed       Deploys the 'listed' array of stacks defined in '../configs/swarm_stacks.conf'"
  echo "        -default      Deploys the 'default' array of stacks defined in '../configs/swarm_stacks.conf'"
  echo "        -h || -help   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Load config variables from file
  source /share/swarm/configs/swarm_stacks.conf
  source /share/swarm/configs/swarm_vars.conf
  deploy_list=""

# Define which stack(s) to load using command options
  if [[ $1 = "-all" ]]; then
    if [[ "${bounce_list[@]}" = "" ]]; then
      IFS=$'\n' deploy_list=( $(cd "${configs_folder}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') );
      if [[ "${deploy_list[i]}" = "." ]]; then
        unset 'deploy_list[i]'
      fi
    else
      IFS=$'\n' deploy_list=( "${bounce_list[@]}" );
    fi
  elif [[ $1 = "-listed" ]]; then
    IFS=$'\n' deploy_list=( "${stacks_listed[@]}" );
  elif [[ $1 = "-default" ]]; then
    IFS=$'\n' deploy_list=( "${stacks_default[@]}" );
  elif [[ -z "$1" ]] || [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] ; then
    # Print helpFunction in case parameters are empty
    helpFunction
  else
    deploy_list=("$@")
  fi

# Display list of stacks to be deployed
  echo "*** DEPLOYING LISTED STACK(S) ***"
  # Remove duplicate entries in deploy_list
    deploy_list=(`for stack in "${deploy_list[@]}" ; do echo "${stack}" ; done | sort -u`)
  # Remove 'traefik' from the deploy_list array
    for i in "${!deploy_list[@]}"; do
      if [[ "${deploy_list[i]}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
        unset 'deploy_list[i]'
      fi
    done
  # Add 'traefik' stack as first item in deploy_list array
    if [ "$(docker service ls --filter name=traefik -q)" = "" ]; then
      # Create required traefik files
      #rm "${appdata_folder}"/traefik/{traefik.log,acme.json} # Not sure if this is required. Certs are auto-updated, and why remove previous logs?
      touch "${appdata_folder}"/traefik/{access.log,traefik.log,acme.json}
      chmod 600 "${appdata_folder}"/traefik/{access.log,traefik.log,acme.json}
      deploy_list=( "traefik" "${deploy_list[@]}" )
      echo " -> ${deploy_list[@]}"
      echo
#      echo "*** TRAEFIK MUST BE THE FIRST DEPLOYED SWARM STACK ***"
#      echo
    else
      echo " -> ${deploy_list[@]}"
      echo
    fi
  # Create 'traefik_public' overlay network
    if [ "$(docker network ls --filter name=traefik -q)" = "" ]; then
      echo "*** CREATING OVERLAY NETWORK ***"
      docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable traefik_public
      echo "***** OVERLAY NETWORK CREATED, WAITING 15 SECONDS *****"
      sleep 15
      echo
    fi

# Deploy indicated stack(s)
  for stack in "${deploy_list[@]}"; do
    echo "*** DEPLOYING '${stack}' ***"
    # The below two lines are needed only if the '.env' file redirect is used
    ln -sf "${configs_folder}"/"${variables_file}" "${configs_folder}"/"${stack}"/.env
    sleep 1
    #. ${scripts_folder}/docker_stack_folders.sh "${stack}"
    docker stack deploy ${stack} -c "${configs_folder}"/"${stack}"/"${stack}".yml
    sleep 1
    if [ "$(docker service ls --filter name="${stack}" -q)" = "" ]; then
      echo
      echo "**** ... ERROR ... '${stack}' *NOT* DEPLOYED! ****"
    else
      echo "**** '${stack}' DEPLOYED, WAITING 10 SECONDS ****"
      sleep 10
    fi
  done

# Clear the 'deploy_list' array now that we are done with it
  unset deploy_list IFS

# Print script complete message
  echo
  echo "****** STACK DEPLOY SCRIPT COMPLETE ******"
  echo