#!/bin/sh
######################################

echo FreeDMR Docker installer...

echo Installing required packages...
echo Install Docker Community Edition...

sudo apt-get remove docker docker-engine docker.io containerd runc

sudo apt-get update
sudo apt-get install git ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo Set userland-proxy to false...
cat <<EOF > /etc/docker/daemon.json
{
     "userland-proxy": false,
     "experimental": true,
     "log-driver": "json-file",
     "log-opts": {
        "max-size": "10m",
        "max-file": "3"
      }
}
EOF

echo "Restart docker..."
systemctl restart docker

echo "Make config directory..."
mkdir /etc/freedmr &&
mkdir -p /etc/freedmr/acme.sh && 
mkdir -p /etc/freedmr/certs &&
chmod -R 755 /etc/freedmr

echo "make json directory..."
mkdir -p /etc/freedmr/json &&
chown 54000:54000 /etc/freedmr/json

echo "Install /etc/freedmr/freedmr.cfg ..."

cat << EOF > /etc/freedmr/freedmr.cfg
[GLOBAL]
PATH: ./
PING_TIME: 10
MAX_MISSED: 3
USE_ACL: True
REG_ACL: DENY:0-100000
SUB_ACL: DENY:0-100000
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
GEN_STAT_BRIDGES: True
ALLOW_NULL_PASSPHRASE: True
ANNOUNCEMENT_LANGUAGES:
SERVER_ID: 0
DATA_GATEWAY: False
VALIDATE_SERVER_IDS: True


[REPORTS]
REPORT: True
REPORT_INTERVAL: 60
REPORT_PORT: 4321
REPORT_CLIENTS: *

[LOGGER]
LOG_FILE: /dev/null
LOG_HANDLERS: console-timed
LOG_LEVEL: INFO
LOG_NAME: FreeDMR

[ALIASES]
TRY_DOWNLOAD: True
PATH: ./json/
PEER_FILE: peer_ids.json
SUBSCRIBER_FILE: subscriber_ids.json
TGID_FILE: talkgroup_ids.json
PEER_URL: http://freedmr-lh.gb7fr.org.uk/json/peer_ids.json
SUBSCRIBER_URL: http://freedmr-lh.gb7fr.org.uk/json/subscriber_ids.json
TGID_URL: http://freedmr-lh.gb7fr.org.uk/json/talkgroup_ids.json
LOCAL_SUBSCRIBER_FILE: local_subscriber_ids.json
STALE_DAYS: 1
SUB_MAP_FILE: sub_map.pkl
SERVER_ID_URL: http://freedmr-lh.gb7fr.org.uk/json/server_ids.tsv
SERVER_ID_FILE: server_ids.tsv
TOPO_FILE: topography.json


#Control server shared allstar instance via dial / AMI
[ALLSTAR]
ENABLED: false
USER:admin
PASS: password
SERVER: asl.example.com
PORT: 5038
NODE: 11111

[OBP-TEST]
MODE: OPENBRIDGE
ENABLED: False
IP:
PORT: 62044
NETWORK_ID: 1
PASSPHRASE: mypass
TARGET_IP: 
TARGET_PORT: 62044
USE_ACL: True
SUB_ACL: DENY:1
TGID_ACL: PERMIT:ALL
RELAX_CHECKS: True
ENHANCED_OBP: True
PROTO_VER: 2


[SYSTEM]
MODE: MASTER
ENABLED: True
REPEAT: True
MAX_PEERS: 1
EXPORT_AMBE: False
IP: 127.0.0.1
PORT: 54000
PASSPHRASE:
GROUP_HANGTIME: 5
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
DEFAULT_UA_TIMER: 10
SINGLE_MODE: True
VOICE_IDENT: False
TS1_STATIC:
TS2_STATIC:
DEFAULT_REFLECTOR: 0
ANNOUNCEMENT_LANGUAGE: es_ES
GENERATOR: 100
ALLOW_UNREG_ID: False
PROXY_CONTROL: True
OVERRIDE_IDENT_TG:

[ECHO]
MODE: PEER
ENABLED: True
LOOSE: False
EXPORT_AMBE: False
IP: 127.0.0.1
PORT: 54916
MASTER_IP: 127.0.0.1
MASTER_PORT: 54915
PASSPHRASE: passw0rd
CALLSIGN: ECHO
RADIO_ID: 1000001
RX_FREQ: 449000000
TX_FREQ: 444000000
TX_POWER: 25
COLORCODE: 1
SLOTS: 1
LATITUDE: 00.0000
LONGITUDE: 000.0000
HEIGHT: 0
LOCATION: Earth
DESCRIPTION: ECHO
URL: www.freedmr.uk
SOFTWARE_ID: 20170620
PACKAGE_ID: MMDVM_FreeDMR
GROUP_HANGTIME: 5
OPTIONS:
USE_ACL: True
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
ANNOUNCEMENT_LANGUAGE: es_ES
EOF

