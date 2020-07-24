#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/bash-colors.env
  source /share/docker/swarm/swarm_vars.env

# Perform prune operation with/without '-f' option
  case "${1}" in 
    "-h"|"-help") helpFunction ;;
    "-f"|"-force")
      echo -e "${blu}[-> PRUNING THE DOCKER SYSTEM <-]${DEF}"
        docker system prune -f
        echo
      ;;
    *)
    echo -e "${blu}[-> REMOVE UNUSED DOCKER ${CYN}VOLUMES${DEF} "
      #docker volume ls -qf dangling=true | xargs -r docker volume rm
      VOLUMES_DANGLING=$(docker volume ls -qf dangling=true)
      if [[ ! ${VOLUMES_DANGLING} = "" ]];
      then docker volume rm ${NETWORKS_DANGLING}
      else prnt " - ${YLW}No dangling volumes to remove.${DEF}"
      fi
      echo
    #echo -e "[-> REMOVE UNUSED DOCKER ${CYN}NETWORKS${DEF} "
    #  #docker network ls | grep "bridge"
    #  NETWORKS_BRIDGED="$(docker network ls | grep "bridge" | awk '/ / { print $1 }')"
    #  if [[ ! ${NETWORKS_BRIDGED} = "" ]];
    #  then docker network rm ${NETWORKS_BRIDGED}
    #  else prnt " - No disconnected, bridged networks to remove."
    #  fi
    #  echo
    echo -e "${blu}[-> REMOVE UNUSED DOCKER ${CYN}IMAGES${DEF}"
      #docker images
      #IMAGES_DANGLING=$(docker images --filter "dangling=true" -q --no-trunc)
      IMAGES_DANGLING="$(docker images --filter "dangling=false" -q)"
      if [[ ! ${IMAGES_DANGLING} = "" ]]
      then docker rmi ${IMAGES_DANGLING}
      else prnt " - ${YLW}No dangling images to remove.${DEF}"
      fi
      #docker images | grep "none"
      IMAGES_NONE=$(docker images | grep "none" | awk '/ / { print $3 }')
      if [[ ! ${IMAGES_NONE} = "" ]];
      then docker rmi ${IMAGES_NONE}
      else prnt " - No unassigned images to remove."
      fi
      echo
    echo -e "${blu}[-> REMOVE UNUSED DOCKER ${CYN}CONTAINERS${DEF}"
      #docker ps
      #docker ps -a
      CONTAINERS_EXITED=$(docker ps -qa --no-trunc --filter "status=exited")
      if [[ ! ${CONTAINERS_EXITED} = "" ]];
      then docker rm ${CONTAINERS_EXITED}
      else prnt " - ${YLW}No exited containers to remove.${DEF}"
      fi
      echo
    ;;
  esac

# Script completion notice
  echo -e "${GRN}[-- DOCKER SYSTEM PRUNE COMPLETE --]${DEF}"
  echo