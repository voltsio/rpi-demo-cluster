#!/bin/bash

set -e

N="$1"

function label() {
  kubectl label node "pico$1" blinktShow-
  kubectl label node "pico$1" blinktImage-
  kubectl label node "pico$1" blinktReadyColor-
  kubectl label node "pico$1" blinktShow=true
  kubectl label node "pico$1" blinktImage=pods
  kubectl label node "pico$1" blinktReadyColor=cpu
}

label "$N"
