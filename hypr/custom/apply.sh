#!/usr/bin/env bash

## Copyright (C) 2023 Ticks <ticks.cc@gmail.com>

HYPRDIR="${HOME}/.config/hypr"
THEME_DIR="${HYPRDIR}/custom"

if [[ ! -f "${THEME_DIR}/system.sh" ]]; then
	echo "${THEME_DIR}/system.sh not found"
	exit 1
fi
if [[ ! -f "${THEME_DIR}/color.sh" ]]; then
	echo "${THEME_DIR}/color.sh not found"
	exit 1
fi
if [[ ! -f "${THEME_DIR}/theme.sh" ]]; then
	echo "${THEME_DIR}/theme.sh not found"
	exit 1
fi

source ${THEME_DIR}/system.sh
source ${THEME_DIR}/color.sh
source ${THEME_DIR}/theme.sh

PATH_CLS="${HOME}/.cache/wal"
PATH_CONF="${HOME}/.config"
PATH_BAR="${HYPRDIR}/bar/waybar"
PATH_TERM="${HYPRDIR}/term/alacritty"
PATH_MENU="${HYPRDIR}/menu/rofi"
PATH_NOTIFY="${HYPRDIR}/notification/dunst"

wallpaper_path="$(echo ${wallpaper_path} | sed -e "s|^~\(.*\)|${HOME}\1|g")"

if [[ ! -f "${wallpaper_path}" ]]; then
	echo "${wallpaper_path} not found"
	auto_color="false"
fi

wal_cmd() {
	if [[ "${color_scheme}" == "light" ]]; then
		wal -i "${wallpaper_path}" -l -n -q -s -t -e
	else
		wal -i "${wallpaper_path}" -n -q -s -t -e
	fi
}

apply_wallpaper() {
	sed -i -e "s@preload=.*@preload=${wallpaper_path}@g" ${HYPRDIR}/hyprpaper.conf
	sed -i -e "s@\(wallpaper=[^,]*\),.*@\1,${wallpaper_path}@g" ${HYPRDIR}/hyprpaper.conf
}

apply_bar() {
	if [[ "${auto_color}" != "true" ]]; then
		cat >${PATH_BAR}/color.css <<-EOF

			    @define-color background   #${background};
			    @define-color foreground   #${foreground};

			    @define-color color0  #${color0};
			    @define-color color1  #${color1};
			    @define-color color2  #${color2};
			    @define-color color3  #${color3};
			    @define-color color4  #${color4};
			    @define-color color5  #${color5};
			    @define-color color6  #${color6};
			    @define-color color7  #${color7};

			    @define-color color8   #${color8};
			    @define-color color9   #${color9};
			    @define-color color10  #${color10};
			    @define-color color11  #${color11};
			    @define-color color12  #${color12};
			    @define-color color13  #${color13};
			    @define-color color14  #${color14};
			    @define-color color15  #${color15};
		EOF
	else
		cp ${PATH_CLS}/waybar_color.css ${PATH_BAR}/color.css
	fi
}

apply_menu() {
	sed -i -e "s@font:.*@font: \"${menu_font}\";@g" ${PATH_MENU}/shared/fonts.rasi
	if [[ "${auto_color}" != "true" ]]; then
		cat >${PATH_MENU}/shared/colors.rasi <<-EOF
			* {
			     background:     #${background};
			     background-alt: #${color8};
			     foreground:     #${foreground};
			     selected:       #${color5};
			     active:         #${color3};
			     urgent:         #${color1};
			}
		EOF
	else
		cp ${PATH_CLS}/rofi_color.rasi ${PATH_MENU}/shared/colors.rasi
	fi
}

apply_netmenu() {
	if [[ -f "$PATH_CONF"/networkmanager-dmenu/nmd.ini ]]; then
		sed -i -e "s#dmenu_command = .*#dmenu_command = rofi -dmenu -theme ${PATH_MENU}/networkmenu.rasi#g" ${PATH_CONF}/networkmanager-dmenu/nmd.ini
	fi
}

