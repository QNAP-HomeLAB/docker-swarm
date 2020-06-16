#!/bin/bash

echo "***** Creating Docker 'config' variables *****"
# define config variables
echo "DOMAIN.TLD" | docker config create var_domain -
echo "cloudflare" | docker config create var_certresolver -
echo "America" | docker config create var_tz_region -
echo "Chicago" | docker config create var_tz_city -
echo "1000" | docker config create var_usr -
echo "100" | docker config create var_grp -

#echo "" | docker config create var_ -
