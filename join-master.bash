#!/bin/bash
# This also expects the token and master IP to be passed in as env variables
set -e
NODES="${1}"

CMD=$(cat <<EOCMD
cd /root;
if [ ! -d /root/haas-infrastructure ]; then git clone https://github.com/data-8/haas-infrastructure.git; fi;
cd haas-infrastructure
git fetch --quiet && git reset --hard --quiet origin/master
./install-kubeadm.bash
EOCMD
)

sudo clush -w "${NODES}" "${CMD}"
sudo clush -w "${NODES}" kubeadm join --token "${KUBEADM_TOKEN}"  "${KUBE_MASTER_IP}":6443
