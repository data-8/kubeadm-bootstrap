#!/bin/bash
set -e

kubeadm init --pod-network-cidr=10.244.0.0/16

# By now the master node should be ready!
mkdir -p ~/.kube
ln -s /etc/kubernetes/admin.conf ~/.kube/config

# Install flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

# Make master node a running worker node too!
# FIXME: Use taint tolerations instead in the future
kubectl taint nodes --all node-role.kubernetes.io/master-

# Install helm
curl https://storage.googleapis.com/kubernetes-helm/helm-v2.8.0-linux-amd64.tar.gz | tar xvz
mv linux-amd64/helm /usr/local/bin
rm -rf linux-amd64

kubectl --namespace kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
kubectl --namespace=kube-system patch deployment tiller-deploy --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'

# Wait for tiller to be ready!
kubectl rollout status --namespace=kube-system deployment/tiller-deploy --watch

# Install nginx and other support stuff!
helm install --name=support --namespace=support support/
