cat > /bin/menu <<- "EOF"
#!/bin/bash
while : ; do
choix=$(whiptail --title "Raspbian Proyect HP3ICC EasyFreeDMR Docker Version by CA5RPY" --menu "move up or down with the keyboard arrows and select your option by pressing enter:" 17 65 8 \
1 " Edit FreeDMR Server " \
2 " Edit Interlink  " \
3 " Edit FDMR-Monitor  " \
4 " Edit docker-Compose.yml  " \
5 " Start & Restart FreeDMR Server  " \
6 " Stop FreeDMR Server " \
7 " Info list Container Run  " \
8 " update " 3>&1 1>&2 2>&3)
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
nano /etc/freedmr/freedmr.cfg ;;
2)
nano /etc/freedmr/rules.py ;;
3)
nano /etc/freedmr/hbmon/fdmr-mon.cfg  ;;
4)
nano /etc/freedmr/docker-compose.yml ;;
5)
start-fdmr ;;
6)
stop-fdmr ;;
7)
docker stats --all ;;
8)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/update.sh)";
esac
done
exit 0

EOF

##
chmod +x /bin/menu*
chmod +x /bin/MENU
ln -s /bin/menu /bin/MENU
