#!/bin/bash
#===============================================================================
#         FILE: rabbitmq_init.sh
#       AUTHOR: Celine H.
# ORGANIZATION: ---
#      VERSION: 0.0.1
#      CREATED: 29-05-2020
#         TODO:
#===============================================================================

if [ $EUID != 0 ]
  then echo -e "${RED}Please run as root!${nc}"
  exit
fi

rabbitmq-plugins enable rabbitmq_management rabbitmq_top rabbitmq_web_dispatch
