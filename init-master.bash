#!/bin/bash
set -e

source data/config.bash
source data/secrets.bash

echo "After this is done, you need to manually edit /etc/kubernetes/manifests/kube-apiserver.yaml"
echo "Adding --bind-address=${KUBE_MASTER_IP} to the command of the container, right below --advertise-address"
echo "Alsos change the host of the health chck to ${KUBE_MASTER_IP} from 127.0.0.1"
echo "Should be fixed by https://github.com/kubernetes/kubeadm/issues/305"

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address="${KUBE_MASTER_IP}" --token="${KUBEADM_TOKEN}"

# By now the master node should be ready!
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install flannel
kubectl apply -f kube-flannel-rbac.yaml
kubectl apply -f kube-flannel.yaml

# Make master node a running worker node too!
# FIXME: Use taint tolerations instead in the future
kubectl taint nodes --all node-role.kubernetes.io/master-

# Mark the master as ingress node too!
# FIXME: figure out what to do about this later?
kubectl label $(kubectl get node -o name) node-role.kubernetes.io/ingress=""

# For now, just set up permissive RBAC rules.
# FIXME: Set up proper permissions instead!
kubectl create clusterrolebinding permissive-binding \
        --clusterrole=cluster-admin \
        --user=admin \
        --user=kubelet \
        --group=system:serviceaccounts

# Install helm
curl https://storage.googleapis.com/kubernetes-helm/helm-v2.4.2-linux-amd64.tar.gz | tar xvz
mv linux-amd64/helm /usr/local/bin
rm -rf linux-amd64

/usr/local/bin/helm init

# Wait for tiller to be ready!
# HACK: Do this better

sleep 1m

# Install nginx and other support stuff!
helm install --name=support --namespace=support support/

# Until https://github.com/kubernetes/charts/pull/1250 gets merged
kubectl --namespace=support patch deployment support-nginx-ingress-controller -p '{"spec": {"template": { "spec": { "hostNetwork": true } } } }'
