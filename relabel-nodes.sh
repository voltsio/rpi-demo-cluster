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
