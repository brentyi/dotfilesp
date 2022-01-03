#!/bin/bash

{
  # Re-enable "on-button scrolling" for a trackpoint device. This is useful for scrolling!
  set -x
  touch_input_id=$(xinput --list | grep "TPPS/2 Elan TrackPoint" | sed -e 's/.*id=\(.*\)\t.*/\1/')
  xinput --set-prop $touch_input_id "libinput Scroll Method Enabled" 0 0 1
  set +x
}
