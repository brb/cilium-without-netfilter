#!/bin/bash

set -ex

NODE_IP_ADDR=$1
WITH_NETFILTER=$2

swapoff -a

apt install -y tuned psmisc
tuned-adm profile network-latency
killall irqbalance

kubeadm config print init-defaults --component-configs KubeletConfiguration > k8s-config.yaml
sed -i "s/advertiseAddress: 1.2.3.4/advertiseAddress: ${NODE_IP_ADDR}/g" k8s-config.yaml
[ "$WITH_NETFILTER" = "1" ] || sed -i 's/makeIPTablesUtilChains: true/makeIPTablesUtilChains: false/g' k8s-config.yaml
sed -i '/serviceSubnet: 10.96.0.0\/12/a foobar' k8s-config.yaml
sed -i 's/foobar/  podSubnet: 10.217.0.0\/16/g' k8s-config.yaml
SKIP_PHASES_PARAM=""
[ "$WITH_NETFILTER" = "1" ] || SKIP_PHASES_PARAM="--skip-phases=addon/kube-proxy"

kubeadm init $SKIP_PHASES_PARAM --config k8s-config.yaml --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables,SystemVerification

rm -rf $HOME/.kube
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-

sed -i "s/NODE_MASTER_IP/${NODE_IP_ADDR}/g" cilium.yaml
kubectl apply -f cilium.yaml
