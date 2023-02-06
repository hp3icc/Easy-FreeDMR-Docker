####   table
cat > /etc/freedmr/hbmon/templates/main_table.html  <<- "EOF"

<fieldset class="big">
<legend><b><font color="#000">&nbsp;.: Server Activity :.&nbsp;</font></b></legend>
{% if _table['MASTERS']|length >0 %}
 <table style="table-layout:fixed;width:1100px; font: 10pt arial, sans-serif;margin-top:5px;margin-bottom:5px;" width=1100px>
    <tr style="background-color:#265b8a;" "height:30px;font: 10pt arial, sans-serif;{{ themec }}">
        <th>Systems M&P</th>
        <th>Source</th>
        <th>Destination</th>        
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
         <table style='width:1100px; font: 13pt arial, sans-serif; margin-top:8px;'>
             <tr style='border:none; background-color:#f1f1f1;'>
             <td style='border:none;height:60px;'><font color=brown><b><center>Waiting for Data from FreeDMR Server ...</center></b></td>
             </tr>
            </table>
 {% endif %}
    {% for _peer, _pdata  in _table['PEERS'].items() %}
    {% if _pdata[1]['TS'] == True or _pdata[2]['TS'] == True %}
    <tr style="background-color:#f9f9f9f9;">
        {% if _pdata[1]['TRX'] == "RX" %}
        <td style="font-weight:bold; padding-left: 20px; text-align:center;color:#464646;">P: {{_peer}} </td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#0d1a81;">{{ _pdata[1]['SUB']|safe }} [<span style="align-items: center;justify-content:center;font-size: 8pt;font-weight:600;color:brown;">TS {{ 1 if _pdata[1]['TS'] == True else 2 }}</span>]</td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#b5651d;">{{ _cdata[1]['DEST']|safe }}</td>
        {% endif %}
        {% if _pdata[2]['TRX'] == "RX" %}
        <td style="font-weight:bold; padding-left: 20px; text-align:center;color:#464646;">P: {{_peer}} </td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#0d1a81;">{{ _pdata[2]['SUB']|safe }} [<span style="align-items: center;justify-content:center;font-size: 8pt;font-weight:600;color:brown;">TS {{ 1 if _pdata[1]['TS'] == True else 2 }}</span>]</td>
        <td style="font: 9.5pt arial, sans-serif;font-weight: 600;color:#b5651d;">{{ _pdata[2]['DEST']|safe }}</td>
        {% endif %}
    </tr>
    {% endif %}
    {% endfor %}
    <tr style="background-color:#f0f0f0;"><td colspan=3 height=5pt><hr style="height:1px;border:none;color:#f0f0f0;background-color:#f0f0f0;"></hr></td></tr>
{% if _table['OPENBRIDGES']|length >0 %}
    <tr style="background-color:#265b8a;" "height:30px;width:1100px; font: 10pt arial, sans-serif;{{ themec }}">
        <th>Systems OpenBridge</th>
        <th colspan=2 '>Active Incoming Calls</th>
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
<fieldset class="big">
  <legend><b>.: Lastheard :.</b></legend>
  <table class="log">
    <tr>
      <th>Date</th>
      <th>Time</th>
      <th>Callsign (DMR-Id)</th>
      <th>Name</th>
      <th>TG#</th>
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
<fieldset class="big">
  <legend><b>.: Connected to Server :.</b></legend>
  <div class="conn2srv">
    {% if _table['MASTERS']|length >0 %}
      <h4 class="tittle">USERS:</h4>
        <div class="hs-peers">
          {% for _master in _table['MASTERS'] %}    
          {% if _table['MASTERS'][_master]['PEERS']|length >0 %}
          {% for _client, _cdata in _table['MASTERS'][_master]['PEERS'].items() %}
          <div class="tooltip">
               <a target="_blank" href="http://www.qrz.com/db/{{_cdata['CALLSIGN']}}"><b>{{_cdata['CALLSIGN']}}</b></a>
              <b>DMR ID</b>: <span class="txt-yellow"><b>{{ _client }}</b></span><br>
              {% if _cdata['RX_FREQ'] == 'N/A' and _cdata['TX_FREQ'] == 'N/A' %}
              <b>Type: <span class="txt-yellow">IP Network</span></b><br>
              {% else %} 
              <b>Type: <span class="txt-yellow">Radio</span></b>&nbsp;({{ _cdata['SLOTS'] }})<br>
              {% endif %}
              <b>Hardware</b>: {{_cdata['PACKAGE_ID'] }}<br>
              <b>Soft_Ver</b>: {{_cdata['SOFTWARE_ID'] }}<br>
              <b>Info</b>: {{_cdata['LOCATION']}}<br>
              <b>Master</b>: <span class="txt-yellow">{{_master}}</span><br>
              <b>Time connected</b>: <span class="txt-yellow"><SPAN STYLE="text-shadow: 0.15em 0.15em #9e9e9e">{{ _cdata['CONNECTED'] }}</span>
            </div>
          </div>
          {% endfor %}
          {% endif %}
          {% endfor %}
        </div>
        {% endif %}
        {% if _table['PEERS']|length >0 %}
        <h4 class="tittle">PEERS:</h4>
        <div class="hs-peers">
          {% for _peer, _pdata  in _table['PEERS'].items() %}
          <span class="tooltip" style="border-bottom: 1px dotted white;{{'background-color:#98FB98; color:#464646;' if _table['PEERS'][_peer]['STATS']['CONNECTION'] == 'YES' else 'background-color:#ff0000; color:white;'}}"><b>&nbsp;&nbsp;{{_pdata['CALLSIGN']}}&nbsp;&nbsp;</b>            {% if _table['PEERS'][_peer]['STATS']['CONNECTION'] == 'YES' %}
            <span class="tooltiptext c2s-pos2">Connected</span>
            {% else %}
            <span class="tooltiptext c2s-pos2"><b>Disconnected</b></span>
            {% endif %}
          </div>
          {% endfor %}
        </div>
        {% endif %}
  </div>