apply_terminal() {
	sed -i ${PATH_TERM}/fonts.yml \
		-e "s@family: .*@family: \"${term_font}\"@g" \
		-e "s@size: .*@size: ${term_font_size}@g"

	# alacritty : colors
	if [[ "${auto_color}" != "true" ]]; then
		cat >${PATH_TERM}/colors.yml <<-_EOF_
			colors:
			  # Default colors
			  primary:
			    background: "#${background}"
			    foreground: "#${foreground}"

			    dim_foreground: "#${color15}"
			    bright_foreground: "#${foreground}"

			  # Cursor colors
			  cursor:
			    text: "#${background}"
			    cursor: "#${foreground}"
			  vi_mode_cursor:
			    text: "#${background}"
			    cursor: "#${color2}"

			  # Search colors
			  search:
			    matches:
			      foreground: "#${background}"
			      background: "#${color8}"
			    focused_match:
			      foreground: "#${background}"
			      background: "#${color2}"
			    footer_bar:
			      foreground: "#${background}"
			      background: "#${color8}"

			  # Selection colors
			  selection:
			    text: "#${background}"
			    background: "#${color3}"

			  # Normal colors
			  normal:
			    black: "#${color0}"
			    red: "#${color1}"
			    green: "#${color2}"
			    yellow: "#${color3}"
			    blue: "#${color4}"
			    magenta: "#${color5}"
			    cyan: "#${color6}"
			    white: "#${color7}"

			  # Bright colors
			  bright:
			    black: "#${color8}"
			    red: "#${color9}"
			    green: "#${color10}"
			    yellow: "#${color11}"
			    blue: "#${color12}"
			    magenta: "#${color13}"
			    cyan: "#${color14}"
			    white: "#${color15}"

			  # Dim colors
			  dim:
			    black: "#${color8}"
			    red: "#${color9}"
			    green: "#${color10}"
			    yellow: "#${color11}"
			    blue: "#${color12}"
			    magenta: "#${color13}"
			    cyan: "#${color14}"
			    white: "#${color15}"
		_EOF_
	else
		cp ${PATH_CLS}/alacritty_color.yml ${PATH_TERM}/colors.yml
	fi
}

apply_gtk() {
	local XFILE="${HYPRDIR}/xsettingsd"
	local GTK2FILE="${HOME}/.gtkrc-2.0"
	local GTK3FILE="${PATH_CONF}/gtk-3.0/settings.ini"

	sed -i -e "s|Net/ThemeName .*|Net/ThemeName \"$gtk_theme\"|g" ${XFILE}
	sed -i -e "s|Net/IconThemeName .*|Net/IconThemeName \"$gtk_icon_theme\"|g" ${XFILE}
	sed -i -e "s|Gtk/CursorThemeName .*|Gtk/CursorThemeName \"$gtk_cursor_theme\"|g" ${XFILE}

	sed -i -e "s|gtk-font-name=.*|gtk-font-name=\"$gtk_font\"|g" ${GTK2FILE}
	sed -i -e "s|gtk-theme-name=.*|gtk-theme-name=\"$gtk_theme\"|g" ${GTK2FILE}
	sed -i -e "s|gtk-icon-theme-name=.*|gtk-icon-theme-name=\"$gtk_icon_theme\"|g" ${GTK2FILE}
	sed -i -e "s|gtk-cursor-theme-name=.*|gtk-cursor-theme-name=\"$gtk_cursor_theme\"|g" ${GTK2FILE}

	sed -i -e "s|gtk-font-name=.*|gtk-font-name=$gtk_font|g" ${GTK3FILE}
	sed -i -e "s|gtk-theme-name=.*|gtk-theme-name=$gtk_theme|g" ${GTK3FILE}
	sed -i -e "s|gtk-icon-theme-name=.*|gtk-icon-theme-name=$gtk_icon_theme|g" ${GTK3FILE}
	sed -i -e "s|gtk-cursor-theme-name=.*|gtk-cursor-theme-name=$gtk_cursor_theme|g" ${GTK3FILE}
}

apply_notifyd() {
	sed -i ${PATH_NOTIFY}/dunstrc \
		-e "s/width = .*/width = $notify_width/g" \
		-e "s/height = .*/height = $notify_height/g" \
		-e "s/font = .*/font = $notify_font/g" \
		-e "s/frame_width = .*/frame_width = $notify_border/g"

	sed -i '/urgency_low/Q' ${PATH_NOTIFY}/dunstrc
	if [[ "${auto_color}" != "true" ]]; then
		cat >>${PATH_NOTIFY}/dunstrc <<-_EOF_
			[urgency_low]
			timeout = 2
			background = "#${background}"
			foreground = "#${foreground}"
			frame_color = "#${color5}"

			[urgency_normal]
			timeout = 5
			background = "#${background}"
			foreground = "#${foreground}"
			frame_color = "#${color5}"

			[urgency_critical]
			timeout = 0
			background = "#${background}"
			foreground = "#${foreground}"
			frame_color = "#${color5}"
		_EOF_
	else
		cat ${PATH_CLS}/dunst_color.toml >>${PATH_NOTIFY}/dunstrc
	fi
}

