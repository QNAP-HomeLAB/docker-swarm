#!/bin/bash

# Load config variables from file
  source /share/swarm/configs/swarm_vars.conf

  echo
  echo "COMMAND -- SCRIPT FILE NAME     -- COMMAND DESCRIPTION"
  echo
  echo " dlist  -- docker_commands_list -- lists the custom Docker Swarm commands created for managing a QNAP Docker Swarm"
  echo " dcd    -- docker_compose_dn    -- stops (brings 'down') a docker-compose container"
  echo " dcu    -- docker_compose_up    -- starts (brings 'up') a docker-compose container"
  echo " dsb    -- docker_stack_bounce  -- removes a single stack then recreates it using '$configs_folder/stackname/stackname.yml'"
  echo " dsd    -- docker_stack_deploy  -- deployes a single stack, or a default list of stacks defined in '$configs_folder/swarm_stacks.conf'"
  echo " dsu    -- docker_stack_up      -- deploys all stacks defined in '$configs_folder/swarm_stacks.conf'"
  echo " dsf    -- docker_stack_folders -- creates the folder structure for (1 - 9 listed) stacks"
  echo " dsr    -- docker_stack_remove  -- removes a single stack, or all stacks listed via 'docker stack ls'"
  echo " dsc    -- docker_stack_clear   -- removes all stacks"
  echo " dwup   -- docker_swarm_setup   -- creates a new swarm, and overlay network, then starts all stacks declared in '$configs_folder'"
  echo " dwlv   -- docker_swarm_leave   -- prunes docker system, leaves swarm - USE WITH CAUTION!"
  echo " dwrm   -- docker_swarm_remove  -- removes all stacks, prunes docker system, leaves swarm - USE WITH CAUTION!"
  echo " dprn   -- docker_system_prune  -- prunes the Docker system of unused images, networks, and containers"
  echo
