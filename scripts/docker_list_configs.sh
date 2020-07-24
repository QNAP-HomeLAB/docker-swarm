#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/bash-colors.env
  source /share/docker/compose/compose_vars.env
  source /share/docker/swarm/swarm_vars.env
  source /share/docker/swarm/swarm_stacks.conf
  unset stack_folders IFS
  unset stacks_list IFS
  unset configs_path IFS
  unset compose IFS

# Help message for script
  helpFunction(){
    echo -e "${blu}[-> This script lists the existing 'stackname.yml' files in the ${YLW}../swarm/${blu} or ${YLW}../compose/${blu} folder structure. <-]${DEF}"
    echo
    echo -e "  SYNTAX: # dlc -${CYN}option${DEF}"
    echo -e "    VALID OPTIONS:"
    echo -e "      -${CYN}c${DEF} | -${CYN}compose${DEF}  Displays stacks with config files in the ${YLW}..${compose_configs}/${def} filepath."
    echo -e "      -${CYN}s${DEF} | -${CYN}swarm${DEF}    Displays stacks with config files in the ${YLW}..${swarm_configs}/${def} filepath."
    # echo -e "      -${CYN}listed${DEF}       Displays stacks in the '${CYN}listed${DEF}' array of stacks defined in '${YLW}${swarm_configs}/${CYN}swarm_stacks.conf${DEF}'"
    # echo -e "      -${CYN}default${DEF}      Displays stacks in the '${CYN}default${DEF}' array of stacks defined in '${YLW}${swarm_configs}/${CYN}swarm_stacks.conf${DEF}'"
    echo -e "      -${CYN}h${DEF} | -${CYN}help${DEF}     Displays this help message."
    echo -e "    NOTE: a valid option from above is required for this script to function"
    echo
    exit 1 # Exit script after printing help
    }

# determine configuration type to query
  case "$1" in
    ""|"-h"|"-help"|"--help") helpFunction ;;
    # "-c"|"-compose") configs_path=${compose_configs}; compose="-compose" ;;
    "-c"|"-compose") configs_path="/share/docker/compose/configs"; compose="-compose" ;;
    "-s"|"-swarm") configs_path=${swarm_configs} ;;
  esac

# descriptive script header
  echo -e "${blu}[-> EXISTING DOCKER ${YLW}${configs_path}/${blu} CONFIGURATION FILES <-]${DEF}"
# populate list of configuration folders
  IFS=$'\n' stack_folders=( $(cd "${configs_path}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') );
# remove '.' folder name from printed list
  for i in "${!stack_folders[@]}"; do
    if [[ "${stack_folders[i]}" = "." ]]; then
      unset 'stack_folders[i]'
    fi
    if [[ -f "${configs_path}"/"${stack_folders[i]}"/"${stack_folders[i]}${compose}.yml" ]];
      then
        stacks_list="${stacks_list} ${stack_folders[i]}"
    fi
  done

# display list of configuration folders
  if [[ ! ${stacks_list} ]];
  then echo -e " -> ${YLW}no configuration files exist${DEF}"
  else echo -e " ->${CYN}${stacks_list[@]}${DEF}"
  fi
  echo

# clear variable for future use
  unset stack_folders IFS
  unset stacks_list IFS
  unset configs_path IFS
  unset compose IFS
