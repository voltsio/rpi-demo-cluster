#!/bin/bash

set -e

function error {
    echo -e " Failed\nCheck the log for details."
}

function resource_wait {
    while [ "$(kubectl get $1 -n $2 $3 -o json | jq .status.$4)" != "$5" ]
    do
        echo "$(kubectl get $1 -n $2 $3 -o json | jq .status.$4)"
        sleep 5
    done
}

function deploy_wait {
    resource_wait deploy $1 $2 availableReplicas $3
}

function ds_wait {
    resource_wait ds $1 $2 numberAvailable $3
}

trap error ERR

echo -n "Configuring k8s master..."
sudo kubeadm init --config config.yaml >> log 2>&1
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config >> log 2>&1
sudo chown $(id -u):$(id -g) $HOME/.kube/config >> log 2>&1

echo -ne " Done\nWaiting for kube-proxy..."
ds_wait kube-system kube-proxy 1

echo -ne " Done\nJoining workers..."
parallel-ssh -i -h worker-nodes -t 0 "sudo kubeadm join --skip-preflight-checks --token 123456.1234567890123456 10.34.42.182:6443" >> log 2>&1

echo -ne " Done\nInstalling flannel..."
kubectl apply -f kube-flannel.yaml >> log 2>&1

echo -ne " Done\nWaiting for kube-proxy..."
ds_wait kube-system kube-proxy 5

echo -ne " Done\nWaiting for flannel..."
ds_wait kube-system kube-flannel-ds 5

echo -ne " Done\nWaiting for kube-dns..."
deploy_wait kube-system kube-dns 1

echo -ne " Done\nInstalling influxdb..."
kubectl apply -f influxdb.yaml >> log 2>&1

echo -ne " Done\nWaiting for influxdb..."
deploy_wait kube-system monitoring-influxdb 1

echo -ne " Done\nInstalling heapster..."
kubectl apply -f heapster.yaml >> log 2>&1

echo -ne " Done\nWaiting for heapster..."
deploy_wait kube-system heapster 1

echo -ne " Done\nInstalling traefik..."
kubectl apply -f traefik.yaml >> log 2>&1

kubectl label node node1 loadBalancer=true >> log 2>&1

echo -ne " Done\nWaiting for traefik..."
deploy_wait kube-system traefik-ingress-controller 1

echo -ne " Done\nInstalling kubernetes-dashboard..."
kubectl apply -f kubernetes-dashboard.yaml >> log 2>&1

echo -ne " Done\nWaiting for kubernetes-dashboard..."
deploy_wait kube-system kubernetes-dashboard 1

echo -ne " Done\nInstalling blinkt nodes..."
kubectl apply -f blinkt-k8s-controller-rbac.yaml >> log 2>&1
kubectl apply -f blinkt-k8s-controller-nodes.yaml >> log 2>&1

kubectl label node pico0 blinktImage=nodes >> log 2>&1
kubectl label node pico0 blinktShow=true >> log 2>&1
kubectl label node pico0 blinktReadyColor=cpu >> log 2>&1
sleep 1

echo -ne " Done\nWaiting for blinkt nodes..."
ds_wait kube-system blinkt-k8s-controller-nodes 1

kubectl label node pico1 blinktImage=pods >> log 2>&1
kubectl label node pico1 blinktShow=true >> log 2>&1
kubectl label node pico1 blinktReadyColor=cpu >> log 2>&1
sleep 1

kubectl label node pico2 blinktImage=pods >> log 2>&1
kubectl label node pico2 blinktShow=true >> log 2>&1
kubectl label node pico2 blinktReadyColor=cpu >> log 2>&1
sleep 1

kubectl label node pico3 blinktImage=pods >> log 2>&1
kubectl label node pico3 blinktShow=true >> log 2>&1
kubectl label node pico3 blinktReadyColor=cpu >> log 2>&1
sleep 1

kubectl label node pico4 blinktImage=pods >> log 2>&1
kubectl label node pico4 blinktShow=true >> log 2>&1
kubectl label node pico4 blinktReadyColor=cpu >> log 2>&1
sleep 1

echo -ne " Done\nInstalling blinkt pods..."
kubectl apply -f blinkt-k8s-controller-pods.yaml >> log 2>&1

echo -ne " Done\nWaiting for blinkt pods..."
ds_wait kube-system blinkt-k8s-controller-pods 4

echo -ne " Done\nInstalling pi..."
kubectl apply -f pi.yaml >> log 2>&1

echo -ne " Done\nWaiting for pi..."
deploy_wait default pi 1

echo -ne " Done\nInstalling load-simulator..."
kubectl apply -f load-simulator.yaml >> log 2>&1

echo -ne " Done\nWaiting for load-simulator..."
deploy_wait default load-simulator 1

echo -e " Done\nCluster setup complete."
