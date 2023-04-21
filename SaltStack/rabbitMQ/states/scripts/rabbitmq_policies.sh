#!/bin/bash
#===============================================================================
#         FILE: rabbitmq_policies.sh
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

rabbitmqctl set_policy ha-two "^[a-z]*(?:\-[a-z]+)*(?:\.[a-z]+)*(?:\_[a-z]+)*$" \
	'{"ha-mode":"exactly","ha-params":2,"ha-promote-on-failure":"always","ha-promote-on-shutdown":"when-synced"}'
