#!/bin/bash
#===============================================================================
#         FILE: backup_es_indices.sh
#      CREATED: 05-08-2021
#      UPDATED:
#      PLUGINS: /usr/share/elasticsearch/bin/elasticsearch-plugin 
#               install file:////tmp/repository-s3-6.8.18.zip
#         TODO: https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html
#===============================================================================
#HOSTNAME=HOSTNAMEaster01.mgmt.local
# check space
#curl -sX GET "${HOSTNAME}:9200/_nodes/stats/fs
DATE=`date '+%Y-%m-%d'`
HOSTNAME=$HOSTNAME
HOSTNAMESHORT="LOC"


#curl -X PUT "${HOSTNAME}:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
#   "transient": {
#       "cluster.routing.allocation.disk.watermark.low": "10gb",
#       "cluster.routing.allocation.disk.watermark.high": "2gb",
#       {
#       "cluster.routing.allocation.disk.watermark.flood_stage": "2gb",
#       "cluster.info.update.interval": "1m"
#   }
#}#
#'echo "####################"
echo "Check repository, if exists we can skip the init var"
curl -X GET "${HOSTNAME}:9200/_snapshot/backup_${HOSTNAMESHORT}" | jq


echo "####################"
echo "Check all existing snapshots"
curl -X GET "${HOSTNAME}:9200/_snapshot/backup_${HOSTNAMESHORT}_all?pretty" | jq



echo "####################"
echo "Check snapshots status"
curl -X GET "${HOSTNAME}:9200/_snapshot/_status" | jq


echo "####################"
if [ "$1" = "INIT" ]; then
echo "Register repository -- to do only once"
curl -X PUT "${HOSTNAME}:9200/_snapshot/backup_${HOSTNAMESHORT}" -H 'Content-Type: application/json' -d'
{
  "type": "s3",
  "settings": {
    "client": "default",
    "bucket": "s3-bucketname",
    "region": "eu-west-1"
  }
}
'
fi

echo "####################"
if [ "$1" = "CREATE" ]; then
  echo "Creating a backup"
  curl -X PUT "${HOSTNAME}:9200/_snapshot/backup_${HOSTNAMESHORT}/snapshot_${DATE}?wait_for_completion=false&pretty"


fi


if [ "$1" = "CHECK" ]; then

  echo "####################"
  echo "Check today snapshot status"
  curl -X GET "${HOSTNAME}:9200/_snapshot/backup_${HOSTNAMESHORT}/snapshot_${DATE}/_status?pretty"

fi

if [ "$1" = "UNLOCK" ]; then
  echo "Unlock ES indices"
  curl -XPUT -H "Content-Type: application/json" {HOSTNAME}:9200/_all/_settings -d '{"index.blocks.read_only_allow_delete": null}'
fi
