#!/bin/bash

# Help message for script
helpFunction(){
  echo 
  echo "This script removes a single or pre-defined list of Docker Swarm stack"
  echo
  echo "SYNTAX: # dsr stack_name"
  echo "SYNTAX: # dsr -option"
  echo "  VALID OPTIONS:"
  echo "        -all          Removes all stacks with a corresponding folder inside the '../configs/' path."
  echo "        -listed       Removes stacks listed in the '../configs/swarm_stacks.conf' config file 'stacks_listed' array."
  echo "        -default      Removes a default list of stacks defined in the '../configs/swarm_vars.conf' variable file."
  echo "        -h || -help   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Load config variables from file
  source /share/swarm/configs/swarm_stacks.conf
  source /share/swarm/configs/swarm_vars.conf
  remove_list=""

# Define which stack to remove using command options
  if [[ $1 = "-all" ]]; then
    IFS=$'\n' remove_list=( $(docker stack ls --format {{.Name}}) ); 
  elif [[ $1 = "-listed" ]]; then
    IFS=$'\n' remove_list=( "${stacks_listed[@]}" );
  elif [[ $1 = "-default" ]]; then
    IFS=$'\n' remove_list=( "${stacks_default[@]}" );
  elif [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] ; then
    helpFunction
  else
      remove_list=("$@")
  fi

# Display list of stacks to be removed
  echo "****** REMOVING LISTED STACK(S) ******"
  # Remove duplicate entries in remove_list
    remove_list=(`for stack in "${remove_list[@]}" ; do echo "$stack" ; done | sort -u`)
  # Remove 'traefik' from the remove_list array
    for i in "${!remove_list[@]}"; do
      if [[ "${remove_list[i]}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
        unset 'remove_list[i]'
      fi
    done
  # If removing '-all' stacks, add 'traefik' back in as last stack in remove_list
    if [[ "$1" = [tT][rR][aA][eE][fF][iI][kK] ]] || [[ $1 = "-all" ]]; then
      if [ "$(docker service ls --filter name=traefik -q)" != "" ]; then
        remove_list=( "${remove_list[@]}" "traefik" )
        echo " -> ${remove_list[@]}"
        echo
        echo "*** 'traefik' MUST BE THE LAST REMOVED SWARM STACK ***"
        echo
      fi
    elif [[ $1 = "traefik" ]]; then
      if [[ "${bounce_list[@]}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
        input=yes;
      else
        read -r -p "Are you sure you want to remove the 'traefik' stack? This could cause apps to be inaccessible. [Y/n] " input
      fi
      case $input in
        [yY][eE][sS]|[yY])
          remove_list=( "${remove_list[@]}" "traefik" )
          echo " -> ${remove_list[@]}"
          echo
          ;;
        [nN][oO]|[nN])
          echo "** 'traefik' STACK WILL NOT BE REMOVED **";
          ;;
        *)
          echo "INVALID INPUT: Must be any case-insensitive variation of '(y)es' or '(n)o'."
          exit 1
          ;;
      esac
    else
      echo " -> ${remove_list[@]}"
      echo
    fi

# Remove indicated stack(s)
  for stack in "${remove_list[@]}"; do
    echo "**** REMOVING '$stack' ****"
    docker stack rm "$stack"
    echo "*** '$stack' REMOVED, WAITING 10 SECONDS ***"
    sleep 10
  done

# Clear the 'remove_list' array now that we are done with it
  unset remove_list IFS
  echo

# Pruning the system is optional but recommended
  . ${scripts_folder}/docker_system_prune.sh -f

# Print script complete message
  echo "****** STACK REMOVE SCRIPT COMPLETE ******"
  echo