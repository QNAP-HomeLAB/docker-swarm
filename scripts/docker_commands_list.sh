#!/bin/bash

# Load config variables from file
  source /share/swarm/configs/swarm_vars.conf

  echo
  echo "Custom bash commands created to manage a QNAP based Docker Swarm."
  echo
  echo "COMMAND  | SCRIPT FILE NAME     | COMMAND DESCRIPTION"
  echo
  echo " dlist   | docker_commands_list | lists the custom Docker Swarm commands created for managing a QNAP Docker Swarm"
  echo " dcd     | docker_compose_dn    | stops (brings 'down') a docker-compose container"
  echo " dcu     | docker_compose_up    | starts (brings 'up') a docker-compose container"
  echo " dcl     | docker_compose_logs  | displays 50 log entries for the indicated docker-compose container"
  echo " dln     | docker_list_network  | lists currently created docker networks"
  echo " dls     | docker_list_stack    | lists currently deployed docker swarm stacks and services"
  echo " dlv     | docker_list_volume   | lists currently unused docker volumes"
  echo " dsb     | docker_stack_bounce  | removes a single stack then recreates it using '$configs_folder/<stackname>/<stackname>.yml'"
  echo "  bounce | docker_stack_bounce  | removes all active stacks then recreates them using '$configs_folder/<stackname>/<stackname>.yml'"
  echo " dsd     | docker_stack_deploy  | deploys a single stack, or a default list of stacks defined in '$configs_folder/swarm_stacks.conf'"
  echo "  dsup   | docker_stack_deploy  | same as 'dsd -all' which deploys all stacks with a config folder listed in '$configs_folder'/"
  echo " dsf     | docker_stack_folders | creates the folder structure for (1 - 9 listed) stacks"
  echo " dsr     | docker_stack_remove  | removes a single stack, or all stacks listed via 'docker stack ls'"
  echo "  dsclr  | docker_stack_remove  | same as 'dsr -all', does not accept options"
  echo " dwinit  | docker_swarm_init    | updates 'docker_swarm_init.sh' from github, initializes swarm, creates overlay network, and deploys stacks"
  echo " dwup    | docker_swarm_setup   | initializes a new swarm, creates an overlay network, then deploys traefik"
  echo " dwlv    | docker_swarm_leave   | USE WITH CAUTION! - prunes docker system, leaves swarm"
  echo "  dwclr  | docker_swarm_leave   | USE WITH CAUTION! - removes ALL stacks, prunes docker system, leaves swarm"
  echo " dprn    | docker_system_prune  | prunes the Docker system of unused images, networks, volumes, and containers"
  echo " dve     | docker_service_error | lists errors for the indicated 'stackname_appname' (both names are required)"
  echo " dvl     | docker_service_logs  | lists logs for the indicated 'stackname_appname' (both names are required)."
  echo
