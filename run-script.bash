#!/bin/bash
set -e

NODES=${1}
SCRIPT=${2}

CMD=$(cat <<EOCMD
cd /root;
if [ ! -d /root/haas-infrastructure ]; then git clone https://github.com/data-8/haas-infrastructure.git; fi;
cd haas-infrastructure
git reset --hard && git pull origin master -q
${2}
EOCMD
   )

clush -w "${NODES}" "${CMD}"
