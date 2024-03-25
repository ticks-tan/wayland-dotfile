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

get_color_cmd() {
	echo "get color from image: ${wallpaper_path} -> ${THEME_DIR}/color.sh"
	if [[ "${color_scheme}" == "light" ]]; then
		${HYPRDIR}/scripts/md-color -f "${wallpaper_path}" -o "${THEME_DIR}/color.sh"
	else
		${HYPRDIR}/scripts/md-color -f "${wallpaper_path}" -o "${THEME_DIR}/color.sh" --dark
	fi
	sed -i -E "s|=#(.{6})|=\"\1\"|g" ${THEME_DIR}/color.sh
	source ${THEME_DIR}/color.sh
}

apply_wallpaper() {
	sed -i -e "s@preload=.*@preload=${wallpaper_path}@g" ${HYPRDIR}/hyprpaper.conf
	sed -i -e "s@\(wallpaper=[^,]*\),.*@\1,${wallpaper_path}@g" ${HYPRDIR}/hyprpaper.conf
}

apply_bar() {
	cat >${PATH_BAR}/color.css <<-EOF
@define-color background #${background};
@define-color onBackground #${onBackground};

@define-color primary #${primary};
@define-color secondary #${secondary};
@define-color tertiary #${tertiary};
@define-color error #${error};
@define-color primaryContainer #${primaryContainer};
@define-color secondaryContainer #${secondaryContainer};
@define-color tertiaryContainer #${tertiaryContainer};
@define-color errorContainer #${errorContainer};
@define-color surfaceDim #${surfaceDim};
@define-color surface #${surface};
@define-color surfaceBright #${surfaceBright};
@define-color surfaceContainer #${surfaceContainer};
@define-color outline #${outline};
@define-color shadow #${shadow};
@define-color inversePrimary #${inversePrimary};
@define-color inverseSurface #${inverseSurface};

@define-color onPrimary #${onPrimary};
@define-color onSecondary #${onSecondary};
@define-color onTertiary #${onTertiary};
@define-color onError #${onError};
@define-color onPrimaryContainer #${onPrimaryContainer};
@define-color onSecondaryContainer #${onSecondaryContainer};
@define-color onTertiaryContainer #${onTertiaryContainer};
@define-color onErrorContainer #${onErrorContainer};
@define-color onSurface #${onSurface};
@define-color scrim #${scrim};
	EOF
}

apply_menu() {
	sed -i -e "s@font:.*@font: \"${menu_font}\";@g" ${PATH_MENU}/shared/fonts.rasi
	cat >${PATH_MENU}/shared/colors.rasi <<-EOF
* {
	background:         #${background};
	surface:            #${surface};
	onSurface:          #${onSurface};
	onBackground:       #${onBackground};
	primaryContainer:   #${primaryContainer};
	onPrimaryContainer: #${onPrimaryContainer};
	primary:            #${primary};
	onPrimary:          #${onPrimary};
	error:              #${error};
	onError:            #${onError};
}
	EOF
}

apply_terminal() {
	sed -i ${PATH_TERM}/fonts.toml \
		-e "s@family=.*@family=\"${term_font}\"@g" \
		-e "s@size=.*@size=${term_font_size}@g"

	cat >${PATH_TERM}/colors.toml <<-_EOF_
# Default colors
[colors.primary]
background="#${background}"
foreground="#${onBackground}"
dim_foreground="#${onSurface}"
bright_foreground="#${onSurface}"

# Cursor colors
[colors.cursor]
text="#${background}"
cursor="#${onBackground}"

[colors.vi_mode_cursor]
text="#${background}"
cursor="#${onBackground}"

# Search colors
[colors.search]
matches.foreground="#${onSurface}"
matches.background="#${surfaceContainer}"
focused_match.foreground="#${surfaceContainer}"
focused_match.background="#${onSurface}"

[colors.footer_bar]
foreground="#${onBackground}"
background="#${background}"

# Selection colors
[colors.selection]
text="#${background}"
background="#${onBackground}"

# Normal colors
[colors.normal]
black="#11111b"
red="#d20f39"
green="#40a02b"
yellow="#df8e1d"
blue="#1e66f5"
magenta="#8839ef"
cyan="#9ca0b0"
white="#eff1f5"

# Bright colors
[colors.bright]
black="#11111b"
red="#d20f39"
green="#40a02b"
yellow="#df8e1d"
blue="#1e66f5"
magenta="#8839ef"
cyan="#9ca0b0"
white="#eff1f5"

# Dim colors
[colors.dim]
black="#11111b"
red="#d20f39"
green="#40a02b"
yellow="#df8e1d"
blue="#1e66f5"
magenta="#8839ef"
cyan="#9ca0b0"
white="#eff1f5"
	_EOF_
}

apply_gtk() {
	local XFILE="${HYPRDIR}/xsettingsd"
	local GTK2FILE="${HOME}/.gtkrc-2.0"
	local GTK3FILE="${PATH_CONF}/gtk-3.0/settings.ini"

	sed -i -e "s|Net/ThemeName .*|Net/ThemeName \"$gtk_theme\"|g" ${XFILE}
	sed -i -e "s|Net/IconThemeName .*|Net/IconThemeName \"$gtk_icon_theme\"|g" ${XFILE}
	sed -i -e "s|Gtk/CursorThemeName .*|Gtk/CursorThemeName \"$cursor_theme\"|g" ${XFILE}

	sed -i -e "s|gtk-font-name=.*|gtk-font-name=\"$gtk_font\"|g" ${GTK2FILE}
	sed -i -e "s|gtk-theme-name=.*|gtk-theme-name=\"$gtk_theme\"|g" ${GTK2FILE}
	sed -i -e "s|gtk-icon-theme-name=.*|gtk-icon-theme-name=\"$gtk_icon_theme\"|g" ${GTK2FILE}
	sed -i -e "s|gtk-cursor-theme-name=.*|gtk-cursor-theme-name=\"$cursor_theme\"|g" ${GTK2FILE}

	sed -i -e "s|gtk-font-name=.*|gtk-font-name=$gtk_font|g" ${GTK3FILE}
	sed -i -e "s|gtk-theme-name=.*|gtk-theme-name=$gtk_theme|g" ${GTK3FILE}
	sed -i -e "s|gtk-icon-theme-name=.*|gtk-icon-theme-name=$gtk_icon_theme|g" ${GTK3FILE}
	sed -i -e "s|gtk-cursor-theme-name=.*|gtk-cursor-theme-name=$cursor_theme|g" ${GTK3FILE}
}

