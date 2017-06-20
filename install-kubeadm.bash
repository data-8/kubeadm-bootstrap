#!/bin/bash
apt-get update 
apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

# Install docker if you don't have it already.

apt-get install -y docker-engine

# Make sure you're using the overlay driver!
# Note that this gives us docker 1.11, which does *not* support overlay2

systemctl stop docker
modprobe overlay
echo '{"storage-driver": "overlay"}' > /etc/docker/daemon.json
rm -rf /var/lib/docker/*
systemctl start docker

# Install kubernetes components!
apt-get install -y kubelet kubeadm kubernetes-cni
