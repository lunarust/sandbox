#!/bin/bash
if [ $# -ne 2 ]
  then
    echo "No or incorrect arguments supplied"
    echo "Usage: $0 (inspect_filter) (container_name)"
    echo "Example: $0 .State.Running core"
        exit 1
fi

if [ "$1" = ".Image.Tag" ]; then
        ver=$(docker inspect -f {{.Config.Image}} $2)
        tag=$(echo $ver |  awk -F ":" '{print $2}' || true)
        if [ -z $tag ]
                then
                        echo "Last"
                else
                  echo $tag
                      # if [[ "$tag" =~ .*"develop".* ]]; then
                      #    echo $tag | cut -d. -f 2
                      # elif [[ "$tag" =~ .*"release".* ]]; then
                      #    echo $(echo $tag | awk -F "_" '{print $NF}')
                      # else
                      #   echo $tag
                      #fi
        fi
        else
               docker inspect -f {{$1}} $2

fi
