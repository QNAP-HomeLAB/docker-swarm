# QNAP-Docker-Swarm-Setup
A guide for configuring the docker swarm stack on QNAP devices with Container Station

# SWARM SETUP GUIDE

### Document History
     - Initial Document                              13/Mar/2019
     - Added more profile shortcuts                  07/Jun/2019
     - Added Auth0/ForwardAuth instructions          07/Jun/2019
     - Added scripts to guide                        07/Jun/2019
     - Added preparation Steps                       13/Jun/2019
     - Added Special Thanks                          14/Jun/2019
     - Removed legacy OAuth references               14/Jun/2019
     - German Translation added                      12/Sep/2019
     - Optimimization in Codes for better C/P        15/Sep/2019

---
### Special Thanks
This document originated from taking notes when first setting up my docker swarm. It would not have been possible without **@gkoerk** on the _QNAP Unofficial Forum_ Discord channel (Which I highly recommend you join).

His knowledge, clear instructions, and incredible patience put me on the path of becoming a docker addict, and without his guidance, this guide would not exist.  If this guide helps you out, please remember to send **@gkoerk** some love on the discord channel.

Thanks to **@eJonnyDotCom** from the _QNAP Unofficial Forum_ Discord channel for his feedback and comments on this guide (and spotting my numerous mistakes).  **@eJonnyDotCom** went through the pain and frustrations of missing steps and unclear instructions so you don't have to.

---
###  Docker Swarm Setup 
#### Preparation
Ports 80 and 443 must be unused on your NAS.  By default QTS used 80 and 443 for web login.  Please change this to 9080 and 9443 to ensure no port conflicts with docker stacks.  You will also need to ensure ports 80 and 443 are forwarded from your router to your NAS before we begin.

