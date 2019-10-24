#!/bin/bash

set -ex

swapoff -a

NODE_IP_ADDR=$1
kubeadm config print init-defaults --component-configs KubeletConfiguration > k8s-config.yaml
sed -i "s/advertiseAddress: 1.2.3.4/advertiseAddress: ${NODE_IP_ADDR}/g" k8s-config.yaml
sed -i 's/makeIPTablesUtilChains: true/makeIPTablesUtilChains: false/g' k8s-config.yaml
sed -i '/serviceSubnet: 10.96.0.0\/12/a foobar' k8s-config.yaml
sed -i 's/foobar/  podSubnet: 10.217.0.0\/16/g' k8s-config.yaml
kubeadm init --skip-phases=addon/kube-proxy --config k8s-config.yaml --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables,SystemVerification

rm -rf $HOME/.kube
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-

sed -i "s/NODE_MASTER_IP/${NODE_IP_ADDR}/g" cilium.yaml
kubectl apply -f cilium.yaml
