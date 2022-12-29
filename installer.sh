#!/bin/sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/install.sh)"
start-fdmr
sudo cat > /opt/extra.sh <<- "EOF"
#!/bin/bash
######################################################################
# Coloque en este archivo, cualquier instruccion shell adicional que # 
# quierre se realice al finalizar un Full Upgrade desde el menu.     #
######################################################################
 
EOF
sudo cat > /opt/obp.txt <<- "EOF"
######################################################################
# Coloque abajo su lista de obp y peer para que se agreguen          #
al finalizar un Full Upgrade desde el menu.                          #
######################################################################
 

EOF

chmod +x /opt/extra.sh
history -c && history -w
menu
