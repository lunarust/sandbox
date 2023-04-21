#!/bin/bash
dockernames=$(docker ps -a --format {{.Names}})
echo "{"
echo "\"data\":["
for name in $dockernames
do
    if [ "$name" != "checkboot" ]; then
      echo "    {\"{#CONTAINERNAME}\":\"$name\"},"
    fi
done|sed '$s/,//'
echo "]"
echo "}"
