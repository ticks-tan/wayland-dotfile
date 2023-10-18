#!/usr/bin/env bash

## Copyright (C) 2023 Ticks <ticks.cc@gmail.com>
##
## Launch waybar script
##

#CUR_DIR="$(cd "$(dirname "${BASE_SOURCE[0]}")" &>/dev/null && pwd)"
#echo "${CUR_DIR}"
CUR_DIR="${HOME}/.config/hypr/bar/waybar"

launch_bar() {
	killall -q waybar

	while pgrep -u $UID -x waybar >/dev/null; do sleep 1; done

	waybar -c "${CUR_DIR}"/config.json -s "${CUR_DIR}"/style.css &
}

launch_bar
