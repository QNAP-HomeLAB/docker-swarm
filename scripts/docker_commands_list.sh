#!/bin/bash

## Docker shortcut commands and aliases file
# Load config variables from file
  source /share/docker/scripts/bash-colors.env
  source /share/docker/compose/compose_vars.env
  source /share/docker/swarm/swarm_vars.env

helpFunction(){
  echo -e "${blu}[-> Custom bash commands created to manage a QNAP based Docker Swarm <-]${DEF}"
  echo
  echo -e " ${blu} COMMAND       -- SCRIPT FILE NAME     -- COMMAND DESCRIPTION${DEF}"
  echo -e "  ${cyn}dlist${DEF}         -- ${ylw}docker_commands_list${DEF} -- lists the custom Docker Swarm commands created for managing a QNAP Docker Swarm"
  echo -e "  ${cyn}dcd${DEF}           -- ${ylw}docker_compose_dn${DEF}    -- stops (brings 'down') a docker-compose container"
  echo -e "  ${cyn}dcu${DEF}           -- ${ylw}docker_compose_up${DEF}    -- starts (brings 'up') a docker-compose container"
  echo -e "  ${cyn}dln${DEF}           -- ${ylw}docker_list_network${DEF}  -- lists currently created docker networks"
  echo -e "  ${cyn}dls${DEF}           -- ${ylw}docker_list_stack${DEF}    -- lists currently deployed docker swarm stacks and services"
  echo -e "  ${cyn}dsb | bounce${DEF}  -- ${ylw}docker_stack_bounce${DEF}  -- removes stack then recreates it using '${ylw}\$swarm_configs/${cyn}stackname${DEF}/${cyn}stackname.yml${DEF}' (bounce == '${cyn}dsb -all${DEF}')"
  echo -e "  ${cyn}dsd | dsup${DEF}    -- ${ylw}docker_stack_deploy${DEF}  -- deploys stack, or a list of stacks defined in '${ylw}\$swarm_configs/${cyn}swarm_stacks.conf${DEF}' (dsup == '${cyn}dsd -all${DEF}')"
  echo -e "  ${cyn}dsr | dsclr${DEF}   -- ${ylw}docker_stack_remove${DEF}  -- removes stack, or ${cyn}-all${DEF} stacks listed via 'docker stack ls' (dsclr == '${cyn}dsr -all${DEF}')"
  echo -e "  ${cyn}dsf${DEF}           -- ${ylw}docker_stack_folders${DEF} -- creates swarm folder structure for (1 - 9 listed) stacks"
  echo -e "  ${cyn}dscfg${DEF}         -- ${ylw}docker_stack_configs${DEF} -- lists existing 'stackname.yml' config files in the '${ylw}\$swarm_configs/' folder structure"
  echo -e "  ${cyn}dwup | dwinit${DEF} -- ${ylw}docker_swarm_setup${DEF}   -- swarm setup script, (${cyn}dwinit${DEF} == 'dwup -init' which downloads install script from github)"
  echo -e "  ${cyn}dwlv | dwclr${DEF}  -- ${ylw}docker_swarm_leave${DEF}   -- USE WITH CAUTION! - prunes docker system, leaves swarm (dwclr == 'dwlv -${cyn}all${DEF}')"
  echo -e "  ${cyn}dprn${DEF}          -- ${ylw}docker_system_prune${DEF}  -- prunes the Docker system of unused images, networks, and containers"
  echo
  }

