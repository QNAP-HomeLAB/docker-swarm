#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/bash-colors.env
  source /share/docker/swarm/swarm_stacks.conf
  source /share/docker/swarm/swarm_vars.env
  deploy_list=""

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script deploys a single stack or a pre-defined list of Docker Swarm stack <-]${DEF}"
  echo
  echo -e "SYNTAX: # dsd ${CYN}stack_name${DEF}"
  echo -e "SYNTAX: # dsd ${CYN}-option${DEF}"
  echo -e "  VALID OPTIONS:"
  echo -e "        -${CYN}all${DEF}          Deploys all stacks with a corresponding folder inside the '${YLW}${swarm_configs}/${DEF}' path."
  echo -e "        -${CYN}listed${DEF}       Deploys the 'listed' array of stacks defined in '${YLW}${swarm_configs}/${CYN}swarm_stacks.conf${DEF}'"
  echo -e "        -${CYN}default${DEF}      Deploys the 'default' array of stacks defined in '${YLW}${swarm_configs}/${CYN}swarm_stacks.conf${DEF}'"
  echo -e "        -${CYN}h${DEF} || -${CYN}help${DEF}   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# define which stack(s) to load using command options
  #if [ $2 -eq 0 ] then 
    if [[ $1 = "-all" ]]; then
      if [[ "${bounce_list[@]}" = "" ]]; then
        IFS=$'\n' deploy_list=( $(cd "${swarm_configs}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') );
        if [[ "${deploy_list[i]}" = "." ]]; then
          unset 'deploy_list[i]'
        fi
      else
        IFS=$'\n' deploy_list=( "${bounce_list[@]}" );
      fi
    elif [[ $1 = "-listed" ]]; then IFS=$'\n' deploy_list=( "${stacks_listed[@]}" );
    elif [[ $1 = "-default" ]]; then IFS=$'\n' deploy_list=( "${stacks_default[@]}" );
    elif [[ -z "$1" ]] || [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] ; then helpFunction;
    else deploy_list=("$@")
    fi
  #else
  #fi

  # case $1 in
  #   "-all")
  #     if [[ "${bounce_list[@]}" = "" ]]; then
  #       IFS=$'\n' deploy_list=( $(cd "${swarm_configs}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') );
  #       if [[ "${deploy_list[i]}" = "." ]]; then unset 'deploy_list[i]'; fi
  #     else IFS=$'\n' deploy_list=( "${bounce_list[@]}" );
  #     fi
  #     ;;
  #   "-listed") IFS=$'\n' deploy_list=( "${stacks_listed[@]}" ) ;;
  #   "-default") IFS=$'\n' deploy_list=( "${stacks_default[@]}" ) ;;
  #   *) helpFunction ;;
  # esac

# display list of stacks to be deployed
  # echo -e "${blu}[-> DEPLOYING LISTED STACK(S) <-]${DEF}"
    # remove duplicate entries in deploy_list
    deploy_list=(`for stack in "${deploy_list[@]}" ; do echo "${stack}" ; done | sort -u`)
    # stacks_list=${deploy_list//[$'\t\r\n']}
    # echo -e " -> ${CYN}${deploy_list[@]}${DEF}"
    # echo " -> ${deploy_list[@]}"
    # echo
    # create 'traefik_public' overlay network
    if [[ ! "$(docker network ls --filter name=traefik_public -q)" ]]; then
      docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable traefik_public
      # Pause until 'network create' operation is finished
      while [[ ! "$(docker network ls --filter name=traefik_public -q)" ]]; do sleep 1; done
      echo -e " -> '${CYN}traefik_public${DEF}' OVERLAY NETWORK ${grn}CREATED${DEF}"
      echo
    fi


# perform stack setup and deployment tasks
  for stack in "${deploy_list[@]}"; do
    # check if indicated stack configuration file exists, otherwise exit
    if [[ -f "${swarm_configs}"/"${stack}"/"${stack}.yml" ]]; then
      echo -e " -> DEPLOY '${CYN}${stack}${DEF}' STACK "
      # check if required folders exist, create if missing
      if [[ ! -d "${swarm_appdata}"/"${stack}" || ! -d "${swarm_configs}"/"${stack}" ]]; then
        # echo -e "  -> ${YLW}Required folders${DEF} not found! Creating..."
        . ${docker_scripts}/docker_stack_folders.sh "${stack}"
      fi
      # check if required log files exist, create if missing
      if [[ ! -f ${swarm_appdata}/"${stack}"/access.log || ! -f ${swarm_appdata}/"${stack}"/"${stack}".log ]]; then
        touch ${swarm_appdata}/${stack}/{access.log,"${stack}".log}
        chmod 600 ${swarm_appdata}/${stack}/{access.log,"${stack}".log}
      fi
      # create required letsencrypt certificate file if not already made
      if [[ "${stack}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
        if [[ ! -f ${docker_folder}/certs/acme.json ]]; then
          mkdir -p ${docker_folder}/certs
          touch ${docker_folder}/certs/acme.json
          chmod 600 ${docker_folder}/certs/acme.json
        fi
      fi
      # deploy the requested stack
      docker stack deploy ${stack} -c "${swarm_configs}"/"${stack}"/"${stack}".yml
      sleep 1
      if [[ ! "$(docker service ls --filter name="${stack}" -q)" ]]; then
        echo -e " ${red}ERROR${DEF}: '${CYN}${stack}${DEF}' ${YLW}*NOT* DEPLOYED${DEF}"
      else
        # Pause until stack is deployed
        while [ ! "$(docker service ls --filter label=com.docker.stack.namespace=$stack -q)" ]; 
        do sleep 1; done
        echo -e " ++ '${CYN}$stack${DEF}' STACK ${GRN}DEPLOYED${DEF} ++ "
      fi
    else echo -e " ${red}ERROR${DEF}: '${CYN}${stack}${DEF}' ${YLW}CONFIG FILE DOES NOT EXIST${DEF}"
    fi
  done

# clear the 'deploy_list' array now that we are done with it
  unset deploy_list IFS

# print script complete message
  # echo
  # echo -e "[-- ${GRN}STACK DEPLOY SCRIPT COMPLETE${DEF} --]"
  echo