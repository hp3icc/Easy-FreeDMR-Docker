#!/bin/bash
sudo cat > /bin/menu-update <<- "EOF"
#!/bin/bash
while : ; do
choix=$(whiptail --title "Raspbian Proyect HP3ICC EasyFreeDMR Menu Update" --menu "move up or down with the keyboard arrows and select your option by pressing enter:" 15 56 6 \
1 " Pull Update FreeDMR " \
2 " Main menu " 3>&1 1>&2 2>&3)
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
update-fdmr;;
2)
break;
esac
done
exit 0




EOF
#

sudo cat > /bin/update-fdmr <<- "EOF"
#!/bin/bash
cd /etc/freedmr
docker compose down
docker compose pull
docker compose up -d
EOF
sudo cat > /bin/update-fdmr2 <<- "EOF"
#!/bin/bash
stop-fdmr
cp /etc/freedmr/docker-compose.yml /opt/docker-compose.yml
variable=$(grep "SERVER_ID:" /etc/freedmr/freedmr.cfg | tail -c 6)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/install.sh)"
sudo sed -i "s/SERVER_ID:.*/SERVER_ID: $variable/g"  /etc/freedmr/freedmr.cfg
#cp /opt/docker-compose.yml /etc/freedmr/docker-compose.yml
cat /opt/obp.txt >> /etc/freedmr/freedmr.cfg
chmod +x /opt/extra.sh
sh /opt/extra.sh
start-fdmr

EOF
########################
chmod +x /bin/update-fdmr
chmod +x /bin/update-fdmr2
chmod +x /bin/menu-update
menu-update