Steps:
1. Backup what you have running now (if you don't have anything running yet, skip to Step 8.)
1. Shutdown and remove all Containers
1. Open terminal and run `docker system prune`
1. Run `docker network prune` for good measure
1. Run `docker swarm leave --force` (just to be sure you don't have a swarm left hanging around)
1. Remove Container Station
1. Reboot NAS
1. Install Container Station and launch once installed
1. Create a new user called _dockeruser_
1. Create the following folder shares and give _dockeruser_ Read/Write permissions:  
`/share/appdata` - Here we will add a folder <stack name>. This is where your application files live... libraries, artifacts, etc.
`/share/appdata/config` - Here we will also add a folder <stack name>. Inside this structure, we will keep our actual _stack.yml_ files and any other necessary config files.  
`/share/runtime` - This is a shared folder on a volume that does not get backed up. It is where living DB files and transcode files reside, so it would appreciate running on the fastest storage group you have or in cache mode or in Qtier (if you use it).
1. Run `id dockeruser` in terminal and note the uid and gid
1. Run `docker network ls`. You should see 3 networks, bridge, host, and null
1. Run `docker swarm init --advertise-addr <YOUR NAS IP HERE>` - Use ***YOUR*** nas IP
1. Run `docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable traefik_public`
1. Install Entware 1.0 package (Installing qnapclub is easiest way https://www.qnapclub.eu/en/howto/1). This allows you to setup the shortcuts in Steps 20 & 21 by editing your cli profile.
1.  Run `mkdir /share/appdata/traefik`
1.  Run `mkdir /share/appdata/config/traefik`
1.  Run `mkdir /share/runtime/traefik`
1.  Install nano or vi, whichever you are more comfortable with (e.g. Run `opkg install nano` or `opkg install vim`)
1.  Run `nano /opt/etc/profile` (or `vi /opt/etc/profile` if that is your thing)
1.  Add the following lines to the end of the file and save
```
dsd() {
	docker stack deploy "$1" -c /share/appdata/config/"$1"/"$1".yml
}
dsr() {
	docker stack rm "$1"
}
dfc() {
	bash /share/appdata/scripts/folder_setup.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
}
dup() {
	bash /share/appdata/scripts/restart_stack.sh
}
dsp() {
	bash docker system prune -f
}
dsrms() {
	bash /share/appdata/scripts/remove_stack.sh
}
dss() {
	bash /share/appdata/scripts/setup_stack.sh
}
```
Remember these shortcut names:
- **dsd** deploys a single stack - e.g. `dsd plex`
- **dsr** removes a single stack - e.g. `dsr plex`
- **dfc** creates the folder structure for a single (or multiple) stack. If you want to setup multiple stack folders use `dfc plex ombi PiHole` (up to 9 stacks at a time). Simplest example: e.g. `dfc plex` would create:
     - /share/appdata/plex
     - /share/appdata/config/plex
     - /share/runtime/plex
- **dup** starts existing stacks declared in `/share/appdata/scripts/restart_stack.sh`
- **dsp** prunes the docker system.  Any containers or networks not running will be removed -e.g. `dsp`
- **dsrms** will remove all stacks, prune the docker system, remove any overlay networks, and leave the swarm - e.g. `dsrms` (use with care!)
- **dss** will create a new swarm, create a new overlay network, start all stacks declared in `/share/appdata/scripts/setup_stack.sh`
** See below for scripts that need to be created and added to `/share/appdata/scripts` folder

***NOTE:*** You will need to restart your ssh or cli session in order to make the profile changes effective.

22. Edit _traefik.env_ and put your cloudflare email and GLOBAL API KEY in lines 7&8 (If you are not using cloudflare you will need to check with the Traefik documentation to add the correct environment settings to your _traefik.env_ file)
1. Edit _traefik.yml_ and _traefik.toml_ to include your domain name
1. Add the provided 3 traefik files to `/share/appdata/config/traefik` (.yml, .toml, .env)
2. ``touch acme.json`` in the folder and set permissions to 600
3. Check `traefik.<yourdomain.com>` resolves to your WAN IP (Run `ping traefik.<yourdomain.com>` - Press `ctrl+c` to stop the ping)
4. Run `dsd traefik` to start the traefik container
5. Follow _ForwardAuth Setup Steps_ below
6. Enjoy Traefik and add more containers.
---
### ForwardAuth Setup Steps
1. Go to https://auth0.com
1. Sign in or register an account
1. Note Tenant Domain provided by Auth0
1. Login or create an account with https://github.com
1. Goto _Settings -> Developer Settings - OAuth Apps_
1. Create a new app (call it something to recognise it is linked to Auth0)
1. Note the client Id and Secret
1. Add homepage URL as `https://<yourauth0accounthere>.auth0.com/`
1. Add authorisaiton callback URL as `https://<yourauth0accounthere>.auth0.com/login/callback`
1. Go back to Auth0
1. Go to _Connections -> Social_
1. Select _Github_ and enter in your Github app ClientID and secret Credentials - **NOTE:** ENSURE _Attribute "Email Address"_ is ticked
1. Create an application on Auth0 (regular web app)
1. Use the Auth0 clientID and Client Secret in your _application.yaml_ file
1. Make sure to specify POST method of token endpoint authentication (Drop down box)
1. Enter in your Callback URL (`https://<service>.<domain>/signin` & `https://<service>.<domain>/oauth/signin`)
1. Enter your origin URL (`https://<your URL here>`) and save changes
1. Go to Users & Roles and Create a user with a real email address.  You will use this later so remember it
1. Click on _Rules -> Whitelist_
1. Enter in your email address into the whitelist field (e.g. `Line 8 "const whitelist = [ '<your email here>']; //authorized users"`)
1. Open ssh and `dsr traefik`, wait 10 seconds and `dsd traefik`
1. Wait 30 seconds and then launch `https://traefik.<yourdomainhere>`
1. Enter Auth0 authentication login to reach traefik dashboard
---
### Scripts Setup
Please create these scripts and save them to `/share/appdata/scripts` if you want to use the cli shortcuts we created in earlier steps.  **NOTE:** `setup_stack.sh` requires you to add your NAS IP for it to work.
All the stack scripts (`xxx_stack.sh`) require you to edit the stacks list to match your setup.  If you do not edit them they will fail to deploy the stacks you don't have .. nothing blows up, no bunnies die, just a big pile of nothingness in your swarm.
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

---
### Deutsche Übersetzung
## SCHWARM-SETUP-ANLEITUNG
### Vorbereitung

Die Ports 80 und 443 müssen auf Ihrem NAS unbenutzt sein.  Standardmäßig verwendet QTS 80 und 443 für die Webserver. Bitte ändern Sie dies auf 9080 und 9443, um sicherzustellen, dass keine Portkonflikte mit Docker-Stacks auftreten.  Sie müssen auch sicherstellen, dass die Ports 80 und 443 von Ihrem Router zu Ihrem NAS weitergeleitet werden, bevor wir beginnen.

Schritte:
1. Sichern Sie, was Sie gerade ausgeführt haben (wenn Sie noch nichts haben, fahren Sie mit Schritt 8 fort.)
1. Herunterfahren und Entfernen aller Container
1. Öffnen Sie das Terminal und führen Sie `docker system prune` aus.
1. Führen Sie `docker network prune` für eine gute Sache aus.
1. Laufen Sie `docker swarm leave --force` (nur um sicher zu gehen, dass Sie keinen Schwarm mehr haben, der herumhängt).
1. Container-Station entfernen
1. NAS neu starten
1. Container-Station installieren und nach der Installation starten
1. Erstellen Sie einen neuen Benutzer namens ***dockeruser***.
1. Erstellen Sie die folgenden Ordnerfreigaben und geben Sie ***dockeruser*** Lese-/Schreibrechte:  
`/share/appdata` - Hier werden wir einen Ordner hinzufügen <stack name>. Hier leben Ihre Anwendungsdateien.... Bibliotheken, Artefakte, etc.
`/share/appdata/config` - Hier werden wir auch einen Ordner hinzufügen <stack name>. Innerhalb dieser Struktur werden wir unsere aktuellen _stack.yml_ Dateien und alle anderen notwendigen Konfigurationsdateien aufbewahren.  
`/share/runtime` - Dies ist ein freigegebener Ordner auf einem Volume, das nicht gesichert wird. Es ist der Ort, an dem sich lebende DB-Dateien und Transcode-Dateien befinden, daher würde es sich freuen, wenn Sie auf der schnellsten Speichergruppe, die Sie haben, oder im Cachemodus oder in Qtier (wenn Sie es verwenden) ausgeführt würden.
1. Starten Sie `id dockeruser` im Terminal und notieren Sie sich die uid und gid.
1. Führen Sie `docker network ls` aus. Du solltest 3 Netzwerke sehen, Bridge, Host und Null.
1. Ausführen von `docker swarm init --advertise-addr <YOUR NAS IP HERE>` - Verwenden Sie ***Ihre*** nas IP
1. Ausführen von `docker network create --driver=overlay --subnet=172.1.1.1.0/22 --attachable traefik_public`
1. Installieren Sie das Entware 1.0-Paket (Die Installation von qnapclub ist der einfachste Weg https://www.qnapclub.eu/en/howto/1). Dies ermöglicht es Ihnen, die Verknüpfungen in den Schritten 20 und 21 einzurichten, indem Sie Ihr Bashprofil bearbeiten.
1.  `mkdir /share/appdata/traefik` ausführen
1.  gefolgt von `mkdir /share/appdata/config/traefik` und
1.  `mkdir /share/runtime/traefik` ausführen.
1.  Installiere nano oder vi, je nachdem, was dir am besten gefällt (z.B. Run `opkg install nano` oder `opkg install vim`).
1.  Führen Sie `nano /opt/etc/profile` (oder `vi /opt/etc/profile`, wenn das Ihres ist) aus.
1.  Füge die folgenden Zeilen am Ende der Datei hinzu und speichere sie.
```
dsd() {
	docker stack deploy "$1" -c /share/appdata/config/"$1"/"$1".yml
}
dsr() {
	docker stack rm "$1"
}
dfc() {
	bash /share/appdata/scripts/folder_setup.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
}
dup() {
	bash /share/appdata/scripts/restart_stack.sh
}
dsp() {
	bash docker system prune -f
}
dsrms() {
	bash /share/appdata/scripts/remove_stack.sh
}
dss() {
	bash /share/appdata/scripts/setup_stack.sh
}
```
Merken Sie sich diese Verknüpfungsnamen:
- **dsd** setzt einen einzelnen Stapel ein - z.B. `dsd plex`.
- **dsr** entfernt einen einzelnen Stapel - z.B. `dsr plex`.
- **dfc** erstellt die Ordnerstruktur für einen einzelnen (oder mehrere) Stapel. Wenn Sie mehrere Stapelordner einrichten möchten, verwenden Sie `dfc plex ombi PiHole` (bis zu 9 Stapel gleichzeitig). Einfachstes Beispiel: z.B. würde `dfc plex` erstellen:
     - /share/appdata/plex
     - /share/appdata/config/plex/
     - /share/runtime/plex
- **dup** startet bestehende Stapel, die in `/share/appdata/scripts/restart_stack.sh` deklariert sind.
- **dsp** beschneidet das Dockersystem.  Alle nicht laufenden Container oder Netzwerke werden entfernt - z.B. `dsp`.
- **dsrms** entfernt alle Stapel, schneidet das Dockersystem, entfernt alle Overlay-Netzwerke und verlässt den Schwarm - z.B. `dsrms` (Vorsicht!)
- **dss** erstellt einen neuen Schwarm, erstellt ein neues Overlay-Netzwerk, startet alle in `/share/appdata/scripts/setup_stack.sh` deklarierten Stacks.

** Siehe unten für Skripte, die erstellt und dem Ordner `/share/appdata/scripts` hinzugefügt werden müssen.

***HINWEIS:*** Sie müssen Ihre ssh- oder cli-Sitzung neu starten, um die Profiländerungen wirksam zu machen.

22. Bearbeiten Sie _traefik.env_ und geben Sie Ihre Cloudflare-E-Mail und Ihren GLOBAL API KEY in die Zeilen 7&8 ein (wenn Sie Cloudflare nicht verwenden, müssen Sie dies in der Traefik-Dokumentation nachprüfen, um die richtigen Umgebungseinstellungen zu Ihrer Datei _traefik.env_ hinzuzufügen).
1. Bearbeiten Sie _traefik.yml_ und _traefik.toml_, um Ihren Domainnamen aufzunehmen.
1. Füge die bereitgestellten 3 Traefik-Dateien zu `/share/appdata/config/traefik` (.yml,.toml,.env) hinzu.
2. ``touch acme.json`` im Ordner und setzen Sie die Berechtigungen via ``chmod 600 acme.json``.
3. Überprüfen Sie, ob `traefik.<deinedomain.com>` zu Ihrer WAN-IP auflöst (Starten Sie `ping traefik.<deinedomain.com>` - Drücken Sie `ctrl+c`, um den Ping zu stoppen).
4. Starten Sie `dsd traefik`, um den Traefik-Container zu starten.
5. Befolgen Sie die folgenden Schritte zur Einrichtung von _ForwardAuth_.
6. Genießen Sie Traefik und fügen Sie weitere Container hinzu.
---
### ForwardAuth Setup-Schritte
1. Gehen Sie zu https://auth0.com
1. Anmelden oder ein Konto registrieren
1. Hinweis Tenant domain bereitgestellt von Auth0
1. Melden Sie sich an oder erstellen Sie ein Konto bei https://github.com
1. Gehen Sie zu _Einstellungen -> Entwicklereinstellungen - OAuth Apps_.
1. Erstellen Sie eine neue App (nennen Sie sie etwas, um zu erkennen, dass sie mit Auth0 verknüpft ist).
1. Notieren Sie sich die Client-ID und das Secret.
1. Hinzufügen der Homepage-URL als `https://<deinauth0accounthier>.auth0.com/`
1. Fügen Sie die Autorisierungs-Rückruf-URL als `https://<deinauth0accounthier>.auth0.com/login/callback` hinzu.
1. Zurück zu Auth0
1. Gehen Sie zu _Verbindungen -> Soziales_.
1. Wählen Sie _Github_ und geben Sie in Ihre Github-App ClientID und geheime Zugangsdaten ein - **Notiz:** Versichere dich das  _Attribut "Email Address"_ angekreuzt ist.
1. Erstellen einer Anwendung auf Auth0 (normale Webanwendung)
1. Verwenden Sie die Auth0 clientID und das Client Secret in Ihrer _application.yaml_ Datei.
1. Stellen Sie sicher, dass Sie die POST-Method der Token-Endpunkt-Authentifizierung angeben (Dropdown-Box).
1. Geben Sie Ihre Rückruf-URL ein (`https://<service>.<domain>/signin` & `https://<service>.<domain>/oauth/signin`)
1. Geben Sie Ihre Herkunfts-URL (`https://<deine URL hier>`) ein und speichern Sie die Änderungen.
1. Gehen Sie zu Benutzer & Rollen und erstellen Sie einen Benutzer mit einer echten E-Mail-Adresse.  Du wirst das später verwenden, also denk daran.
1. Klicken Sie auf _Regeln -> Whitelist_.
1. Geben Sie Ihre E-Mail-Adresse in das Feld Whitelist ein (z.B. `Zeile 8 "const Whitelist = [ '<deine email hier>']; //authorized users"`).
1. Öffnen Sie ssh und `dsr traefik`, warten Sie 10 Sekunden und `dsd traefik`.
1. Warten Sie 30 Sekunden und starten Sie dann `https://traefik.<yourdomiainhere>`.
1. Geben Sie die Auth0-Authentifizierung ein, um das traefik Dashboard zu erreichen.
---
### Scripts Setup
Bitte erstellen Sie diese Skripte und speichern Sie sie unter `/share/appdata/scripts`, wenn Sie die Shortcuts verwenden möchten, die wir in früheren Schritten erstellt haben.  **HINWEIS:** `setup_stack.sh` erfordert, dass Sie Ihre NAS-IP hinzufügen, damit sie funktioniert.
Alle Stack-Skripte (`xxx_stack.sh`) erfordern, dass Sie die Stackliste entsprechend Ihrem Setup bearbeiten.  Wenn du sie nicht bearbeitest, werden sie es nicht schaffen, die Stapel einzusetzen, die du nicht hast... nichts explodiert, keine Hasen sterben, nur ein großer Haufen Nichts in deinem Schwarm.

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
    sleep 15
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

---

