#!/bin/bash
set -e

source data/config.bash
source data/secrets.bash

echo "After this is done, you need to manually edit /etc/kubernetes/manifests/kube-apiserver.yaml"
echo "Adding --bind-address=${KUBE_MASTER_IP} to the command of the container, right below --advertise-address"
echo "Should be fixed by https://github.com/kubernetes/kubeadm/issues/305"

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address="${KUBE_MASTER_IP}" --token="${KUBEADM_TOKEN}"

