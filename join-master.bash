#!/bin/bash
# This expects to be run from the worker node
# This also expects the token and master IP to be passed in as env variables
set -e
kubeadm join --token "${KUBEADM_TOKEN}"  "${KUBE_MASTER_IP}":6443
