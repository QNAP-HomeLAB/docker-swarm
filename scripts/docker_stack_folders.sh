#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/bash-colors.env
  source /share/docker/swarm/swarm_stacks.conf
  source /share/docker/swarm/swarm_vars.env

# Help message for script
helpFunction(){
  echo -e "${blu}T[-> his script creates ${CYN}Drauku's${blu} folder structure for the listed stack(s). <-]${DEF}"
  echo -e "      ${blu}(modified from ${CYN}gkoerk's${blu} famously awesome folder structure for stacks.)${DEF}"
  echo
  echo -e "  Enter up to nine(9) stack_names in a single command, separated by a 'space' character: "
  echo -e "    SYNTAX: dsf ${CYN}stack_name1${DEF} ${CYN}stack_name2${DEF} ... ${CYN}stack_name9${DEF}"
  echo -e "    SYNTAX: dsf -${CYN}option${DEF}"
  echo -e "      VALID OPTIONS:"
  echo -e "        -${CYN}h${DEF} || -${CYN}help${DEF}   Displays this help message."
  echo
  echo -e "    The below folder structure is created for each 'stack_name' entered with this command:"
  echo -e "        ${YLW}${swarm_appdata}/${CYN}stack_name${DEF}"
  echo -e "        ${YLW}${swarm_configs}/${CYN}stack_name${DEF}"
  # echo -e "        ${YLW}${swarm_runtime}/${CYN}stack_name${DEF}"
  # echo -e "        ${YLW}/share/swarm/secrets/${CYN}stack_name${DEF}"
  echo
  exit 1 # Exit script after printing help
}

# Print helpFunction in case parameters are empty, or -h option entered
  if [[ -z "$1" ]] || [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] || [[ $1 = "--help" ]] ; then
    helpFunction
  fi

  # pCYN "[-> CREATE DOCKER SWARM FOLDER STRUCTURE FOR LISTED STACKS <-]"
  # echo " -> $@"
  # echo

# Create folder structure
  mkdir -p ${swarm_appdata}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
  mkdir -p ${swarm_configs}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
  # mkdir -p ${swarm_runtime}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
  # mkdir -p ${secrets_folder}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
  stacks_list="$@"
  # for stack in "${!stacks_list[@]}"; do
  #   mkdir -p ${swarm_appdata}/${stacks_list[stack]}
  #   mkdir -p ${swarm_configs}/${stacks_list[stack]}
  #   mkdir -p ${swarm_runtime}/${stacks_list[stack]}
  # done

# Change all swarm folders to the 'dockuser' 'user:group' values
  # chown -R ${var_user}:${var_group} ${docker_folder}
  # echo "FOLDER OWNERSHIP UPDATED"
  # echo 

# Print script complete message
  echo -e "${GRN} -> SWARM STACK FOLDERS CREATED${DEF}"
  # echo