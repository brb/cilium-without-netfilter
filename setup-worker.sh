#!/bin/bash

set -ex

swapoff -a

NODE_IP_ADDR=$1

kubeadm join ${NODE_IP_ADDR}:6443 --token abcdef.0123456789abcdef --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables,SystemVerification
