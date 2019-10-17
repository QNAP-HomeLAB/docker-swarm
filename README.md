<a href="https://liberapay.com/gkoerk/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a>

<img src="http://img.shields.io/liberapay/patrons/gkoerk.svg?logo=liberapay">

Please consider donating above to support the [QNAP Unofficial Discord](https://discord.gg/rnxUPMd).

**Benefits** 
- Community Supporter role in Discord: Priority assistance with any issues.
- Access to my private Gitlab repository of existing Docker Swarm recipes
- Request & Vote on new recipes to publish
- Read access to my personal eBook library.
- Access to and advice on new properties for QNAP Unofficial: (i.e. Subreddit, Blog, Wiki, FAQs, CI/CD, Community Docker images, etc.)

---------------------------------------

# QNAP Docker Swarm Setup

A guide for configuring the docker swarm stack on QNAP devices with Container Station
---

## 1 - Preparation

- **Ports 80, 443, and 8080 *must be unused by your NAS.*** 
  - By default, QTS assigns ports 8080 and 443 as the default HTTP and HTTPS ports for the QNAP Web Admin Console, and assigns 80 as the default HTTP port for the native "Web Server" application. Each of these must be modified to proceed with this guide.
- Modify these ports as follows to ensure there will be no port conflicts with docker stacks:
  - **Change default System ports:** In QNAP GUI > General Settings, change the default HTTP port to `8880`, and the default HTTPS port to `8443`. 
  - **Change default Web Application ports:** In QNAP GUI > General Settings > Applications > Web Server, change the default HTTP port to `9880`, and the default HTTPS port to `9443`.
  - Unless currently in use, consider disabling both the Web Server and MySQL applications in the QNAP GUI Settings.
- **Ports 80 and 443 must be forwarded from your router to your NAS**. This is *possible* using UPNP in the QNAP GUI, but ***is not recommended!***
  - **Instead, disable UPNP at the router and manually forward ports 80 and 443 to your NAS.**

**In sum:**
- QTS System ports should be:
  - HTTP : 8880
  - HTTPS: 8443

- QTS Web Server application ports should be:
  - HTTP : 9880
  - HTTPS: 9443
---

## 2 - Container Station Steps
1. Backup what you have running now (if you don't have anything running yet, skip to Step 3 or 5)

2. Shutdown and remove all Containers:
  - Open SSH terminal to your NAS and run: 
    `docker system prune`
  - To ensure the network topography is reset, run:
    `docker network prune`
  - To be sure you don't have a swarm left hanging around, run:
    `docker swarm leave --force`

3. Remove Container Station

4. Reboot NAS ([example](https://i.imgur.com/voFkAt9.png))

5. Install Container Station, then launch once installed. 
  - Accept and create the `/Container` folder suggested when CS is launched for the first time.

6. Create a new user called _dockeruser_ 

7. Create the following folder shares *using the QTS web-GUI* at `ControlPanel >> Privilege >> Shared Folders` and give _dockeruser_ Read/Write permissions:
  - `/share/appdata`
    - Here we will add folders named < stack name >. This is where your application files live... libraries, artifacts, internal application configuration, etc. Think of this directory much like a combination of `C:/Windows/Program Files` and `C:\Users\<UserName>\AppData` in Windows.
  - `/share/appdata/config`
    - Here we will also add folders named < stack name >. Inside this structure, we will keep our actual _stack_name.yml_ files and any other necessary config files used to configure the docker stacks and images we want to run. This folder makes an excellent GitHub repository for this reason.
  - `/share/runtime`
    - This is a shared folder on a volume that does not get backed up. It is where living DB files and transcode files reside, so it would appreciate running on the fastest storage group you have or in cache mode or in Qtier (if you use it). Think of this like the `C:\Temp\` in Windows.

8. Install the `entware-std` package from the third-party QNAP Club repository. This is necessary in order to setup the shortcuts/aliases in Steps 18 & 19 by editing a permanent profile.
  - The preferred way to do this is to add the QNAP Club Repository to the App Center. Follow the [walkthrough instructions here](https://www.qnapclub.eu/en/howto/1). Note that I use the English translation of the QNAP Club website, but you may change languages (and urls) in the upper right language dropdown.
  - If you don't need the walkthrough, add the repository. (For English, go to App Center, Settings, App Repository, Add, `https://www.qnapclub.eu/en/repo.xml`).
  - If you have trouble locating the correct package below, the correct description begins `entware-3x and entware-ng merged to become entware.` The working link (as of publication) is here: https://www.qnapclub.eu/en/qpkg/556. 
    - If you **cannot** add the QNAP Club store to the App Center, you may manually download the qpkg file from that link and use it to install manually via the App Center, "Install Manually" button. This is **not preferred** as QNAP cannot check for and notify you of updates to the package.
  - Search for `entware-std` and install that package.

  **Important: *DO NOT* CHOOSE either the `entware-ng` or `entware-3x-std` packages. These have merged and been superceded by `entware-std`.**
---

## 3 - QNAP CLI Steps

1. **Run:** `id dockeruser` in terminal and note the 'uid' and 'gid'

2. **Run:** `docker network ls` The networks shown should match the following (except the generated NETWORK ID):

```[~] # docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
XXXXXXXXXXXX        bridge              bridge              local
XXXXXXXXXXXX        host                host                local
XXXXXXXXXXXX        none                null                local
```

3. Run: `docker swarm init --advertise-addr <YOUR NAS IP HERE>` - Use ***YOUR*** nas internal LAN IP address

4. **CHECKPOINT:** Run `docker network ls`. Does the list of networks contain one named `docker_gwbridge`?
The networks should match the following (except the generated NETWORK ID):

```[~] # docker network ls
NETWORK ID          NAME                   DRIVER              SCOPE
XXXXXXXXXXXX        bridge                 bridge              local
XXXXXXXXXXXX        docker_gwbridge        bridge              local
XXXXXXXXXXXX        host                   host                local
XXXXXXXXXXXX        ingress                overlay             swarm
XXXXXXXXXXXX        none                   null                local
```

**Important: If your configuration is lacking a docker_gwbridge or differs from this list**, please contact someone on the [QNAP Unofficial Discord](https://discord.gg/rnxUPMd) (ideally in the [#docker-stack channel](https://discord.gg/MzTNQkV)). Do not proceed beyond this point unless your configuration matches the one above, unless you embrace pain and failure and love very complicated problems that could be QNAP's fault.

5. **Run:** `docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable traefik_public`

6. **Run:** `mkdir -p /share/appdata/traefik`

7. **Run:** `mkdir -p /share/appdata/config/traefik`

8. **Run:** `mkdir -p /share/runtime/traefik`

9. Install nano or vi, whichever you are more comfortable with (e.g. Run `opkg install nano` or `opkg install vim`)
  - ***NOTE:*** You must have installed the `entware-std` package as detailed above in Section-2 Step-8 to be able to use the "opkg" installer.

10. **Run:** `nano /opt/etc/profile` (or `vi /opt/etc/profile` if that is your thing)
  - Add the following lines to the end of the file and save

  ***NOTE:*** If you use a Windows client to save the profile (or the scripts below), they will be saved with CR LF and will error.  
  Please set the file format to UNIX (LF) in order for the profile and scripts to work correctly.

```
dfc() {
    bash /share/appdata/scripts/folder_setup.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
}
dup() {
    bash /share/appdata/scripts/restart_stack.sh
}
dsd() {
    docker stack deploy "$1" -c /share/appdata/config/"$1"/"$1".yml
}
dsr() {
    docker stack rm "$1"
}
dss() {
    bash /share/appdata/scripts/setup_stack.sh
}
dsp() {
    bash docker system prune -f
}
dsrms() {
    bash /share/appdata/scripts/remove_stack.sh
}
bounce() {
 limit=15
 docker stack rm "$1"
  until [ -z "$(docker service ls --filter label=com.docker.stack.namespace=$1 -q)" ] || [ "$limit" -lt 0 ]; do
   sleep 1;
   limit="$((limit-1))"
  done
 limit=15  
  until [ -z "$(docker network ls --filter label=com.docker.stack.namespace=$1 -q)" ] || [ "$limit" -lt 0 ]; do
   sleep 1;
   limit="$((limit-1))"
  done
 docker stack deploy "$1" -c /share/appdata/config/"$1"/"$1".yml
}
dcu() {
    docker-compose -f /share/appdata/config/"$1"/"$1".yml up -d
}
dcd() {
    docker-compose -f /share/appdata/config/"$1"/"$1".yml down
}
```

Remember these shortcut names, (defined by the above code-snippet):
- **dfc** -- creates the folder structure for a single (or multiple) stack. If you want to setup multiple stack folders use `dfc plex ombi PiHole` (up to 9 stacks at a time). 
  - e.g. `dfc plex` would create these three folders:
    - `/share/appdata/plex`
    - `/share/appdata/config/plex`
    - `/share/runtime/plex`
- **dup** -- starts existing stacks declared in `/share/appdata/scripts/restart_stack.sh`
- **dsd** -- deploys a single stack - e.g. `dsd traefik`
- **dsr** -- removes a single stack - e.g. `dsr traefik`
- **dss** -- will create a new swarm, create a new overlay network, and start all stacks declared in 
  - `/share/appdata/scripts/setup_stack.sh`
- **dsp** -- prunes the docker system.  Any containers or networks not running will be removed -e.g. `dsp`
- **dsrms** -- will remove all stacks, prune the docker system, remove any overlay networks, and leave the swarm - e.g. `dsrms` 
  - ***Use with care!***
- **bounce** -- removes a single stack and recreates it - e.g. `bounce traefik`
  - removes existing `traefik` stack, then recreates using `/share/appdata/config/traefik/traefik.yml`
- **dcu** -- starts a docker-compose container
  - e.g. `dcu openvpn` starts the container defined by `/share/appdata/config/openvpn/openvpn.yml`
- **dcd** -- stops a docker-compose container - e.g. `dcd openvpn`

  ***NOTE:*** You will need to restart your ssh or cli session in order to make the profile changes effective.

  **See below** for scripts that need to be created and added to `/share/appdata/scripts` folder.
---

## 4 - Traefik Setup Steps

1. Add the three provided traefik files in "/config/traefik/" to `/share/appdata/config/traefik` (.yml, .toml, .env)

2. **Edit:** _traefik.env_ and put your cloudflare email and GLOBAL API KEY in lines 7 & 8 
  - **Note:** If you are not using cloudflare you will need to check with the Traefik documentation to add the correct environment settings to your _traefik.env_ file.

3. **Edit:** _traefik.yml_ and _traefik.toml_ to include your domain name.

4. In an SSH CLI (command line) run the below commands to set traefik folder permissions.
  - **Run:** `cd /share/appdata/config/traefik` -- changes current directory
  - **Run:** `touch acme.json` -- updates the file timestamp
  - **Run:** `chmod 600` -- sets 'rw' permissions for the current owner of the folder 

5. Check that `traefik.<yourdomain.com>` resolves to your WAN IP (Run `ping traefik.<yourdomain.com>` - Press `ctrl+c` to stop the ping)

6. Run: `dsd traefik` to start the traefik container

7. Enjoy Traefik and add more containers.
---

## 5 - ForwardAuth Setup Steps

1. Go to https://auth0.com

2. Sign in or register an account

3. Note Tenant Domain provided by Auth0

4. Login or create an account with https://github.com (using OAuth)

5. Go to _Settings -> Developer Settings - OAuth Apps_

6. Create a new app (call it something to recognize it is linked to Auth0)

7. Note the client ID and Secret

8. Add homepage URL as `https://<yourauth0accounthere>.auth0.com/`

9. Add authorization callback URL as `https://<yourauth0accounthere>.auth0.com/login/callback`

10. Go back to Auth0

11. Go to _Connections -> Social_

12. Select _Github_ and enter in your Github app ClientID and secret Credentials 
  **NOTE:** ENSURE _Attribute "Email Address"_ is ticked

13. Create an application on Auth0 (regular web app)

14. Use the Auth0 clientID and Client Secret in your _application.yaml_ file

15. Make sure to specify POST method of token endpoint authentication (Drop down box)

16. Enter in your Callback URL (`https://<service>.<domain>/signin` & `https://<service>.<domain>/oauth/signin`)
  For an entire domain, the values should look like this example:


17. Enter your origin URL (`https://<your URL here>`) and save changes

18. Go to Users & Roles and Create a user with a real email address.  You will use this later so remember it!

19. Click on _Rules -> Whitelist_

20. Enter in your email address into the whitelist field 
  e.g. `Line 8 "const whitelist = [ '<your email here>']; //authorized users"`

21. Open ssh and `dsr traefik`, wait 10 seconds and `dsd traefik`

22. Wait 30 seconds and then launch `https://traefik.<yourdomainhere>`

23. Enter Auth0 authentication login to reach traefik dashboard
---

## 6 - Scripts Setup
Please create these scripts and save them to `/share/appdata/scripts` if you want to use the cli shortcuts we created in earlier steps.  **NOTE:** `setup_stack.sh` requires you to add your NAS IP for it to work.
All the stack scripts (`xxx_stack.sh`) require you to edit the stacks list to match your setup.  If you do not edit them they will fail to deploy the stacks you don't have .. nothing blows up, no bunnies die, just a big pile of nothingness in your swarm.

***NOTE:*** Please ensure you save these files in UNIX (LF) format.  Windows (CR LF) format will break these scripts.  If you are a Windows user, please download the files from the scripts folder above.

##### folder_setup.sh

```
#!/bin/bash
# Script to create gkoerk's famously awesome folder structure for stacks

# Set folder paths here (you should not need to change these, but if you do, it will save a load of typing)
appdata=/share/appdata
config=/share/appdata/config
runtime=/share/runtime

# Help message for script
helpFunction() {
    echo ""
    echo "Usage: $0 -f <folder name>"
    echo -f "-f name of folder(s) you wish to add. For more than one folder, use -f <folder name 1> <folder name 2> ... <folder name 9>. You can have 9 folder names in a single command"
    exit 1 # Exit script after printing help
}

# Print helpFunction in case parameters are empty
if [ -z "$1" ]; then
    echo "Please enter at least one folder name"
    helpFunction
fi

# Create folder structure

mkdir -p $appdata/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
mkdir -p $config/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
mkdir -p $runtime/{$1,$2,$3,$4,$5,$6,$7,$8,$9}

echo "The following folders were setup:"
echo " - $@"

```

##### restart_stack.sh

```
#!/bin/bash
# define services - Add stacks to this list between the brackets
# Leave Traefik out of the list as it will be started separately
stacks=(portainer docker-cleanup
    shepherd wetty guacamole
    emby privatebin autopirate hackmd
)
# define config folder
config_folder=/share/appdata/config

echo "**** Starting Traefik ****"
# Traefik needs to be the first stack deployed
docker stack deploy traefik -c ${config_folder}/traefik/traefik.yml

# Pruning the stack is optional ... comment out if you don't want to do this step
echo "***** Pruning the stack *****"
docker system prune -f
echo "**** System pruned ****"

echo "**** Starting Other Stacks ****"
# restart all services in docker swarm

# loop through stacks defined above
for stack in "${stacks[@]}"; do
    echo "**** Starting $stack ****"
    docker stack deploy $stack -c ${config_folder}/${stack}/${stack}.yml
    echo "***** Sleeping for a bit*****"
    sleep 10
    echo "**** $stack has been started ****"
done

echo "**** All Stacks have been started ****"

```

##### remove_stack.sh

```
#!/bin/bash
# define services - Add stacks to this list between the brackets
stacks=(portainer docker-cleanup
    shepherd wetty guacamole
    emby privatebin autopirate hackmd
)
# define config folder
config_folder=/share/appdata/config

echo "**** Removing Stacks ****"
# remove all services in docker swarm

# loop through stacks defined above
for stack in "${stacks[@]}"; do
    echo "**** Removing $stack ****"
    docker stack rm $stack
    echo "***** Sleeping for a bit*****"
    sleep 15
    echo "**** $stack has been removed ****"
done
echo "**** Removing Traefik ****"
# traefik needs to be last
docker stack rm traefik
echo "**** All Stacks have been removed ****"
echo "***** Sleeping for a bit *****"
sleep 15
echo "***** Pruning the stack *****"
docker system prune -f
echo "**** System pruned ****"
docker swarm leave -f
echo "***** Swarm Left *****"

```

##### setup_stack.sh

```
#!/bin/bash
# NOTE YOU NEED TO SET YOUR NAS IP BELOW FOR THE SWARM!!
echo "***** Setting up Swarm *****"
# setup Swarm
docker swarm init --advertise-addr <ENTER YOUR NAS IP HERE>

echo "***** Sleeping for a bit*****"
sleep 15

echo "***** Setting up overlay network *****"
# setup the overlay network
docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable traefik_public

# define services - Add stacks to this list between the brackets
# Leave Traefik out of the list as it will be started seperately
stacks=(portainer docker-cleanup
    shepherd nextcloud graylog wetty
    plex privatebin autopirate
)
# define config folder
config_folder=/share/appdata/config

echo "**** Starting Traefik ****"
# Traefik needs to be the first stack deployed
docker stack deploy traefik -c ${config_folder}/traefik/traefik.yml

echo "**** Starting Other Stacks ****"
# restart all services in docker swarm

# loop through stacks defined above
for stack in "${stacks[@]}"; do
    echo "**** Starting $stack ****"
    docker stack deploy $stack -c ${config_folder}/${stack}/${stack}.yml
    echo "***** Sleeping for a bit*****"
    sleep 15
    echo "**** $stack has been started ****"
done

echo "**** All Stacks have been started ****"

```