echo "Install rules.py..."
echo "BRIDGES = {'9990': [{'SYSTEM': 'ECHO', 'TS': 2, 'TGID': 9990, 'ACTIVE': True, 'TIMEOUT': 2, 'TO_TYPE': 'NONE', 'ON': [], 'OFF': [], 'RESET': []},]}" > /etc/freedmr/rules.py

echo "Set perms on config directory..."
chown -R 54000 /etc/freedmr

echo "Tune network stack..."
cat << EOF > /etc/sysctl.conf
net.core.rmem_default=134217728
net.core.rmem_max=134217728
net.core.wmem_max=134217728                       
net.core.rmem_default=134217728
net.core.netdev_max_backlog=250000
net.netfilter.nf_conntrack_udp_timeout=15
net.netfilter.nf_conntrack_udp_timeout_stream=35
EOF

/usr/sbin/sysctl -p



echo "Downloading Easy-FreeDMR-Docker..."

git clone https://github.com/hp3icc/Easy-FreeDMR-Docker.git /tmp/Easy-FreeDMR-Docker &&
cp /tmp/Easy-FreeDMR-Docker/docker-compose.yml /etc/freedmr &&
cp -r /tmp/Easy-FreeDMR-Docker/docker /etc/freedmr

echo "Downloading hbmon..."

sudo git clone https://github.com/yuvelq/FDMR-Monitor.git /etc/freedmr/hbmon
cd /etc/freedmr/hbmon
sudo git checkout Self_Service

echo "Configuring..."

cp fdmr-mon_SAMPLE.cfg fdmr-mon.cfg

sed -i "s/FDMR_IP .*/FDMR_IP = 172.16.238.10/" fdmr-mon.cfg

sed -i "s/PRIVATE_NETWORK .*/PRIVATE_NETWORK = False/" fdmr-mon.cfg
sed -i "s/DB_SERVER .*/DB_SERVER = mariadb/" fdmr-mon.cfg
sed -i "s/DB_USERNAME .*/DB_USERNAME = hbmon/" fdmr-mon.cfg
sed -i "s/DB_PASSWORD .*/DB_PASSWORD = hbmon/" fdmr-mon.cfg
sed -i "s/DB_NAME .*/DB_NAME = hbmon/" fdmr-mon.cfg

sed -i "s/TGID_URL .*/TGID_URL = https://freedmr.cymru/talkgroups/talkgroup_ids_json.php" fdmr-mon.cfg


sed -i "s/path2config .*/path2config = \"\/hbmon\/fdmr-mon.cfg\";/" html/include/config.php


chmod -R 777 /etc/freedmr/hbmon/log

echo "Run FreeDMR container..."

docker compose up -d

echo "Read notes in /etc/freedmr/docker-compose.yml to understand how to implement extra functionality."
echo "FreeDMR setup complete!"

echo "Wait some minutes and execute this command"
echo docker exec -it python sh -c "cd /hbmon && python mon_db.py --create"


######################################
chmod 755 /etc/freedmr -R

#############################
sudo cat > /bin/menu <<- "EOF"
#!/bin/bash
while : ; do
choix=$(whiptail --title "Raspbian Proyect HP3ICC EasyFreeDMR Docker Version" --menu "move up or down with the keyboard arrows and select your option by pressing enter:" 17 56 8 \
1 " Edit FreeDMR Server " \
2 " Edit Interlink  " \
3 " Edit FDMR-Monitor  " \
4 " Start & Restart FreeDMR Server  " \
5 " Stop FreeDMR Server " \
6 " update " 3>&1 1>&2 2>&3)
exitstatus=$?
#on recupere ce choix
#exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your chosen option:" $choix
else
    echo "You chose cancel."; break;
fi
# case : action en fonction du choix
case $choix in
1)
sudo nano /etc/freedmr/freedmr.cfg ;;
2)
sudo nano /etc/freedmr/rules.py ;;
3)
sudo nano /etc/freedmr/fdmr-mon.cfg ;;
4)
start-fdmr ;;
5)
stop-fdmr ;;
6)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/update.sh)";
esac
done
exit 0
EOF

##
cp /bin/menu /bin/MENU

sudo cat > /bin/start-fdmr <<- "EOF"
#!/bin/bash
cd /etc/freedmr
docker compose down
docker compose up -d
EOF
#
sudo cat > /bin/stop-fdmr <<- "EOF"
#!/bin/bash
cd /etc/freedmr
docker compose down
EOF
#

#############################################################
chmod +x /bin/menu*
chmod +x /bin/MENU
chmod +x /bin/start-fdmr
chmod +x /bin/stop-fdmr
history -c && history -w
start-fdmr
menu
#####