apply_notifyd() {
	sed -i ${PATH_NOTIFY}/dunstrc \
		-e "s/width = .*/width = $notify_width/g" \
		-e "s/height = .*/height = $notify_height/g" \
		-e "s/font = .*/font = $notify_font/g" \
		-e "s/frame_width = .*/frame_width = $notify_border/g"

	sed -i '/urgency_low/Q' ${PATH_NOTIFY}/dunstrc
	cat >>${PATH_NOTIFY}/dunstrc <<-_EOF_
		[urgency_low]
		timeout = 2
		background = "#${background}"
		foreground = "#${onBackground}"
		frame_color = "#${surfaceContainer}"

		[urgency_normal]
		timeout = 5
		background = "#${background}"
		foreground = "#${onBackground}"
		frame_color = "#${surfaceContainer}"

		[urgency_critical]
		timeout = 0
		background = "#${error}"
		foreground = "#${onError}"
		frame_color = "#${surfaceContainer}"
	_EOF_
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
		-e "s@\$hypr_dis_autoreload[ ]*=.*@\$hypr_dis_autoreload = ${hypr_dis_autoreload}@g"

	sed -i ${HYPRDIR}/hyprland/env.conf \
		-e "s@env=GDK_SCALE,.*@env=GDK_SCALE,${gtk_scale}@g" \
		-e "s@env=GDK_DPI_SCALE,.*@env=GDK_DPI_SCALE,${gtk_dpi_scale}@g" \
		-e "s@env=GTK_THEME,.*@env=GTK_THEME,${gtk_theme}@g" \
		-e "s@env=XCURSOR_THEME,.*@env=XCURSOR_THEME,${cursor_theme}@g" \
		-e "s@env=XCURSOR_SIZE,.*@env=XCURSOR_SIZE,${cursor_size}@g" \
		-e "s@env=QT_WAYLAND_FORCE_DPI,.*@env=QT_WAYLAND_FORCE_DPI,${qt_wayland_dpi}@g" \
		-e "s@env=HYPRCURSOR_SIZE,.*@env=HYPRCURSOR_SIZE,${cursor_size}@g" \
		-e "s@env=HYPRCURSOR_THEME,.*@env=HYPRCURSOR_THEME,${cursor_theme}@g"

	cat >${HYPRDIR}/hyprland/color.conf <<-_EOF_
# ___________________________________________________________________________________________________ #
#     _     _ #
#     /    /                            /                      /                      / #
# ---/___ /---------------__----)__----/-----__-----__-----__-/---------__-----__----/-----__----)__- #
#   /    /     /   /    /   )  /   )  /    /   )  /   )  /   /        /   '  /   )  /    /   )  /   ) #
# _/____/_____(___/____/___/__/______/____(___(__/___/__(___/________(___ __(___/__/____(___/__/_____ #
#                /    / #
#            (_ /    / #


\$background=${background}
\$onBackground=${onBackground}

\$primary=${primary}
\$secondary=${secondary}
\$tertiary=${tertiary}
\$error=${error}
\$primaryContainer=${primaryContainer}
\$secondaryContainer=${secondaryContainer}
\$tertiaryContainer=${tertiaryContainer}
\$errorContainer=${errorContainer}
\$surfaceDim=${surfaceDim}
\$surface=${surface}
\$surfaceBright=${surfaceBright}
\$surfaceContainer=${surfaceContainer}
\$outline=${outline}
\$shadow=${shadow}
\$inversePrimary=${inversePrimary}
\$inverseSurface=${inverseSurface}

\$onPrimary=${onPrimary}
\$onSecondary=${onSecondary}
\$onTertiary=${onTertiary}
\$onError=${onError}
\$onPrimaryContainer=${onPrimaryContainer}
\$onSecondaryContainer=${onSecondaryContainer}
\$onTertiaryContainer=${onTertiaryContainer}
\$onErrorContainer=${onErrorContainer}
\$onSurface=${onSurface}
\$scrim=${scrim}
	_EOF_
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
		-mesg 'Are you Sure to change your theme ?' \
		-markup-rows \
		-theme ${PATH_MENU}/confirm.rasi
}

confirm_run() {
	yes='󰗡 Yes'
	no='󰅙 No'

	selected="$(echo -e "${yes}\n${no}" | confirm_cmd)"
	if [[ "${selected}" == "${yes}" ]]; then
		if [[ "${auto_color}" == "true" ]]; then
			get_color_cmd
		fi
		apply_wallpaper
		apply_bar
		patch_bar
		apply_menu
		apply_terminal
		apply_gtk
		apply_notifyd
		cat ${HYPRDIR}/custom/theme.sh >${HYPRDIR}/.current
		apply_wm
		notify_user "Theme Changed"
	else
		notify_user "Theme Not Changed"
	fi
}


confirm_run
