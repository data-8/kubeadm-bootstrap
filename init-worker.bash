#!/bin/bash
# This also expects the token and master IP to be passed in as env variables
set -e

source data/config.bash

kubeadm join --token "${KUBEADM_TOKEN}"  "${KUBE_MASTER_IP}":6443
