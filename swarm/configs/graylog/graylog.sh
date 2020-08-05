#!/bin/bash
source /share/swarm/configs/swarm_vars.conf

# Modify folder ownership to prevent Graylog permission issues
chown $var_usr:$var_grp ${appdata_folder}/graylog/journal
chown $var_usr:$var_grp ${appdata_folder}/graylog/config

# Elasticsearch needs the below command run via CLI to properly.
sysctl -w vm.max_map_count=262144
