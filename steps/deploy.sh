#!/usr/bin/env bash
set -eu

kubectl create -f ping.yaml

until $(kubectl get pods -l app=ping-destination -o jsonpath='{.items[0].status.containerStatuses[0].ready}'); do
    echo "Waiting for ping destination busybox to start..."
    sleep 5
done

echo "Busybox at ping destination is running"
echo
