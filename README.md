# Cilium without Netfilter

## Kernels

* https://gitlab.com/brb/linux-5.3-wo-nf -- v5.3 without netfilter (`CONFIG_NETFILTER=n`)
* https://gitlab.com/brb/linux-5.3-with-nf -- v5.3 with netfilter
* https://gitlab.com/brb/linux-5.3-aws-with-nf
* https://gitlab.com/brb/linux-5.3-aws-wo-nf

## Scripts

* https://github.com/brb/misc-scripts

## Creating services

```
for i in $(seq 1 N); do sed 's/xxx/$i/g' netperf-svc.yaml | kubectl apply -f -; done
```
