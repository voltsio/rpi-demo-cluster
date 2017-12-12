#!/bin/bash

set -e

kubectl label node pico0 blinktShow-
kubectl label node pico1 blinktShow-
kubectl label node pico2 blinktShow-
kubectl label node pico3 blinktShow-
kubectl label node pico4 blinktShow-

kubectl label node pico0 blinktShow=true
kubectl label node pico1 blinktShow=true
kubectl label node pico2 blinktShow=true
kubectl label node pico3 blinktShow=true
kubectl label node pico4 blinktShow=true


kubectl label node pico1 blinktImage=pods
kubectl label node pico1 blinktShow=true
kubectl label node pico1 blinktReadyColor=cpu
sleep 1

kubectl label node pico2 blinktImage=pods
kubectl label node pico2 blinktShow=true
kubectl label node pico2 blinktReadyColor=cpu
sleep 1

kubectl label node pico3 blinktImage=pods
kubectl label node pico3 blinktShow=true
kubectl label node pico3 blinktReadyColor=cpu
sleep 1

kubectl label node pico4 blinktImage=pods
kubectl label node pico4 blinktShow=true
kubectl label node pico4 blinktReadyColor=cpu
sleep 1
