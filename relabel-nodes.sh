#!/bin/bash

set -e

N="$1"

function label() {
  kubectl label node "pico$N" blinktShow-
  kubectl label node "pico$N" blinktImage-
  kubectl label node "pico$N" blinktReadyColor-
  kubectl label node "pico$N" blinktShow=true
  kubectl label node "pico$N" blinktImage=pods
  kubectl label node "pico$N" blinktReadyColor=cpu
}

label "$N"
