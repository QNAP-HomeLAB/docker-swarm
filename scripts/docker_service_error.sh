#!/bin/bash

# Help message for script
helpFunction(){
  echo 
  echo "This script lists errors for the indicated 'stackname_appname' (both names are required)."
  echo
  echo "SYNTAX: # dve <servicename>"
  echo "SYNTAX: # dve -option"
  echo "  NOTE: <servicename> MUST consist of 'appname_servicename' as defined in the .yml file. ex: 'traefik_app' or 'traefik_whoami'"
  echo "  VALID OPTIONS:"
  echo "    -h || -help   Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Load config variables from file
  source /share/swarm/configs/swarm_vars.conf

# Print helpFunction in case parameters are empty, or -h option entered
  if [[ -z "$1" ]] || [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] || [[ $1 = "--help" ]] ; then
    helpFunction
  fi

# Check the indicated swarm service for errors
  docker service ps --no-trunc "${1}"