# logical action check
  if [[ $1 = "-execute" ]]; then
    # docker_commands_list -- lists the below custom docker commands
    dlist(){ 
      bash /share/docker/scripts/docker_commands_list.sh "$1"
      }
    # docker_list_configs -- lists existing compose stack config files
    dccfg(){ 
      bash /share/docker/scripts/docker_list_configs.sh -compose 
      }
    # docker_compose_dn -- stops the entered container
    dcd(){ 
      bash /share/docker/scripts/docker_compose_dn.sh "$1" 
      }
    # docker_compose_up -- starts the entered container using preconfigured docker_compose files
    dcu(){ 
      bash /share/docker/scripts/docker_compose_up.sh "$1" 
      }
    # docker_compose_logs -- displays 50 log entries for the indicated docker-compose container
    dcl(){ 
      bash /share/docker/scripts/docker_compose_logs.sh "$1" 
      }
    # docker_list_configs -- lists existing stack config files for either swarm or compose filepaths
    dlc(){ 
      bash /share/docker/scripts/docker_list_configs.sh $1 
      }
    # docker_list_stack -- lists all stacks and number of services inside each stack
    dls(){ 
      bash /share/docker/scripts/docker_list_stack.sh 
      }
    # docker_list_network -- lists current docker networks
    dln(){ 
      bash /share/docker/scripts/docker_list_network.sh 
      }
    # docker_list_volume -- lists unused docker volumes
    dlv(){ 
      bash /share/docker/scripts/docker_list_volume.sh 
      }
    # docker_stack_bounce -- removes then re-deploys the listed stacks or '-all' stacks with config files in the folder structure
    dsb(){ 
      bash /share/docker/scripts/docker_stack_bounce.sh "$1" 
      }
    bounce(){ 
      bash /share/docker/scripts/docker_stack_bounce.sh -all 
      }
    # docker_stack_deploy -- deploys a single stack as defind in the configs folder structure
    dsd(){ 
      bash /share/docker/scripts/docker_stack_deploy.sh "$1" 
      }
    dsup(){ 
      bash /share/docker/scripts/docker_stack_deploy.sh -all 
      }
    # docker_stack_folders -- creates the folder structure required for each listed stack name (up to 9 per command)
    dsf(){ 
      bash /share/docker/scripts/docker_stack_folders.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" 
      }
    # docker_stack_remove -- removes a single stack
    dsr(){ 
      bash /share/docker/scripts/docker_stack_remove.sh "$1" 
      }
    # docker_stack_remove -- removes all swarm stack
    dsclr(){ 
      bash /share/docker/scripts/docker_stack_remove.sh -all 
      }
    # docker_list_configs -- lists existing swarm stack config files
    dwcfg(){ 
      bash /share/docker/scripts/docker_list_configs.sh -swarm 
      }
    # docker_swarm_initialize -- Downloads and executes the docker_swarm_setup.sh script
    dwinit(){ 
      bash /share/docker/scripts/docker_swarm_init.sh traefik
      # bash mkdir -pm 766 /share/docker/scripts && curl -fsSL https://raw.githubusercontent.com/Drauku/QNAP-Docker-Swarm-Setup/master/scripts/docker_swarm_setup.sh > /share/docker/scripts/docker_swarm_setup.sh && . /share/docker/scripts/docker_swarm_setup.sh -setup 
      }
    dwup(){ 
      bash /share/docker/scripts/docker_swarm_init.sh "$1" 
      }
    # docker_swarm_leave -- LEAVES the docker swarm. USE WITH CAUTION!
    dwlv(){ 
      bash /share/docker/scripts/docker_swarm_leave.sh "$1" 
      }
    # docker_swarm_clear -- REMOVES all swarm stacks, REMOVES the overlay network, and LEAVES the swarm. USE WITH CAUTION!
    dwclr(){ 
      bash /share/docker/scripts/docker_swarm_leave.sh -all 
      }
    # docker_system_prune -- prunes the docker system (removes unused images and containers and networks)
    dprn(){ 
      bash /share/docker/scripts/docker_system_prune.sh 
      }
    # docker_service_errors -- displays 'docker ps --no-trunk <servicename>' command output
    dve(){ 
      bash /share/docker/scripts/docker_service_error.sh "$1" 
      }
    dverror(){ 
      bash /share/docker/scripts/docker_service_error.sh "$1" 
      }
    # docker_service_logs -- displays 'docker service logs <servicename>' command output
    dvl(){ 
      bash /share/docker/scripts/docker_service_logs.sh "$1" 
      }
    dvlogs(){ 
      bash /share/docker/scripts/docker_service_logs.sh "$1" 
      }
    echo -e "[-> Docker aliases for QNAP devices imported <-]"
  else helpFunction;
  fi
