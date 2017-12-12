#!/bin/bash

set -e

kubectl label node pico0 blinktShow=true --overwrite
kubectl label node pico0 blinktImage=pods --overwrite
kubectl label node pico0 blinktReadyColor=cpu --overwrite

kubectl label node pico1 blinktShow=true --overwrite
kubectl label node pico1 blinktImage=pods --overwrite
kubectl label node pico1 blinktReadyColor=cpu --overwrite

kubectl label node pico2 blinktShow=true --overwrite
kubectl label node pico2 blinktImage=pods --overwrite
kubectl label node pico2 blinktReadyColor=cpu --overwrite

kubectl label node pico3 blinktShow=true --overwrite
kubectl label node pico3 blinktImage=pods --overwrite
kubectl label node pico3 blinktReadyColor=cpu --overwrite

kubectl label node pico4 blinktShow=true --overwrite
kubectl label node pico4 blinktImage=pods --overwrite
kubectl label node pico4 blinktReadyColor=cpu --overwrite
