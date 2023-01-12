#!/bin/sh
if [[ $EUID -ne 0 ]]; then
	whiptail --title "Easy-FreeDMR-Docker" --msgbox "Debe ejecutar este script como usuario ROOT" 0 50
	exit 0
fi
######################################

echo FreeDMR Docker installer...

echo Installing required packages...
echo Install Docker Community Edition...

apt-get remove docker docker-engine docker.io containerd runc -y

apt-get update
apt-get install git ca-certificates curl gnupg lsb-release -y

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

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
#
if [ -d "/tmp/Easy-FreeDMR-Docker" ];
then
    rm -rf /tmp/Easy-FreeDMR-Docker
fi
if [ -d "/etc/freedmr" ];
then
    rm -rf /etc/freedmr
fi
if [ -d "/opt/FreeDMR" ];
then
    rm -rf /opt/FreeDMR
fi
if [ -d "/opt/FDMR-Monitor" ];
then
    rm -rf /opt/FDMR-Monitor
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
chown 54000:54000 /etc/freedmr/

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
VALIDATE_SERVER_IDS: False


[REPORTS]
REPORT: True
REPORT_INTERVAL: 60
REPORT_PORT: 4321
REPORT_CLIENTS: *

[LOGGER]
LOG_FILE: /dev/null
LOG_HANDLERS: console-timed
LOG_LEVEL: DEBUG
LOG_NAME: FreeDMR


[ALIASES]
TRY_DOWNLOAD: True
PATH: ./json/
PEER_FILE: peer_ids.json
SUBSCRIBER_FILE: subscriber_ids.json
TGID_FILE: talkgroup_ids.json
PEER_URL: https://www.radioid.net/static/rptrs.json
SUBSCRIBER_URL: https://www.radioid.net/static/users.json
#TGID_URL: http://downloads.freedmr.uk/downloads/talkgroup_ids.json
TGID_URL: https://freedmr.cymru/talkgroups/talkgroup_ids_json.php
LOCAL_SUBSCRIBER_FILE: local_subcriber_ids.json
STALE_DAYS: 1
SUB_MAP_FILE:
SERVER_ID_URL: http://downloads.freedmr.uk/downloads/FreeDMR_Hosts.csv
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
IP: 172.16.238.10
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
RADIO_ID: 9990
RX_FREQ: 449000000
TX_FREQ: 444000000
TX_POWER: 25
COLORCODE: 1
SLOTS: 1
LATITUDE: 00.0000
LONGITUDE: 000.0000
HEIGHT: 0
LOCATION: Local Parrot
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


sed -i "s/MASTER .*/MASTER = 172.16.238.10/" proxy/proxy.cfg
sed -i "s/SERVER .*/SERVER = mariadb/" proxy/proxy.cfg
sed -i "s/USERNAME .*/USERNAME = hbmon/" proxy/proxy.cfg
sed -i "s/PASSWORD .*/PASSWORD = hbmon/" proxy/proxy.cfg
sed -i "s/DB_NAME .*/DB_NAME = hbmon/" proxy/proxy.cfg


