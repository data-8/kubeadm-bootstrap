#!/bin/bash

set -e

# For now, just set up permissive RBAC rules.
kubectl create clusterrolebinding permissive-binding \
        --clusterrole=cluster-admin \
        --user=admin \
        --user=kubelet \
        --group=system:serviceaccounts
