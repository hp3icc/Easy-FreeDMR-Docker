#!/bin/sh
if [[ $EUID -ne 0 ]]; then
	whiptail --title "CL-Link" --msgbox "Debe ejecutar este script como usuario ROOT" 0 50
	exit 0
fi
######################################

echo FreeDMR Docker installer...

apt-get -y remove docker docker-engine docker.io &&
apt-get -y update &&
apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common &&
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - &&
ARCH=`/usr/bin/arch`
echo "System architecture is $ARCH" 
if [ "$ARCH" == "x86_64" ]
then
    ARCH="amd64"
fi
add-apt-repository \
   "deb [arch=$ARCH] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" &&
apt-get -y update &&
apt-get -y install docker-ce &&

echo Install Docker Compose...
apt-get -y install docker-compose &&

echo Set userland-proxy to false...
cat <<EOF > /etc/docker/daemon.json &&
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

#####################################

echo "Restart docker..."
systemctl restart docker

#
if [ -d "/tmp/Easy-FreeDMR-Docker" ];
then
    rm -r /tmp/Easy-FreeDMR-Docker
fi
if [ -d "/etc/freedmr" ];
then
    rm -r /etc/freedmr
fi
if [ -d "/opt/FreeDMR" ];
then
    rm -r /opt/FreeDMR
fi
if [ -d "/opt/FDMR-Monitor" ];
then
    rm -r /opt/FDMR-Monitor
fi
#

echo "Make config directory..."
mkdir /etc/freedmr
mkdir /etc/freedmr/hbmon
mkdir -p /etc/freedmr/acme.sh
mkdir -p /etc/freedmr/certs
mkdir -p /etc/freedmr/mysql/initdb.d
chmod -R 755 /etc/freedmr

echo "make json directory..."
mkdir -p /etc/freedmr/json
chown 54000:54000 /etc/freedmr/json
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

[PROXY]
MASTER: 127.0.0.1
LISTENPORT: 62031
# Leave blank for IPv4, ::: all IPv4 and IPv6 (Dual Stack)
LISTENIP =
DESTPORTSTART: 54000
DESTPORTEND: 54100
TIMEOUT: 30
STATS: False
DEBUG: False
CLIENTINFO: False
BLACKLIST: [1234567]
#e.g. {10.0.0.1: 0, 10.0.0.2: 0}
IPBLACKLIST: {}
 
[SELF SERVICE]
ENABLED: False
MODE: MASTER
USE_SELFSERVICE: True
SERVER: 172.16.238.11
USERNAME: hbmon
# For no password leave it blank
PASSWORD: hbmon
DB_NAME: hbmon
PORT: 3306

[D-APRS]
MODE: MASTER
ENABLED: True
REPEAT: False
MAX_PEERS: 1
EXPORT_AMBE: False
IP:
PORT: 52555
PASSPHRASE:
GROUP_HANGTIME: 0
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
DEFAULT_UA_TIMER: 10
SINGLE_MODE: False
VOICE_IDENT: False
TS1_STATIC:
TS2_STATIC:
DEFAULT_REFLECTOR: 0
ANNOUNCEMENT_LANGUAGE: es_ES
GENERATOR: 2
ALLOW_UNREG_ID: True
PROXY_CONTROL: False
OVERRIDE_IDENT_TG:


EOF
#

echo "Install rules.py..."

cat << EOF > /etc/freedmr/rules.py
BRIDGES = {
 
 '9990': [ 
	{'SYSTEM': 'ECHO', 		'TS': 2, 'TGID': 9990, 'ACTIVE':True, 'TIMEOUT': 0, 'TO_TYPE': 'NONE', 'ON': [], 'OFF': [], 'RESET': []}, 
	],
  
  
  
}
if __name__ == '__main__':
    from pprint import pprint
    pprint(BRIDGES)
    
EOF
#
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

git clone https://github.com/hp3icc/Easy-FreeDMR-Docker.git /tmp/Easy-FreeDMR-Docker
cp /tmp/Easy-FreeDMR-Docker/docker-compose.yml /etc/freedmr
cp -r /tmp/Easy-FreeDMR-Docker/docker /etc/freedmr
cp /etc/freedmr/docker/mariadb/hbmon.sql /etc/freedmr/mysql/initdb.d/

#################
echo "Downloading hbmon..."

git clone https://github.com/yuvelq/FDMR-Monitor.git /etc/freedmr/hbmon
cd /etc/freedmr/hbmon
git checkout Self_Service
chown -R 54000 /etc/freedmr/hbmon/log

echo "Configuring..."

cp fdmr-mon_SAMPLE.cfg fdmr-mon.cfg

sed -i "s/FDMR_IP .*/FDMR_IP = 172.16.238.10/" fdmr-mon.cfg

