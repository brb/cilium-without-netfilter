#!/bin/bash

# Should be run from a client host
# REPLACE_ME in netperf.yaml with worker node name (retrieved via `kubectl get nodes`)

set -exu

MASTER_IP="$1"
WORKER_IP="$2"
RESULTS_FILE="$3"

prev=1
for i in 1 100 1000 2000 2767; do
    for j in $(seq $prev $i); do sed "s/xxx/$j/g" netperf-svc.yaml | kubectl apply -f -; done
    prev=$i
    echo "# SVC=$i" >> $RESULTS_FILE
    for j in $(seq 1 3); do
        PORT=$(kubectl get svc | grep "netperf-$((1 + RANDOM % i))" |awk '{print $5}' | cut -d: -f2 | cut -d/ -f1)
        echo "## TCP_CRR direct" >> $RESULTS_FILE
        $HOME/misc-scripts/latency_netperf $WORKER_IP $PORT CRR >> $RESULTS_FILE
        echo "## TCP_CRR remote" >> $RESULTS_FILE
        $HOME/misc-scripts/latency_netperf $MASTER_IP $PORT CRR >> $RESULTS_FILE
        echo "## TCP_RR direct" >> $RESULTS_FILE
        $HOME/misc-scripts/latency_netperf $WORKER_IP $PORT RR >> $RESULTS_FILE
        echo "## TCP_RR remote" >> $RESULTS_FILE
        $HOME/misc-scripts/latency_netperf $MASTER_IP $PORT RR >> $RESULTS_FILE
    done
done
