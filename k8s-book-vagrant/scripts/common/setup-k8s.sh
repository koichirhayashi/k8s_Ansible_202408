#!/bin/bash

set -euo pipefail

KUBERNETES_VERSION=1.18.0-00

# install lecagy binary
sudo apt-get install -y iptables arptables ebtables

# install kubernetes repository
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /
EOF
sudo apt-get update -y

# install kubeadm, kubelet, kubectl
sudo apt-get install -y kubelet=${KUBERNETES_VERSION} kubeadm=${KUBERNETES_VERSION} kubectl=${KUBERNETES_VERSION}
sudo apt-mark hold kubelet kubeadm kubectl

# get private network IP addr and set bind it to kubelet
IPADDR=$(ip a show enp0s8 | grep inet | grep -v inet6 | awk '{print $2}' | cut -f1 -d/)
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--node-ip=${IPADDR}
EOF

# restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