sed -i "s/PRIVATE_NETWORK .*/PRIVATE_NETWORK = False/" fdmr-mon.cfg
sed -i "s/DB_SERVER .*/DB_SERVER = mariadb/" fdmr-mon.cfg
sed -i "s/DB_USERNAME .*/DB_USERNAME = hbmon/" fdmr-mon.cfg
sed -i "s/DB_PASSWORD .*/DB_PASSWORD = hbmon/" fdmr-mon.cfg
sed -i "s/DB_NAME .*/DB_NAME = hbmon/" fdmr-mon.cfg
sed -i "s/LOG_PATH = .\/log/LOG_PATH = .\//" fdmr-mon.cfg
sed -i "s/LOG_LEVEL = INFO/LOG_LEVEL = DEBUG/" fdmr-mon.cfg

apt-get install rrdtool -y

sed -i 's/var\/www\/html/etc\/freedmr\/hbmon\/html/' /etc/freedmr/hbmon/sysinfo/cpu.sh
sed -i 's/var\/www\/html/etc\/freedmr\/hbmon\/html/' /etc/freedmr/hbmon/sysinfo/graph.sh
sed -i "s/opt\/HBMonv2/etc\/freedmr\/hbmon/g"  /etc/freedmr/hbmon/sysinfo/*.sh
sed '33 a <!--' -i /etc/freedmr/hbmon/html/sysinfo.php
sed '35 a -->' -i /etc/freedmr/hbmon/html/sysinfo.php
sed -i 's/localhost_2-day.png/localhost_1-day.png/' /etc/freedmr/hbmon/html/sysinfo.php

chmod +x /etc/freedmr/hbmon/sysinfo/cpu.sh
chmod +x /etc/freedmr/hbmon/sysinfo/graph.sh
chmod +x /etc/freedmr/hbmon/sysinfo/rrd-db.sh
#
if [ -f "/etc/freedmr/hbmon/sysinfo/hdd.rrd" ];
then
	
    rm -rf /etc/freedmr/hbmon/sysinfo/*.rrd
fi
if [ -f "/etc/freedmr/hbmon/sysinfo/load.rrd" ];
then
	
    rm -rf /etc/freedmr/hbmon/sysinfo/*.rrd
fi
if [ -f "/etc/freedmr/hbmon/sysinfo/mem.rrd" ];
then
	
    rm -rf /etc/freedmr/hbmon/sysinfo/*.rrd
fi
if [ -f "/etc/freedmr/hbmon/sysinfo/tempC.rrd" ];
then
	
    rm -rf /etc/freedmr/hbmon/sysinfo/*.rrd
fi
#
sh /etc/freedmr/hbmon/sysinfo/rrd-db.sh
(crontab -l; echo "*/5 * * * * sh /etc/freedmr/hbmon/sysinfo/graph.sh")|awk '!x[$0]++'|crontab -
(crontab -l; echo "*/2 * * * * sh /etc/freedmr/hbmon/sysinfo/cpu.sh")|awk '!x[$0]++'|crontab -
(crontab -l; echo "* */12 * * * data-id")|awk '!x[$0]++'|crontab -
###
sudo cat > /etc/freedmr/hbmon/html/buttons.php <<- "EOF"
<!-- HBMonitor buttons HTML code -->
<a class="button" href="index.php">Home</a>
&nbsp;
<div class="dropdown">
  <button class="dropbtn">Links</button>
  <div class="dropdown-content">
&nbsp;
<a class="button" href="linkedsys.php">Linked Systems</a>
<a class="button" href="statictg.php">Static TG</a>
<a class="button" href="opb.php">OpenBridge</a>
&nbsp;
</div>
</div>
<div class="dropdown">
  <button class="dropbtn">Self Service</button>
  <div class="dropdown-content">
    <?php if(!PRIVATE_NETWORK){echo '<a class="button" href="selfservice.php">SelfService</a>';}?>
    <a class="button" href="login.php">Login</a>
    <?php 
    if(isset($_SESSION["auth"], $_SESSION["callsign"], $_SESSION["h_psswd"]) and $_SESSION["auth"]){
      echo '<a class="button" href="devices.php">Devices</a>';
    }
    ?>
  </div>
</div>
<div class="dropdown">
  <button class="dropbtn">Local Server</button>
  <div class="dropdown-content">
<a class="button" href="moni.php">&nbsp;Monitor&nbsp;</a>
&nbsp;
<a class="button" href="sysinfo.php">&nbsp;System Info&nbsp;</a>
&nbsp;
<a class="button" href="log.php">&nbsp;Lastheard&nbsp;</a>
&nbsp;
<a class="button" href="tgcount.php">&nbsp;TG Count&nbsp;</a>
&nbsp;
</div>
</div>
<div class="dropdown">
  <button class="dropbtn">FreeDMR</button>
  <div class="dropdown-content">
