#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/bash-colors.env

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script lists logs for the indicated 'stackname_appname' (both names are required). <-]${def} "
  echo
  echo -e "SYNTAX: # dve ${cyn}servicename${def}"
  echo -e "SYNTAX: # dve -option"
  echo -e "  NOTE: <servicename> MUST consist of 'appname_servicename' as defined in the .yml file. ex: 'traefik_app' or 'traefik_whoami'"
  echo -e "  VALID OPTIONS:"
  echo -e "    -h || -help   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Load config variables from file
  source /share/docker/swarm/swarm_vars.env

# Print helpFunction in case parameters are empty, or -h option entered
  if [[ -z "$1" ]] || [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] || [[ $1 = "--help" ]] ; then
    helpFunction
  fi

# Check the indicated swarm service for errors
  docker service logs "${1}"
  #docker service logs --no-trunc "${1}"