apply_wm() {
	sed -i ${HYPRDIR}/hyprland.conf \
		-e "s@\$hypr_border[ ]*=.*@\$hypr_border = ${hypr_border}@g" \
		-e "s@\$hypr_gap_in[ ]*=.*@\$hypr_gap_in = ${hypr_gap_in}@g" \
		-e "s@\$hypr_gap_out[ ]*=.*@\$hypr_gap_out = ${hypr_gap_out}@g" \
		-e "s@\$hypr_radius[ ]*=.*@\$hypr_radius = ${hypr_radius}@g" \
		-e "s@\$hypr_shadow_enable[ ]*=.*@\$hypr_shadow_enable = ${hypr_shadow_enable}@g" \
		-e "s@\$hypr_shadow_range[ ]*=.*@\$hypr_shadow_range = ${hypr_shadow_range}@g" \
		-e "s@\$hypr_opacity[ ]*=.*@\$hypr_opacity = ${hypr_opacity}@g" \
		-e "s@\$hypr_inopacity[ ]*=.*@\$hypr_inopacity = ${hypr_inopacity}@g" \
		-e "s@\$hypr_blur_enable[ ]*=.*@\$hypr_blur_enable = ${hypr_blur_enable}@g" \
		-e "s@\$hypr_blur_size[ ]*=.*@\$hypr_blur_size = ${hypr_blur_size}@g" \
		-e "s@\$hypr_anim_enable[ ]*=.*@\$hypr_anim_enable = ${hypr_anim_enable}@g" \
		-e "s@\$hypr_anim_resize[ ]*=.*@\$hypr_anim_resize = ${hypr_anim_resize}@g" \
		-e "s@\$hypr_dis_random_logo[ ]*=.*@\$hypr_dis_random_logo = ${hypr_dis_random_logo}@g" \
		-e "s@\$hypr_dis_autoreload[ ]*=.*@\$hypr_dis_autoreload = ${hypr_dis_autoreload}@g" \
		-e "s@env=GDK_SCALE,.*@env=GDK_SCALE,${gtk_scale}@g" \
		-e "s@env=GDK_DPI_SCALE,.*@env=GDK_DPI_SCALE,${gtk_dpi_scale}@g" \
		-e "s@env=GTK_THEME,.*@env=GTK_THEME,${gtk_theme}@g" \
		-e "s@env=XCURSOR_THEME,.*@env=XCURSOR_THEME,${gtk_cursor_theme}@g" \
		-e "s@env=XCURSOR_SIZE,.*@env=XCURSOR_SIZE,${cursor_size}@g" \
		-e "s@env=QT_WAYLAND_FORCE_DPI,.*@env=QT_WAYLAND_FORCE_DPI,${qt_wayland_dpi}@g"

	if [[ "${auto_color}" != "true" ]]; then
		cat >${HYPRDIR}/hypr_color.conf <<-_EOF_
			\$background = ${background}
			\$foreground = ${foreground}

			\$color0     = ${color0}
			\$color1     = ${color1}
			\$color2     = ${color2}
			\$color3     = ${color3}
			\$color4     = ${color4}
			\$color5     = ${color5}
			\$color6     = ${color6}
			\$color7     = ${color7}
			\$color8     = ${color8}
			\$color9     = ${color9}
			\$color10    = ${color10}
			\$color11    = ${color11}
			\$color12    = ${color12}
			\$color13    = ${color13}
			\$color14    = ${color14}
			\$color15    = ${color15}
		_EOF_
	else
		cp ${PATH_CLS}/hypr_color.conf ${HYPRDIR}/hypr_color.conf
	fi
	hyprctl reload
}

patch_bar() {
	sed -i ${PATH_BAR}/modules.json \
		-e "s|\"device\"[ ]*:[ ]*\".*\"|\"device\": \"${BAR_BK_DEVICE}\"|g" \
		-e "s|\"bat\"[ ]*:[ ]*\".*\"|\"bat\": \"${BAR_BAT}\"|g" \
		-e "s|\"adapter\"[ ]*:[ ]*\".*\"|\"adapter\": \"${BAR_ADAPTER}\"|g"
}

notify_user() {
	dunstify -u normal -h string:x-dunst-stack-tag:applytheme "$1"
}

confirm_cmd() {
	rofi -dmenu \
		-p 'Change your theme' \
		-mesg 'Are you Sure?' \
		-markup-rows \
		-theme ${PATH_MENU}/confirm.rasi
}

confirm_run() {
	yes=' Yes'
	no=' No'

	selected="$(echo -e "${yes}\n${no}" | confirm_cmd)"
	if [[ "${selected}" == "${yes}" ]]; then
		if [[ "${auto_color}" == "true" ]]; then
			wal_cmd
		fi
		notify_user "Theme Changed"
		apply_wallpaper
		apply_netmenu
		apply_bar
		patch_bar
		apply_menu
		apply_terminal
		apply_gtk
		apply_notifyd
		apply_wm
		cat ${HYPRDIR}/custom/theme.sh >${HYPRDIR}/.current
	else
		notify_user "Theme Not Changed"
	fi
}

####################
confirm_run
