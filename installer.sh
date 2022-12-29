#!/bin/sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/hp3icc/Easy-FreeDMR-Docker/main/install.sh)"
start-fdmr
history -c && history -w
menu
