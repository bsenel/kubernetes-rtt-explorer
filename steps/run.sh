#!/usr/bin/env bash
exec &> ./rtt-log.txt
set -eu

SOURCES=$(kubectl get pods -l app=ping-source -o name | cut -d'/' -f2)
DESTINATION=$(kubectl get pods -o jsonpath='{.items[0].status.podIP}')

kubectl get pods -l app=ping-destination -o jsonpath='{.items[0].status.podIP}'

counter=0
for POD in ${SOURCES}; do
    until [[ $(kubectl get pod ${POD} -o jsonpath='{.status.containerStatuses[0].ready}') || "$counter" -gt 5 ]]; do
        counter=$((counter+1))
        echo "Waiting for ${POD} to start..."
        sleep 5
    done

    if [ "$counter" -lt 6 ]
    then
      HOST=$(kubectl get pod ${POD} -o jsonpath='{.status.hostIP}')
      echo "Source is ${HOST}"
      printf "Current date and time: %s\n" "$(date +'%m-%d-%Y %H:%M:%S')"
      kubectl exec -it ${POD} -- ping ${DESTINATION} -c 100 &
      sleep 120
      echo
    else
      echo "Timeout: ${POD}"
    fi
done
