#!/bin/bash

set -e

curl https://storage.googleapis.com/kubernetes-helm/helm-v2.4.2-linux-amd64.tar.gz | tar xvz
mv linux-amd64/helm /usr/local/bin
rm -rf linux-amd64
