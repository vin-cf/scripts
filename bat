#!/bin/bash
upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'state|time|capacity|energy-rate'

