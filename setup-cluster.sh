#!/bin/bash

set -e

function error {
    echo -e " Failed\nCheck the log for details.\n$1"
}

function resource_wait {
  echo ""
    while [ "$(kubectl get $1 -n $2 $3 -o json | jq .status.$4)" != "$5" ]
    do
        echo "kubectl get $1 -n $2 $3 -o json | jq .status.$4"
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

if [ "$1" == "clean" ]; then
  echo -n "Resetting k8s cluster..."
  sudo kubeadm reset >> log 2>&1
  sleep 10

  echo -ne " Done\nResetting workers..."
  parallel-ssh -i -h worker-nodes -t 0 -v "sudo kubeadm reset" >> log 2>&1

  sleep 10
  echo -ne " Done\nEverything is reset. Starting clean.\n\n"
fi

echo -n "Configuring k8s master..."
sudo kubeadm init --config config.yaml >> log 2>&1
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config >> log 2>&1
sudo chown $(id -u):$(id -g) $HOME/.kube/config >> log 2>&1

echo -ne " Done\nInstalling flannel..."
kubectl apply -f kube-flannel.yaml >> log 2>&1

echo -ne " Done\nWaiting for flannel..."
ds_wait kube-system kube-flannel-ds 1

echo -ne " Done\nJoining workers..."
parallel-ssh -i -h worker-nodes -t 0 -v "sudo kubeadm reset && sudo kubeadm join --token 123456.1234567890123456 10.0.121.2:6443 >> log 2>&1"

echo -ne " Done\nWaiting for kube-proxy..."
ds_wait kube-system kube-proxy 5

echo -ne " Done\nWaiting for flannel to scale..."
ds_wait kube-system kube-flannel-ds 5

echo -ne " Done\nWaiting for kube-dns..."
deploy_wait kube-system kube-dns 1

# echo -ne " Done\nInstalling influxdb..."
# kubectl apply -f influxdb.yaml >> log 2>&1
#
# echo -ne " Done\nWaiting for influxdb..."
# deploy_wait kube-system monitoring-influxdb 1
#
# echo -ne " Done\nInstalling heapster..."
# kubectl apply -f heapster.yaml >> log 2>&1
#
# echo -ne " Done\nWaiting for heapster..."
# deploy_wait kube-system heapster 1

echo -ne " Done\nInstalling traefik..."
kubectl apply -f traefik.yaml >> log 2>&1

echo -ne " Done\nLabeling loadBalancer..."
kubectl label node pico0 loadBalancer=true >> log 2>&1

echo -ne " Done\nWaiting for traefik..."
deploy_wait kube-system traefik-ingress-controller 1

# echo -ne " Done\nInstalling kubernetes-dashboard..."
# kubectl apply -f kubernetes-dashboard.yaml >> log 2>&1
#
# echo -ne " Done\nWaiting for kubernetes-dashboard..."
# deploy_wait kube-system kubernetes-dashboard 1

echo -ne " Done\nInstalling blinkt nodes..."
kubectl apply -f blinkt-k8s-controller-rbac.yaml >> log 2>&1
kubectl apply -f blinkt-k8s-controller-nodes.yaml >> log 2>&1

echo -ne " Done\nLabeling master node..."
kubectl label node "pico0" blinktShow-
kubectl label node "pico0" blinktImage-
kubectl label node "pico0" blinktReadyColor-
kubectl label node "pico0" blinktShow=true
kubectl label node "pico0" blinktImage=nodes
kubectl label node "pico0" blinktReadyColor=cpu

echo -ne " Done\nLabeling nodes..."
./relabel-nodes.sh

echo -ne " Done\nInstalling blinkt pods..."
kubectl apply -f blinkt-k8s-controller-pods.yaml >> log 2>&1

echo -ne " Done\nWaiting for blinkt pods..."
ds_wait kube-system blinkt-k8s-controller-pods 4

echo -ne " Done\nInstalling pi..."
kubectl apply -f pi.yaml >> log 2>&1

echo -ne " Done\nWaiting for pi..."
deploy_wait default pi 1

# echo -ne " Done\nInstalling load-simulator..."
# kubectl apply -f load-simulator.yaml >> log 2>&1
#
# echo -ne " Done\nWaiting for load-simulator..."
# deploy_wait default load-simulator 1

echo -e " Done\nCluster setup complete."
