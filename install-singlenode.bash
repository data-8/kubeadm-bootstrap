#!/bin/bash
set -e

# Install kubernetes with kubeadm on this one node
# Should be run as root

./install-kubeadm.bash

# Make config!
echo "export KUBE_MASTER_IP=$(ip route get 1 | awk '{print $NF;exit}')" >> data/config.bash
echo "export KUBEADM_TOKEN=$(kubeadm token generate)" >> data/config.bash

./init-master.bash
