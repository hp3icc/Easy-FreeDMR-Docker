# Easy-FreeDMR-Docker   Proyecto en desarrollo, NO Utilizar !!!!!

 ![alt text](https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/FreeDMR-Docker.png)

is an excerpt from the emq-TE1ws proyect, focused on new and current sysops who want to install FreeDMR Docker Version easily, quickly and up-to-date.

this shell, install FreeDMR Server and FDMR-Monitor

#

FreeDMR Server Self-Service version Docker by CA5RPY Rodrigo, with Dashboard by OA4DOA ,last original version gitlab FreeDMR by G7RZU hacknix Simon.

#

# Pre-Requirements

need have curl and sudo installed

#

# Install

into your ssh terminal copy and paste the following link :

    apt-get update
    apt-get install curl sudo -y

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/install.sh)"
             
             
 #            
  
 # Menu
 
 ![alt text](https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/easy-freedmr-docker.png)
 
  At the end of the installation your freedmr server will be installed and working, a menu will be displayed that will make it easier for you to edit, restart or update your server and dashboard to future versions.
  
  to use the options menu, just type menu in your ssh terminal or console.
  
 #
 
 # Server startup

To integrate your server to the freedmr network, you must contact the telegram group

 * https://t.me/FreeDMR_Building_Server_Support
        
 #
 
 #
 
 # Location files config :
 
  * FreeDMR Server:  
   
  /etc/freedmr/freedmr.cfg  
   
  * FreeDMR Rules: 
   
  /etc/freedmr/rules.py  
   
  * FDMR-Monitor: 
   
   /etc/freedmr/hbmon/fdmr-mon.cfg
   
   
 #
  
 # Dashboard Files
 
 /etc/freedmr/hbmon/html/

#

 # Sources :
 
 * https://gitlab.hacknix.net/hacknix/FreeDMR
 
 * http://www.freedmr.uk/index.php/freedmr-server-install/
 
 * https://github.com/yuvelq/FDMR-Monitor/tree/Self_Service
  
 


