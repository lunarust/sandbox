#!/bin/bash

if [ $# -ne 2 ]
  then
    echo "No or incorrect arguments supplied"
    echo "Usage: $0 (container_name) (CPU|MEMUSAGE|MEMPERCENT|NETI|NETO|BLOCKI|BLOCKO)"
    echo "Example: $0 core CPU"
    exit 1
fi

case "$2" in
        CPU)
        docker stats --no-stream $1 | tail -n +2 | awk '{print $3}' | tr % ' '
        ;;
        MEMUSAGE)
        value=$(docker stats --no-stream $1 | tail -n +2 | awk '{print $4}''{print $6}')
        echo $value
        ;;
        MEMPERCENT)
        docker stats --no-stream $1 | tail -n +2 | awk '{print $7}' | tr % ' '
        ;;
        NETI)
        value=$(docker stats --no-stream $1 | tail -n +2 | awk '{print $8}')
        echo $value
        ;;
        NETO)
        value=$(docker stats --no-stream $1 | tail -n +2 | awk '{print $9}')
        echo $value
        ;;
        BLOCKI)
        value=$(docker stats --no-stream $1 | tail -n +2 | awk '{print $10}')
        echo $value
        ;;
        BLOCKO)
        value=$(docker stats --no-stream $1 | tail -n +2 | awk '{print $12}')
        echo $value
        ;;
        *)
        echo "Usage: $0 (container_name) (CPU|MEMUSAGE|MEMPERCENT|NETI|NETO|BLOCKI|BLOCKO)"
        exit 1
esac