</fieldset>

EOF
#
cat > /lib/systemd/system/fdmr_mon.service  <<- "EOF"
[Unit]
Description=FDMR Monitor
# To make the network-online.target available
# systemctl enable systemd-networkd-wait-online.service
#After=network-online.target syslog.target
#Wants=network-online.target
[Service]
User=root
Type=simple
Restart=always
RestartSec=3
StandardOutput=null
WorkingDirectory=/opt/FDMR-Monitor
ExecStartPre=/bin/sh -c 'until ping -c1 noip.com; do sleep 1; done;'
ExecStart=python3 /opt/FDMR-Monitor/monitor.py
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOF
#
sudo sed -i "s/Copyright (c) 2016-.*/Copyright (c) <?php \$cdate=date(\"Y\"); if (\$cdate > \"2016\") {\$cdate=\"2016-\".date(\"Y\");} echo \$cdate; ?><br>/g" /etc/freedmr/hbmon/html/*.php
sudo sed -i "s/meta name=\"description.*/meta name=\"description\" content=\"Copyright (c) 2016-22.The Regents of the K0USY Group. All rights reserved. Version OA4DOA 2022 (v270422)\">/g" /etc/freedmr/hbmon/html/*.php
sudo sed -i "s/All rights reserved.<br>.*/All rights reserved.<br><a title=\"Raspbian Proyect by HP3ICC © <?php \$cdate=date(\"Y\"); if (\$cdate > \"2018\") {\$cdate=\"2018-\".date(\"Y\");} echo \$cdate; ?>\" target=\"_blank\" href=https:\/\/github.com\/hp3icc\/Easy-FreeDMR-Docker\/>Proyect: Easy-FreeDMR-Docker<\/a><br>/g" /etc/freedmr/hbmon/html/*.php
##
sudo sed -i '166 s/hotpink/#ad02fd/g'   /etc/freedmr/hbmon/html/css/styles.php
sudo sed -i '217 s/color:white/color:black/' /etc/freedmr/hbmon/html/css/styles.php
sudo sed -i "251d" /etc/freedmr/hbmon/html/css/styles.php
sed '250 a    <?php echo THEME_COLOR."\\n";?>' -i /etc/freedmr/hbmon/html/css/styles.php

sed '21 a # For custom color, select: pro' -i /etc/freedmr/hbmon/fdmr-mon.cfg

sed '24 a COLOR_TEXT = #d2c564' -i /etc/freedmr/hbmon/fdmr-mon.cfg 
sed '25 a COLOR_1 = #c68034' -i /etc/freedmr/hbmon/fdmr-mon.cfg  
sed '26 a COLOR_2 = #7f5224' -i /etc/freedmr/hbmon/fdmr-mon.cfg
sed '27 a COLOR_BACKGROUND = 5a5958' -i /etc/freedmr/hbmon/fdmr-mon.cfg

sed '45 a   $cd1 = strtolower($config["GLOBAL"]["COLOR_1"]);' -i /etc/freedmr/hbmon/html/include/config.php  
sed '46 a   $cd2 = strtolower($config["GLOBAL"]["COLOR_2"]);' -i /etc/freedmr/hbmon/html/include/config.php  
sed '47 a   $cd3 = strtolower($config["GLOBAL"]["COLOR_TEXT"]);' -i /etc/freedmr/hbmon/html/include/config.php 
sed '48 a   $cd3 = strtolower($config["GLOBAL"]["COLOR_TEXT"]);' -i /etc/freedmr/hbmon/html/include/config.php
sed '49 a   $cd4 = strtolower($config["GLOBAL"]["COLOR_BACKGROUND"]);' -i /etc/freedmr/hbmon/html/include/config.php 

sed '66 a   } elseif ($theme == "pro") {' -i /etc/freedmr/hbmon/html/include/config.php  
sed '67 a     $tc = "background-image: linear-gradient(to bottom, $cd1 0%, $cd2 100%);color:$cd3;";' -i /etc/freedmr/hbmon/html/include/config.php 
