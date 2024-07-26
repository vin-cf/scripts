#!/bin/bash

: '
Reconnect Bluetooth Mouse Script

This script attempts to reconnect a Bluetooth mouse with changing MAC addresses.
It is specifically designed for Fedora Linux and has been tested with the Logitech M590 mouse.

Usage:
1. Ensure the script is executable: sudo chmod +x /usr/local/bin/connect-mouse.sh
2. Run the script: ./connect-mouse.sh
'


BLUETOOTHCTL=$(which bluetoothctl)


read_config() {
    local config_file=$1
    readarray -t config < "$config_file"
    echo "${config[@]}"
}

attempt_connection() {
    local base_address=$1
    local start_range=$2
    local end_range=$3

    for ((i=0x$start_range; i<=0x$end_range; i++)); do
        HEX=$(printf "%02X" $i)
        $BLUETOOTHCTL connect "$base_address:$HEX"
        if [ $? -eq 0 ]; then
            echo "Connected to $base_address:$HEX"
            return 0
        fi
    echo "Failed to connect to $base_address"
    done

    return 0
}

config1=$(read_config "m590-config.txt")
config2=$(read_config "mx-ergo-config.txt")

IFS=' ' read -r -a config1_array <<< "$config1"
IFS=' ' read -r -a config2_array <<< "$config2"


attempt_connection "${config1_array[0]}" "${config1_array[1]}" "${config1_array[2]}"
attempt_connection "${config2_array[0]}" "${config2_array[1]}" "${config2_array[2]}"
