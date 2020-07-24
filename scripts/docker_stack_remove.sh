#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/bash-colors.env
  source /share/docker/swarm/swarm_stacks.conf
  source /share/docker/swarm/swarm_vars.env
  remove_list=""

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script removes a single or pre-defined list of Docker Swarm stack(s) <-]${DEF}"
  echo
  echo -e "  SYNTAX: # dsr ${CYN}stack_name${DEF}"
  echo -e "  SYNTAX: # dsr -${CYN}option${DEF}"
  echo -e "    VALID OPTIONS:"
  echo -e "      -${CYN}all${DEF}          Removes all stacks currently listed with 'docker stack ls' command."
  echo -e "      -${CYN}listed${DEF}       Removes the '${CYN}listed${DEF}' array of stacks defined in '${YLW}${swarm_configs}/${CYN}swarm_stacks.conf${DEF}'"
  echo -e "      -${CYN}default${DEF}      Removes the '${CYN}default${DEF}' array of stacks defined in '${YLW}${swarm_configs}/${CYN}swarm_stacks.conf${DEF}'"
  echo -e "      -${CYN}h${DEF} || -${CYN}help${DEF}   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Command header
  # echo -e "${blu}[-> DOCKER SWARM STACK REMOVAL SCRIPT <-]${def}"

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

# Remove indicated stacks
  # echo -e "${blu}[-> REMOVING LISTED STACK(S) <-]${def}"
  # de-duplicate remove_list entries
  remove_list=(`for stack in "${remove_list[@]}" ; do echo "$stack" ; done | sort -u`)
  # remove 'traefik' from the array
  for i in "${!remove_list[@]}"; do
    if [[ "${remove_list[i]}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
      unset 'remove_list[i]'
    fi
  done
  # If removing '-all' stacks, add 'traefik' back in as last stack in remove_list
  if [[ "$1" = [tT][rR][aA][eE][fF][iI][kK] ]] || [[ $1 = "-all" ]]; then
    if [[ "$(docker service ls --filter name=traefik -q)" != "" ]]; then
      remove_list=( "${remove_list[@]}" "traefik" )
    fi
  elif [[ $1 = "traefik" ]]; then
    if [[ "${bounce_list[@]}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
      input=yes;
    else
      printf "Are you sure you want to remove the '${CYN}traefik${DEF}' stack? This could cause apps to be inaccessible."; read -r -p "[(Y)es/(N)o] " input
    fi
    case $input in
      [yY][eE][sS]|[yY])
        #remove_list=( "${remove_list[@]}" "traefik" )
        # echo " -> ${remove_list[@]}"
        # echo
        ;;
      [nN][oO]|[nN])
        echo -e " -> '${CYN}traefik${DEF}' STACK WILL NOT BE REMOVED ";
        ;;
      *)
        echo -e " ${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."
        exit 1
        ;;
    esac
  fi
  # echo " -> ${remove_list[@]}"
  # echo

# Remove indicated stack(s)
  for stack in "${remove_list[@]}"; do
    if [ ! "$(docker service ls --filter label=com.docker.stack.namespace=$stack -q)" ];
      then echo -e " ${red}ERROR: ${YLW}STACK NAME${DEF} '${CYN}$stack${DEF}' ${YLW}NOT FOUND${DEF} ";
      # echo; exit 1
    else
      echo -e " -> REMOVE '${CYN}$stack${DEF}' STACK ";
      docker stack rm "$stack"
      [[ -f ${swarm_configs}/${stack}/.env ]] && rm -f ${swarm_configs}/${stack}/.env
      # Pause until stack is removed
      while [ "$(docker service ls --filter label=com.docker.stack.namespace=$stack -q)" ] || [ "$(docker network ls --filter label=com.docker.stack.namespace=$stack -q)" ]; 
        do sleep 1; 
      done
      echo -e " -- '${CYN}$stack${DEF}' STACK ${red}REMOVED${DEF} -- "
    fi
  done

# Clear the 'remove_list' array now that we are done with it
  unset remove_list IFS

# Print script complete message
  # echo -e "${GRN}[-- STACK REMOVE SCRIPT COMPLETE --]${DEF}"
  echo