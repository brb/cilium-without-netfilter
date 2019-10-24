# Cilium without Netfilter

## Kernel

* https://gitlab.com/brb/linux-5.3-wo-nf -- v5.3 without netfilter (`CONFIG_NETFILTER=n`)
* https://gitlab.com/brb/linux-5.3-with-nf -- v5.3 with netfilter

## Steps

1. Download, install the kernel, reboot: `dpkg -i *.deb && update-grub`.
2. Install Docker:

```
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
apt-get update && apt-get install -y docker-ce
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "iptables": false
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker
```

3. Install kubeadm and Kubernetes:

```
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```

4. Deploy Kubernetes master:

```
export NODE_IP_ADDR=...
kubeadm config print init-defaults --component-configs KubeletConfiguration > k8s-config.yaml
sed -i "s/advertiseAddress: 1.2.3.4/advertiseAddress: ${NODE_IP_ADDR}/g" k8s-config.yaml
sed -i 's/makeIPTablesUtilChains: true/makeIPTablesUtilChains: false/g' k8s-config.yaml
sed -i '/serviceSubnet: 10.96.0.0\/12/a foobar' k8s-config.yaml
sed -i 's/foobar/  podSubnet: 10.217.0.0\/16/g' k8s-config.yaml
kubeadm init --skip-phases=addon/kube-proxy --config k8s-config.yaml --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables,SystemVerification
kubectl taint nodes --all node-role.kubernetes.io/master-
```

5. Join Kubernetes workers:

```
kubeadm joint ${NODE_IP_ADDR}:6443 --token abcdef.0123456789abcdef --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables,SystemVerification
```

6. Rename ifaces:

```
cat /etc/udev/rules.d/70-persistent-net.rules
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="02:01:02:03:04:05", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="eth1"
```

7. Install Cilium:

```
sed -i "s/NODE_MASTER_IP/${NODE_IP_ADDR}/g" cilium.yaml
kubectl apply -f cilium.yaml
```
