#!/bin/bash

{
  set -x
  touch_input_id=$(xinput --list | grep "Finger touch" | sed -e 's/.*id=\(.*\)\t.*/\1/')
  xinput --enable $touch_input_id
  set +x
}
