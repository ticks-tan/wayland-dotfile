#!/usr/bin/env bash

## Copyright (C) 2023 Ticks <ticks.cc@gmail.com>

HYPRDIR="${HOME}/.config/hypr"
THEME_DIR="${HYPRDIR}/custom"

if [[ ! -f "${THEME_DIR}/system.sh" ]]; then
	echo "${THEME_DIR}/system.sh not found"
	exit 1
fi
if [[ ! -f "${THEME_DIR}/theme.sh" ]]; then
	echo "${THEME_DIR}/theme.sh not found"
	exit 1
fi

source ${THEME_DIR}/system.sh
source ${THEME_DIR}/theme.sh

PATH_CONF="${HOME}/.config"
PATH_BAR="${HYPRDIR}/bar/waybar"
PATH_TERM="${HYPRDIR}/term/alacritty"
PATH_MENU="${HYPRDIR}/menu/rofi"
PATH_NOTIFY="${HYPRDIR}/notification/dunst"

apply_wallpaper() {
	sed -i -e "s@preload=.*@preload=${wallpaper_path}@g" ${HYPRDIR}/hyprpaper.conf
	sed -i -e "s@\(wallpaper=[^,]*\),.*@\1,${wallpaper_path}@g" ${HYPRDIR}/hyprpaper.conf
}

apply_bar() {
	cat >${PATH_BAR}/color.css <<-EOF

		        @define-color base   #${base};
		        @define-color mantle #${mantle};
		        @define-color crust  #${crust};

		        @define-color text     #${text};
		        @define-color subtext0 #${subtext0};
		        @define-color subtext1 #${subtext1};

		        @define-color surface0 #${surface0};
		        @define-color surface1 #${surface1};
		        @define-color surface2 #${surface2};

		        @define-color overlay0 #${overlay0};
		        @define-color overlay1 #${overlay1};
		        @define-color overlay2 #${overlay2};

		        @define-color blue      #${blue};
		        @define-color lavender  #${lavender};
		        @define-color sapphire  #${sapphire};
		        @define-color sky       #${sky};
		        @define-color teal      #${teal};
		        @define-color green     #${green};
		        @define-color yellow    #${yellow};
		        @define-color peach     #${peach};
		        @define-color maroon    #${maroon};
		        @define-color red       #${red};
		        @define-color mauve     #${mauve};
		        @define-color pink      #${pink};
		        @define-color flamingo  #${flamingo};
		        @define-color rosewater #${rosewater};
	EOF

}

