#!/bin/sh
######################################
curl https://gitlab.hacknix.net/hacknix/FreeDMR/-/raw/master/docker-configs/docker-compose_install.sh | bash
#curl https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/docker-compose_install.sh | bash
######################################
chmod 755 /etc/freedmr -R
sudo sed -i 's/VOICE_IDENT: True/VOICE_IDENT: False/' /etc/freedmr/freedmr.cfg
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

sudo cat > /opt/obp.txt <<- "EOF"
#Coloque abajo su lista de obp


EOF
#
sudo cat > /bin/start-fdmr <<- "EOF"
#!/bin/bash
cd /etc/freedmr
docker-compose down
docker-compose up -d
EOF
#
sudo cat > /bin/stop-fdmr <<- "EOF"
#!/bin/bash
cd /etc/freedmr
docker-compose down
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

