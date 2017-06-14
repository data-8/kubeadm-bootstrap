#!/bin/bash

set -e

# Install support chart, and get nginx-ingress to work

helm install --name=support --namespace=support support/

# Until https://github.com/kubernetes/charts/pull/1250 gets merged
kubectl --namespace=support patch deployment support-nginx-ingress-controller -p '{"spec": {"template": { "spec": { "hostNetwork": true } } } }'