apply_menu() {
	sed -i -e "s@font:.*@font: \"${menu_font}\";@g" ${PATH_MENU}/shared/fonts.rasi
	cat >${PATH_MENU}/shared/colors.rasi <<-EOF
		* {
		    background:     #${crust};
		    background-alt: #${mantle};
		    foreground:     #${text};
		    selected:       #${lavender};
		    active:         #${green};
		    urgent:         #${red};
		}
	EOF
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
	cat >${PATH_TERM}/colors.yml <<-_EOF_
		colors:
		    # Default colors
		    primary:
		        background: "#${base}" # base
		        foreground: "#${text}" # text
		        # Bright and dim foreground colors
		        dim_foreground: "#${text}" # text
		        bright_foreground: "#${text}" # text

		    # Cursor colors
		    cursor:
		        text: "#${base}" # base
		        cursor: "#${rosewater}" # rosewater
		    vi_mode_cursor:
		        text: "#${base}" # base
		        cursor: "#${lavender}" # lavender

		    # Search colors
		    search:
		        matches:
		            foreground: "#${base}" # base
		            background: "#${subtext0}" # subtext0
		        focused_match:
		            foreground: "#${base}" # base
		            background: "#${green}" # green
		        footer_bar:
		            foreground: "#${base}" # base
		            background: "#${subtext0}" # subtext0

		    # Keyboard regex hints
		    hints:
		        start:
		            foreground: "#${base}" # base
		            background: "#${yellow}" # yellow
		        end:
		            foreground: "#${base}" # base
		            background: "#${subtext0}" # subtext0

		    # Selection colors
		    selection:
		        text: "#${base}" # base
		        background: "#${rosewater}" # rosewater

		    # Normal colors
		    normal:
		        black: "#${surface1}" # surface1
		        red: "#${red}" # red
		        green: "#${green}" # green
		        yellow: "#${yellow}" # yellow
		        blue: "#${blue}" # blue
		        magenta: "#${pink}" # pink
		        cyan: "#${teal}" # teal
		        white: "#${subtext1}" # subtext1

		    # Bright colors
		    bright:
		        black: "#${surface2}" # surface2
		        red: "#${red}" # red
		        green: "#${green}" # green
		        yellow: "#${yellow}" # yellow
		        blue: "#${blue}" # blue
		        magenta: "#${pink}" # pink
		        cyan: "#${teal}" # teal
		        white: "#${subtext0}" # subtext0

		    # Dim colors
		    dim:
		        black: "#${surface1}" # surface1
		        red: "#${red}" # red
		        green: "#${green}" # green
		        yellow: "#${yellow}" # yellow
		        blue: "#${blue}" # blue
		        magenta: "#${pink}" # pink
		        cyan: "#${teal}" # teal
		        white: "#${subtext1}" # subtext1
	_EOF_
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
	cat >>${PATH_NOTIFY}/dunstrc <<-_EOF_
		[urgency_low]
		timeout = 2
		background = "#${base}"
		foreground = "#${text}"
		frame_color = "#${lavender}"

		[urgency_normal]
		timeout = 5
		background = "#${base}"
		foreground = "#${text}"
		frame_color = "#${lavender}"

		[urgency_critical]
		timeout = 0
		background = "#${base}"
		foreground = "#${text}"
		frame_color = "#${lavender}"
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
		-e "s@\$hypr_dis_autoreload[ ]*=.*@\$hypr_dis_autoreload = ${hypr_dis_autoreload}@g" \
		-e "s@env=GDK_SCALE,.*@env=GDK_SCALE,${gtk_scale}@g" \
		-e "s@env=GDK_DPI_SCALE,.*@env=GDK_DPI_SCALE,${gtk_dpi_scale}@g" \
		-e "s@env=GTK_THEME,.*@env=GTK_THEME,${gtk_theme}@g" \
		-e "s@env=XCURSOR_THEME,.*@env=XCURSOR_THEME,${gtk_cursor_theme}@g" \
		-e "s@env=XCURSOR_SIZE,.*@env=XCURSOR_SIZE,${cursor_size}@g"

	cat >${HYPRDIR}/hypr_color.conf <<-_EOF_

		\$rosewaterAlpha = ${rosewater}
		\$flamingoAlpha  = ${flamingo}
		\$pinkAlpha      = ${pink}
		\$mauveAlpha     = ${mauve}
		\$redAlpha       = ${red}
		\$maroonAlpha    = ${maroon}
		\$peachAlpha     = ${peach}
		\$yellowAlpha    = ${yellow}
		\$greenAlpha     = ${green}
		\$tealAlpha      = ${teal}
		\$skyAlpha       = ${sky}
		\$sapphireAlpha  = ${sapphire}
		\$blueAlpha      = ${blue}
		\$lavenderAlpha  = ${lavender}

		\$textAlpha      = ${text}
		\$subtext1Alpha  = ${subtext1}
		\$subtext0Alpha  = ${subtext0}

		\$overlay2Alpha  = ${overlay2}
		\$overlay1Alpha  = ${overlay1}
		\$overlay0Alpha  = ${overlay0}

		\$surface2Alpha  = ${surface2}
		\$surface1Alpha  = ${surface1}
		\$surface0Alpha  = ${surface0}

		\$baseAlpha      = ${base}
		\$mantleAlpha    = ${mantle}
		\$crustAlpha     = ${crust}

		\$rosewater = 0xff${rosewater}
		\$flamingo  = 0xff${flamingo}
		\$pink      = 0xff${pink}
		\$mauve     = 0xff${mauve}
		\$red       = 0xff${red}
		\$maroon    = 0xff${maroon}
		\$peach     = 0xff${peach}
		\$yellow    = 0xff${yellow}
		\$green     = 0xff${green}
		\$teal      = 0xff${teal}
		\$sky       = 0xff${sky}
		\$sapphire  = 0xff${sapphire}
		\$blue      = 0xff${blue}
		\$lavender  = 0xff${lavender}

		\$text      = 0xff${text}
		\$subtext1  = 0xff${subtext1}
		\$subtext0  = 0xff${subtext0}

		\$overlay2  = 0xff${overlay2}
		\$overlay1  = 0xff${overlay1}
		\$overlay0  = 0xff${overlay0}

		\$surface2  = 0xff${surface2}
		\$surface1  = 0xff${surface1}
		\$surface0  = 0xff${surface0}

		\$base      = 0xff${base}
		\$mantle    = 0xff${mantle}
		\$crust     = 0xff${crust}
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
		-mesg 'Are you Sure?' \
		-markup-rows \
		-theme ${PATH_MENU}/confirm.rasi
}

confirm_run() {
	yes=' Yes'
	no=' No'

	selected="$(echo -e "${yes}\n${no}" | confirm_cmd)"
	if [[ "${selected}" == "${yes}" ]]; then
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
