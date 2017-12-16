#!/bin/bash

set -e

function label() {
  kubectl label node "pico$1" blinktShow-
  kubectl label node "pico$1" blinktImage-
  kubectl label node "pico$1" blinktReadyColor-
  kubectl label node "pico$1" blinktShow=true
  kubectl label node "pico$1" blinktImage=pods
  kubectl label node "pico$1" blinktReadyColor=cpu
}

label 0
label 1
label 2
label 3
label 4
