#!/bin/bash

sudo cat > /bin/menu-update <<- "EOF"
#!/bin/bash
while : ; do
choix=$(whiptail --title "Raspbian Proyect HP3ICC EasyFreeDMR Menu Update" --menu "move up or down with the keyboard arrows and select your option by pressing enter:" 15 56 6 \
1 " Update FreeDMR Server " \
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
#
########################
chmod +x /bin/update-fdmr
chmod +x /bin/menu-update
menu-update
