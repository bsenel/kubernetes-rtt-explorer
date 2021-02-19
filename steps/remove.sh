#!/usr/bin/env bash
set -eu

kubectl delete --cascade -f ping.yaml
