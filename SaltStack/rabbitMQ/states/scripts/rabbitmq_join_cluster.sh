#!/bin/bash
#===============================================================================
#         FILE: rabbitmq_join_cluster.sh
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


rabbitmqctl stop_app
rabbitmqctl join_cluster {{ salt['pillar.get']('rabbitmq_cluster_name') }}
rabbitmqctl start_app
