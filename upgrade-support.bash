#!/bin/bash

set -e

# Upgrade support, and do the appropriate patching for afterwards

helm upgrade support support/

# Until https://github.com/kubernetes/charts/pull/1250 gets merged
kubectl --namespace=support patch deployment support-nginx-ingress-controller -p '{"spec": {"template": { "spec": { "hostNetwork": true } } } }'
