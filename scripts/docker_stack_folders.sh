#!/bin/bash

# Help message for script
helpFunction(){
  echo
  echo "Script to create Drauku's folder structure, modified from gkoerk's famously awesome folder structure for stacks."
  echo
  echo "SYNTAX: dsf <folder-name1> <folder-name2> ... <folder-name9>"
  echo "  Enter up to nine(9) folder names in a single command, separated by a 'space' character: "
  echo "SYNTAX: dsf -option"
  echo "  VALID OPTIONS:"
  echo "    -h || -help   Displays this help message."
  echo
  echo "The below folder structure is created for each 'folder-name' entered in this command:"
  echo "    /share/swarm/appdata/<folder-name>"
  echo "    /share/swarm/configs/<folder-name>"
  echo "    /share/swarm/runtime/<folder-name>"
#  echo "    /share/swarm/secrets/<folder-name>"
  echo
  exit 1 # Exit script after printing help
}

# Load config variables from file
  source /share/swarm/configs/swarm_stacks.conf
  source /share/swarm/configs/swarm_vars.conf

# Print helpFunction in case parameters are empty, or -h option entered
  if [[ -z "$1" ]] || [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] || [[ $1 = "--help" ]] ; then
    helpFunction
  fi

# Create folder structure
  mkdir -p ${appdata_folder}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
  mkdir -p ${configs_folder}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
  mkdir -p ${runtime_folder}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
  #mkdir -p $secrets_folder/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
  stacks_list="$@"
  for stack in "${!stacks_list[@]}"; do
    #mkdir -p ${appdata_folder}/${stack}
    #mkdir -p ${configs_folder}/${stack}
    #mkdir -p ${runtime_folder}/${stack}
    if [[ "${stacks_list[stack]}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
      if [ ! -f ${appdata_folder}/traefik/{traefik.log,acme.json} ]; then
          echo "File not found!"
      # Create required traefik files
      #rm "${configs_folder}"/traefik/{traefik.log,acme.json} # Not sure if this is required, why remove previous logs/certs?
      touch ${appdata_folder}/traefik/{traefik.log,acme.json}
      chmod 600 ${appdata_folder}/traefik/{traefik.log,acme.json}
      fi
    fi
  done
  echo "DOCKER SWARM FOLDER STRUCTURE CREATED FOR LISTED STACKS"
  echo " - $@"
  echo

# Change all swarm folders to the 'dockuser' 'user:group' values
  #chown -R $var_user:$var_group $swarm_folder
  #echo "FOLDER OWNERSHIP UPDATED"
  #echo 

# Print script complete message
  echo "DOCKER SWARM STACK FOLDER CREATION SCRIPT COMPLETE"
  echo