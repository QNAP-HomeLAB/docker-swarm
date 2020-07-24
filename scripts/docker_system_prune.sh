#!/bin/bash
# printed line colors
  pRED () { printf "\e[1;31m$1\e[0m\n"; } # red
  pGRN () { printf "\e[1;32m$1\e[0m\n"; } # green
  pYLW () { printf "\e[1;33m$1\e[0m\n"; } # yellow
  pBLU () { printf "\e[1;34m$1\e[0m\n"; } # blue
  pMGN () { printf "\e[1;35m$1\e[0m\n"; } # magenta
  pCYN () { printf "\e[1;36m$1\e[0m\n"; } # cyan
  prnt () { printf "\e[1;37m$1\e[0m\n"; } # print
  pqry () { printf "\e[1;37m$1\e[0m"; }   # query
# text snippet colors
  RED='\e[0;31m'  # red 
  GRN='\e[0;32m'  # green
  YLW='\e[0;33m'  # yellow
  BLU='\e[0;34m'  # blue
  MGN='\e[0;35m'  # magenta
  CYN='\e[0;36m'  # cyan
  WHT='\e[0;37m'  # white
  NC='\e[0m'      # reset

# Perform prune operation with/without '-f' option
  case $1 in 
    '-f')
    pBLU "[-> PRUNING THE DOCKER SYSTEM"
      docker system prune -f
      echo
    ;;
    *)
    pBLU "[-> REMOVE UNUSED DOCKER ${CYN}VOLUMES${NC} "
      #docker volume ls -qf dangling=true | xargs -r docker volume rm
      VOLUMES_DANGLING=$(docker volume ls -qf dangling=true)
      if [[ ! ${VOLUMES_DANGLING} = "" ]];
      then docker volume rm ${NETWORKS_DANGLING}
      else prnt " - ${YLW}No dangling volumes to remove.${NC}"
      fi
      echo
    #pBLU "[-> REMOVE UNUSED DOCKER ${CYN}NETWORKS${NC} "
    #  #docker network ls | grep "bridge"
    #  NETWORKS_BRIDGED="$(docker network ls | grep "bridge" | awk '/ / { print $1 }')"
    #  if [[ ! ${NETWORKS_BRIDGED} = "" ]];
    #  then docker network rm ${NETWORKS_BRIDGED}
    #  else prnt " - No disconnected, bridged networks to remove."
    #  fi
    #  echo
    pBLU "[-> REMOVE UNUSED DOCKER ${CYN}IMAGES${NC} "
      #docker images
      #IMAGES_DANGLING=$(docker images --filter "dangling=true" -q --no-trunc)
      IMAGES_DANGLING="$(docker images --filter "dangling=false" -q)"
      if [[ ! ${IMAGES_DANGLING} = "" ]]
      then docker rmi ${IMAGES_DANGLING}
      else prnt " - ${YLW}No dangling images to remove.${NC}"
      fi
      #docker images | grep "none"
      IMAGES_NONE=$(docker images | grep "none" | awk '/ / { print $3 }')
      if [[ ! ${IMAGES_NONE} = "" ]];
      then docker rmi ${IMAGES_NONE}
      else prnt " - No unassigned images to remove."
      fi
      echo
    pBLU "[-> REMOVE UNUSED DOCKER ${CYN}CONTAINERS${NC} "
      #docker ps
      #docker ps -a
      CONTAINERS_EXITED=$(docker ps -qa --no-trunc --filter "status=exited")
      if [[ ! ${CONTAINERS_EXITED} = "" ]];
      then docker rm ${CONTAINERS_EXITED}
      else prnt " - ${YLW}No exited containers to remove.${NC}"
      fi
      echo
    ;;
  esac

# Script completion notice
  pGRN "[-- DOCKER SYSTEM PRUNE COMPLETE --]"
  echo