#################
cat > /etc/freedmr/hbmon/templates/main_table.html  <<- "EOF"
<fieldset style="background-color:#A7A2A2;text-algin: lef; margin-left:15px;margin-right:15px;font-size:14px;border-top-left-radius: 10px; border-top-right-radius: 10px;border-bottom-left-radius: 10px; border-bottom-right-radius: 10px;">
<center><b> Server Activity </b></legend></center>
{% if _table['MASTERS']|length >0 %}
 <table style="table-layout:fixed;width:100%; font: 10pt arial, sans-serif;margin-top:5px;margin-bottom:5px;" width=100%>
    <tr style="background-color:#265b8a;" "height:30px;font: 10pt arial, sans-serif;{{ themec }}">
        <th style=color:#f1f1f1; 'width: 20%;'>Systems M&P</th>
        <th style=color:#f1f1f1; 'width: 40%;'>Source</th>
        <th style=color:#f1f1f1; 'width: 40%;'>Destination</th>        
    </tr>
    {% for _master in _table['MASTERS'] %}    
    {% for _client, _cdata in _table['MASTERS'][_master]['PEERS'].items() %}
    {% if _cdata[1]['TS'] == True or _cdata[2]['TS'] == True %}
    <tr style="background-color:#a1dcb5;">
        {% if _cdata[1]['TRX'] == "RX" %}
        <td style="font-weight:bold; padding-left: 20px; text-align:center;color:#464646;">M: {{_master}} </td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#0d1a81;">{{ _cdata[1]['SUB']|safe }} [<span style="align-items: center;justify-content:center;font-size: 8pt;font-weight:600;color:brown;">TS {{ 1 if _cdata[1]['TS'] == True else 2 }}</span>]</td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#b5651d;">{{ _cdata[1]['DEST']|safe }}</td>
        {% endif %}
        {% if _cdata[2]['TRX'] == "RX" %}
        <td style="font-weight:bold; padding-left: 20px; text-align:center;color:#464646"><b>M: {{_master}} </td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#0d1a81;">{{ _cdata[2]['SUB']|safe }} [<span style="align-items: center;justify-content:center;font-size: 8pt;font-weight:600;color:brown;">TS {{ 1 if _cdata[1]['TS'] == True else 2 }}</span>]</td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#b5651d;">{{ _cdata[2]['DEST']|safe }}</td>
        {% endif %}
    </tr>
    {% endif %}
    {% endfor %}
    {% endfor %}
{% else %}
         <table style='width:100%; font: 13pt arial, sans-serif; margin-top:8px;'>
             <tr style='border:none; background-color:#A7A2A2;'>
             <td style='border:none;height:60px;'><font color=brown><b><center>Waiting for Data from FreeDMR Server ...</center></b></td>
             </tr>
            </table>
 {% endif %}
    {% for _peer, _pdata  in _table['PEERS'].items() %}
    {% if _pdata[1]['TS'] == True or _pdata[2]['TS'] == True %}
    <tr style="background-color:#de8184;">
        {% if _pdata[1]['TRX'] == "RX" %}
        <td style="font-weight:bold; padding-left: 20px; text-align:center;color:#000000;">P: {{_peer}} </td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#000000;">{{ _pdata[1]['SUB']|safe }} [<span style="align-items: center;justify-content:center;font-size: 8pt;font-weight:600;color:black;">TS {{ 1 if _pdata[1]['TS'] == True else 2 }}</span>]</td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#000000;">{{ _cdata[1]['DEST']|safe }}</td>
        {% endif %}
        {% if _pdata[2]['TRX'] == "RX" %}
        <td style="font-weight:bold; padding-left: 20px; text-align:center;color:#000000;">P: {{_peer}} </td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#000000;">{{ _pdata[2]['SUB']|safe }} [<span style="align-items: center;justify-content:center;font-size: 8pt;font-weight:600;color:black;">TS {{ 1 if _pdata[1]['TS'] == True else 2 }}</span>]</td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#000000;">{{ _pdata[2]['DEST']|safe }}</td>
        {% endif %}
    </tr>
    {% endif %}
    {% endfor %}
    <tr style="background-color:#A7A2A2;"><td colspan=3 height=5pt><hr style="height:1px;border:none;color:#A7A2A2;background-color:#A7A2A2;"></hr></td></tr>
{% if _table['OPENBRIDGES']|length >0 %}
    <tr style="background-color:#265b8a;" "height:30px;width:100%; font: 10pt arial, sans-serif;{{ themec }}">
        <th style=color:#f1f1f1; 'width: 50%;'>Systems OpenBridge</th>
        <th colspan=2 style=color:#f1f1f1; 'width: 50%;'>Active Incoming Calls</th>
    </tr>
    {% for _openbridge in _table['OPENBRIDGES'] %}
    {% set rx = namespace(value=0) %}
    {% if _table['OPENBRIDGES'][_openbridge]['STREAMS']|length >0 %}
       {% for entry in _table['OPENBRIDGES'][_openbridge]['STREAMS'] if _table['OPENBRIDGES'][_openbridge]['STREAMS'][entry][0]=='RX' %}
         {% set rx.value=1 %}
       {% endfor %}
       {% if rx.value == 1 %}    
       <tr style="background-color:#de8184;">
         <td style="font-weight:bold; padding-left: 20px; text-align:center;"> {{ _openbridge}} </td>
         <td colspan=2 style="background-color:#a1dcb5; font: 9pt arial, sans-serif; font-weight: 600; color:#464646;">
         {% for entry in _table['OPENBRIDGES'][_openbridge]['STREAMS']  if _table['OPENBRIDGES'][_openbridge]['STREAMS'][entry][0] == 'RX' %}[<span style="color:#008000;">{{ _table['OPENBRIDGES'][_openbridge]['STREAMS'][entry][0] }}</span>: <font color=#0065ff> {{ _table['OPENBRIDGES'][_openbridge]['STREAMS'][entry][1] }}</font> >> <font color=#b5651d> {{ _table['OPENBRIDGES'][_openbridge]['STREAMS'][entry][2] }}</font>]&nbsp; {% endfor %}
        </td>
      </tr>
      {% endif %}
   {% endif %}
   {% endfor %}
{% endif %}
</table>
</fieldset>
{% if _table['SETUP']['LASTHEARD'] == True %}
<br><fieldset style="border-radius: 8px; background-color:#A7A2A2;margin-left:15px;margin-right:15px;font-size:14px;border-top-left-radius: 10px; border-top-right-radius: 10px;border-bottom-left-radius: 10px; border-bottom-right-radius: 10px;">
  <center><b> Lastheard </b></legend></center>
  <table style="table-layout:fixed;width:100%; font: 10pt arial, sans-serif;font-weight:600;margin-top:5px;margin-bottom:5px;border:none !important;border-collapse:collapse;border:none;" width=100%>
    <tr>
      <th>Date</th>
      <th>Time</th>
      <th>Callsign (DMR-Id)</th>
      <th>Name</th>
      <th>Talk Group</th>
      <th>TG Name</th>
      <th>TX (s)</th>
      <th>System</th>
    </tr>
  {% for itm in lastheard %}
    <tr>
      <td>{{ itm[0][:10] }}</td>
      <td>{{ itm[0][11:] }}</td>
    {% if not itm[7] %}
      <td class="txt-464646"><b>{{ itm[6] }}</b></td>
      <td></td>
    {% else %}
      <td><a target="_blank" href=https://qrz.com/db/{{itm[7][0]}}>{{ itm[7][0] }}</a></b><span class="fnt-7pt">&nbsp;({{ itm[6] }})</span></td>
      <td class="txt-002d62"><b>{{ itm[7][1] }}</b></td>
    {% endif %}
      <td class="txt-b5651d"><b>{{ itm[4] }}</b></td>
      <td class="txt-green"><b>{{ '' if not itm[5] else itm[5]|safe }}</b></td>
      <td {{ 'class="bkgnd-1d1"'|safe if not itm[1] else '' }}>{{ 'DATA' if not itm[1] else itm[1]|int }}</td>
      <td>{{ itm[3] }}</td>
    </tr>
  {% endfor %}
  </table>
</fieldset>
{% endif %}
<fieldset style="width:1070;background-color:#A7A2A2;text-algin: lef; margin-left:15px;margin-right:15px;font-size:14px;border-top-left-radius: 10px; border-top-right-radius: 10px;border-bottom-left-radius: 10px; border-bottom-right-radius: 10px;">
<center><b> Connected to Server System </b></legend></center>
<table style="table-layout:fixed;width:100%; font: 10pt arial, sans-serif;font-weight:600;margin-top:5px;margin-bottom:5px;" width=100%>
{% if _table['MASTERS']|length >0 %}
<tr style="background-color:#A7A2A2;"><td>
<br>
<div style="text-align:left;"><span style="color:#464646;font-weight:600;line-height:1.4;">&nbsp;&nbsp;LINKS:</span></div>
<div style="text-align:left;font:9.5pt arial, sans-serif;font-weight:bold;margin-left:25px; margin-right:25px;line-height:1.4;white-space:normal;">
    {% for _master in _table['MASTERS'] %}    
    {% if _table['MASTERS'][_master]['PEERS']|length >0 %}
    {% for _client, _cdata in _table['MASTERS'][_master]['PEERS'].items() %}
    <span class="tooltip" style="border-bottom: 0px dotted white;">
    <a style="border-bottom: 0px dotted white;font: 9.5pt arial,sans-serif;font-weight:bold;color:#0066ff;" target="_blank" href="http://www.qrz.com/db/{{_cdata['CALLSIGN']}}"><b>{{_cdata['CALLSIGN']}}</b></a>
    <span class="tooltiptext" style="left:115%;top:-10px;">
        <span style="font: 9pt arial,sans-serif;color:#FFFFFF">
        &nbsp;&nbsp;&nbsp;<b>DMR ID</b>: <b><font color=yellow>{{ _client }}</b></font><br>
        {% if _cdata['RX_FREQ'] == 'N/A' and _cdata['TX_FREQ'] == 'N/A' %}
             &nbsp;&nbsp;&nbsp;<b>Type: <font color=yellow>IP Network</font></b><br>
        {% else %} 
            &nbsp;&nbsp;&nbsp;<b>Type: <font color=yellow>Radio</font></b> ({{ _cdata['SLOTS'] }})<br>
        {% endif %}
        &nbsp;&nbsp;&nbsp;<b>Hardware</b>: {{_cdata['PACKAGE_ID'] }}
        <br>&nbsp;&nbsp;&nbsp;<b>Soft_Ver</b>: {{_cdata['SOFTWARE_ID'] }}
        <br>&nbsp;&nbsp;&nbsp;<b>Info</b>: {{_cdata['LOCATION']}}
         <br>&nbsp;&nbsp;&nbsp;<b>Master</b>: <font color=yellow>{{_master}}</font>
        </span></span></span>&nbsp;
    {% endfor %}
    {% endif %}
    {% endfor %}
</div>
{% endif %}
{% if _table['PEERS']|length >0 %}
<br>
<div style="text-align:left;"><span style="color:#464646;font-weight:600;line-height:1.4;">&nbsp;&nbsp;PEERS:</span></div>
<div style="text-align:left;font:9.5pt arial, sans-serif;font-weight:bold;margin-left:25px; margin-right:25px;line-height:1.6;white-space:normal;">
    {% for _peer, _pdata  in _table['PEERS'].items() %}
    <span class="tooltip" style="border-bottom: 1px dotted white;{{'background-color:#98FB98; color:#464646;' if _table['PEERS'][_peer]['STATS']['CONNECTION'] == 'YES' else 'background-color:#ff0000; color:white;'}}"><b>&nbsp;&nbsp;{{_pdata['CALLSIGN']}}&nbsp;&nbsp;</b>
    <span class="tooltiptext" style="top:120%;left:50%;margin-left:-160%;width:160px;">
    <center>&nbsp;&nbsp;<b>Peer</b>: <font color=yellow>{{_peer}}</font>&nbsp;&nbsp;</center>
    </span></span>&nbsp;
 {% endfor %}
</div>
{% endif %}
<br>
</td></tr></table>
</fieldset>
EOF
#############################
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
(crontab -l; echo "* */6 * * * data-id")|awk '!x[$0]++'|crontab -
###
cat > /etc/freedmr/hbmon/html/buttons.php <<- "EOF"
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
######################################################################################

sudo sed -i '166 s/hotpink/#ad02fd/g'   /etc/freedmr/hbmon/html/css/styles.php
sudo sed -i '217 s/color:white/color:black/'  /etc/freedmr/hbmon/html/css/styles.php
sudo sed -i "251d" /etc/freedmr/hbmon/html/css/styles.php
sed '250 a    <?php echo THEME_COLOR."\\n";?>' -i /etc/freedmr/hbmon/html/css/styles.php

sed '21 a # For custom color, select: pro' -i /etc/freedmr/hbmon/fdmr-mon.cfg

sed '24 a COLOR_TEXT = #d8ea00' -i /etc/freedmr/hbmon/fdmr-mon.cfg 
sed '25 a COLOR_1 = #29d103' -i /etc/freedmr/hbmon/fdmr-mon.cfg  
sed '26 a COLOR_2 = #000000' -i /etc/freedmr/hbmon/fdmr-mon.cfg
sed '27 a COLOR_BACKGROUND =  #adadad  ' -i /etc/freedmr/hbmon/fdmr-mon.cfg

sed '45 a   $cd1 = strtolower($config["GLOBAL"]["COLOR_1"]);' -i /etc/freedmr/hbmon/html/include/config.php  
sed '46 a   $cd2 = strtolower($config["GLOBAL"]["COLOR_2"]);' -i /etc/freedmr/hbmon/html/include/config.php  
sed '47 a   $cd3 = strtolower($config["GLOBAL"]["COLOR_TEXT"]);' -i /etc/freedmr/hbmon/html/include/config.php 
sed '48 a   $cd3 = strtolower($config["GLOBAL"]["COLOR_TEXT"]);' -i /etc/freedmr/hbmon/html/include/config.php
sed '49 a   $cd4 = strtolower($config["GLOBAL"]["COLOR_BACKGROUND"]);' -i /etc/freedmr/hbmon/html/include/config.php 

sed '66 a   } elseif ($theme == "pro") {' -i /etc/freedmr/hbmon/html/include/config.php  
sed '67 a     $tc = "background-image: linear-gradient(to bottom, $cd1 0%, $cd2 100%);color:$cd3;";' -i /etc/freedmr/hbmon/html/include/config.php  

######################################
chmod 755 /etc/freedmr -R

#############################
sh -c "$(curl -fsSL https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/menu.sh)"

###############################################
cat > /bin/start-fdmr <<- "EOF"
#!/bin/bash
data-id &&
cd /etc/freedmr
docker compose down
docker compose up -d
cronedit.sh '*/5 * * * *' 'sh /etc/freedmr/hbmon/sysinfo/graph.sh' add
cronedit.sh '*/2 * * * *' 'sh /etc/freedmr/hbmon/sysinfo/cpu.sh' add
cronedit.sh '* */6 * * *' 'data-id' add
EOF
#
cat > /bin/stop-fdmr <<- "EOF"
#!/bin/bash
cd /etc/freedmr
docker compose down
cronedit.sh '*/5 * * * *' 'sh /etc/freedmr/hbmon/sysinfo/graph.sh' remove
cronedit.sh '*/2 * * * *' 'sh /etc/freedmr/hbmon/sysinfo/cpu.sh' remove
cronedit.sh '* */6 * * *' 'data-id' remove
EOF
###############################################
cat > /bin/data-id <<- "EOF"
#!/bin/bash
wget https://freedmr.cymru/talkgroups/talkgroup_ids_json.php -O /etc/freedmr/hbmon/data/talkgroup_ids.json
wget https://database.radioid.net/static/user.csv -O /etc/freedmr/hbmon/data/subscriber_ids.csv
wget https://database.radioid.net/static/rptrs.json -O /etc/freedmr/hbmon/data/peer_ids.json
wget https://freedmr.cymru/talkgroups/talkgroup_ids_json.php -O /etc/freedmr/json/talkgroup_ids.json
wget https://freedmr.cymru/talkgroups/users.json -O /etc/freedmr/json/subscriber_ids.csv
wget https://database.radioid.net/static/rptrs.json -O /etc/freedmr/json/peer_ids.json
EOF
#################################
cat > /usr/local/bin/cronedit.sh <<- "EOF"
cronjob_editor () {
# usage: cronjob_editor '<interval>' '<command>' <add|remove>
if [[ -z "$1" ]] ;then printf " no interval specified\n" ;fi
if [[ -z "$2" ]] ;then printf " no command specified\n" ;fi
if [[ -z "$3" ]] ;then printf " no action specified\n" ;fi
if [[ "$3" == add ]] ;then
    # add cronjob, no duplication:
    ( crontab -l | grep -v -F -w "$2" ; echo "$1 $2" ) | crontab -
elif [[ "$3" == remove ]] ;then
    # remove cronjob:
    ( crontab -l | grep -v -F -w "$2" ) | crontab -
fi
}
cronjob_editor "$1" "$2" "$3"
EOF
chmod +x /usr/local/bin/cronedit.sh
#################################

echo "Run FreeDMR container..."
cd /etc/freedmr
docker compose up -d

echo "Read notes in /etc/freedmr/docker-compose.yml to understand how to implement extra functionality."
echo "FreeDMR setup complete!"

#############################################################
chmod +x /bin/data-id
chmod +x /bin/start-fdmr
chmod +x /bin/stop-fdmr

#####