&nbsp;
<a class="button" href="http://www.freedmr.uk/index.php/why-use-freedmr/"target="_blank">&nbsp;Info FreeDMR&nbsp;</a>
&nbsp;
<a class="button" href="http://www.freedmr.uk/index.php/freedmr-servers/"target="_blank">&nbsp;Info Server&nbsp;</a>
&nbsp;
<a class="button" href="http://www.freedmr.uk/server_test.php"target="_blank">&nbsp;Status Server&nbsp;</a>
&nbsp;
<a class="button" href="http://www.freedmr.uk/index.php/world-wide-talk-groups/"target="_blank">&nbsp;World Wide Talk Groups&nbsp;</a>
&nbsp;
<a class="button" href="http://www.freedmr.uk/freedmr/option-calculator-b.php"target="_blank">&nbsp;Static TG Calculator&nbsp;</a>
&nbsp;
</div>
</div>
<!--
<a class="button" href="bridges.php">Bridges</a>
-->
<!-- Example of buttons dropdown HTML code -->
<!--
<div class="dropdown">
  <button class="dropbtn">Admin Area</button>
  <div class="dropdown-content">
    <a href="masters.php">Master&Peer</a>
    <a href="opb.php">OpenBridge</a>
    <a href="moni.php">Monitor</a>
  </div>
</div>
<div class="dropdown">
  <button class="dropbtn">Reflectors</button>
  <div class="dropdown-content">
    <a target='_blank' href="#">YSF Reflector</a>
    <a target='_blank' href="#">XLX950</a>
  </div>
</div>
-->
EOF

####

sed -i "s/TGID_URL .*/TGID_URL = https:\/\/freedmr.cymru\/talkgroups\/talkgroup_ids_json.php/" fdmr-mon.cfg

sed -i "s/path2config .*/path2config = \"\/hbmon\/fdmr-mon.cfg\";/" html/include/config.php

chmod -R 777 /etc/freedmr/hbmon/log


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
sudo nano /etc/freedmr/hbmon/fdmr-mon.cfg  ;;
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
#
sudo cat > /bin/data-id <<- "EOF"
#!/bin/bash
wget /etc/freedmr/hbmon/data/talkgroup_ids.json https://freedmr.cymru/talkgroups/talkgroup_ids_json.php -O
wget /etc/freedmr/hbmon/data/subscriber_ids.csv https://database.radioid.net/static/user.csv -O
wget /etc/freedmr/hbmon/data/peer_ids.json https://database.radioid.net/static/rptrs.json -O

wget /etc/freedmr/json/talkgroup_ids.json https://freedmr.cymru/talkgroups/talkgroup_ids_json.php -O
wget /etc/freedmr/json/subscriber_ids.csv https://freedmr.cymru/talkgroups/users.json-O
wget /etc/freedmr/json/peer_ids.json https://database.radioid.net/static/rptrs.json -O

EOF
###############################################
sudo cat > /bin/start-fdmr <<- "EOF"
#!/bin/bash
cd /etc/freedmr
data-id
docker-compose down
docker-compose up -d
cronedit.sh '* */12 * * *' 'data-id' add
cronedit.sh '*/5 * * * *' 'sh /etc/freedmr/hbmon/sysinfo/graph.sh' add
cronedit.sh '*/2 * * * *' 'sh /etc/freedmr/hbmon/sysinfo/cpu.sh' add
EOF
#
sudo cat > /bin/stop-fdmr <<- "EOF"
#!/bin/bash
cd /etc/freedmr
docker-compose down
cronedit.sh '* */12 * * *' 'data-id' remove
cronedit.sh '*/5 * * * *' 'sh /etc/freedmr/hbmon/sysinfo/graph.sh' remove
cronedit.sh '*/2 * * * *' 'sh /etc/freedmr/hbmon/sysinfo/cpu.sh' remove
EOF
###############################################
cat > /usr/local/bin/cronedit.sh <<- "EOF"
cronjob_editor () {
# usage: cronjob_editor '<interval>' '<command>' <add|remove>
if [[ -z "$1" ]] ;then printf " no interval specified\n" ;fi
if [[ -z "$2" ]] ;then printf " no command specified\n" ;fi
if [[ -z "$3" ]] ;then printf " no action specified\n" ;fi
if [[ "$3" == add ]] ;then
    # add cronjob, no duplication:
    ( sudo crontab -l | grep -v -F -w "$2" ; echo "$1 $2" ) | sudo crontab -
elif [[ "$3" == remove ]] ;then
    # remove cronjob:
    ( sudo crontab -l | grep -v -F -w "$2" ) | sudo crontab -
fi
}
cronjob_editor "$1" "$2" "$3"
EOF
sudo chmod +x /usr/local/bin/cronedit.sh

#################################
echo "Run FreeDMR container..."
cd /etc/freedmr
docker-compose up -d

echo "Read notes in /etc/freedmr/docker-compose.yml to understand how to implement extra functionality."
echo "FreeDMR setup complete!"

#############################################################

chmod +x /bin/menu*
chmod +x /bin/MENU
chmod +x /bin/data-id
chmod +x /bin/start-fdmr
chmod +x /bin/stop-fdmr
data-id
history -c && history -w
menu
#####
