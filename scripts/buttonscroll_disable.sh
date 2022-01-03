#!/bin/bash

{
  # Disable "on-button scrolling" for a trackpoint device. This interferes with
  # using the middle trackpoint button for camera movements (rotate, pan, etc)
  # in 3D software (Blender, Simplify3D, etc).
  set -x
  touch_input_id=$(xinput --list | grep "TPPS/2 Elan TrackPoint" | sed -e 's/.*id=\(.*\)\t.*/\1/')
  xinput --set-prop $touch_input_id "libinput Scroll Method Enabled" 0 0 0
  set +x
}
