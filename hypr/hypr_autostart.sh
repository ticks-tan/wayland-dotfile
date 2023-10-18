#!/usr/bin/env bash

## Copyright (C) 2023 Ticks <ticks.cc@gmail.com>
##
## Hyprland autostart script
##

DIR="${HOME}/.config/hypr"
SCRIPTS="${DIR}/scripts"

if [[ -f "${DIR}/.current" ]]; then
	source ${DIR}/.current
else
	source ${DIR}/custom/theme.sh
fi

if [[ ! "${hypr_lock_timeout}" ]]; then
	local hypr_lock_timeout=600
fi

import_gtk3_theme() {
	config="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
	if [ ! -f "$config" ]; then
		return
	fi

	gnome_schema="org.gnome.desktop.interface"
	gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"
	icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"
	cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"
	font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"
	gsettings set "$gnome_schema" gtk-theme "$gtk_theme"
	gsettings set "$gnome_schema" icon-theme "$icon_theme"
	gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
	gsettings set "$gnome_schema" font-name "$font_name"
}

set_xdg_desktop() {
	killall -e xdg-desktop-portal-hyprland
	killall -e xdg-desktop-portal-wlr
	killall xdg-desktop-portal
	/usr/lib/xdg-desktop-portal-hyprland &
	sleep 1
	/usr/lib/xdg-desktop-portal &
}

lock_manager() {
	killall -9 swayidle
	swayidle -w \
		timeout ${hypr_lock_timeout} "hyprctl dispatcher dpms off && bash ${SCRIPTS}/hyprlock" &
}

start_always() {
	## this function will exec always

	## Set gtk theme
	import_gtk3_theme

	## 权限认证程序
	if [[ ! $(pidof xfce-polkit) ]]; then
		/usr/lib/xfce-polkit/xfce-polkit &
	fi

	## 壁纸
	killall -9 hyprpaper

	if [[ "${hypr_dis_random_logo}" == "true" ]]; then
		hyprpaper &
	fi

	hyprctl setcursor ${XCURSOR_THEME} ${XCURSOR_SIZE}

}

start_once() {
	## this function will exec once

	set_xdg_desktop

	lock_manager

	echo ""
}

if [[ "$1" == "always" ]]; then
	start_always
	exit 0
elif [[ "$1" == "once" ]]; then
	start_once
	exit 0
else
	exit 1
fi
