#!/usr/bin/env bash

## Copyright (C) 2023 Ticks <ticks.cc@gmail.com>
##
## Theme Config
## 不要修改变量名称，仅修改变量值即可！！！
##

#########################
## Color
#########################
## 颜色配置，参考 https://github.com/catppuccin/catppuccin

base="24273a"
mantle="1e2030"
crust="181926"

text="cad3f5"
subtext0="a5adcb"
subtext1="b8c0e0"

surface0="363a4f"
surface1="494d64"
surface2="5b6078"

overlay0="6e738d"
overlay1="8087a2"
overlay2="939ab7"

blue="8aadf4"
lavender="b7bdf8"
sapphire="7dc4e4"
sky="91d7e3"
teal="8bd5ca"
green="a6da95"
yellow="eed49f"
peach="f5a97f"
maroon="ee99a0"
red="ed8796"
mauve="c6a0f6"
pink="f5bde6"
flamingo="f0c6c6"
rosewater="f4dbd6"

#########################
## Wallpaper
#########################
wallpaper_path="~/.local/share/wallpapers/wallhaven-7plk13.png"

#########################
## Menu
#########################
menu_font="JetBrains Nerd Font 14"

#########################
## Notification
#########################
notify_width="300"
notify_height="80"
notify_font="Sarasa UI SC 12"
notify_border="2"

########################
## GTK
#######################
## 应用主题
gtk_theme="Catppuccin-Macchiato"
## 应用字体大小
gtk_font="Sarasa UI SC 12"
## 图标主题
gtk_icon_theme="Win11"
## 光标主题
gtk_cursor_theme="Catppuccin-Macchiato-Light"
## Gtk 缩放(整数)
gtk_scale=1
## Gtk dpi 缩放(支持分数)
gtk_dpi_scale=1.25
## 鼠标大小
cursor_size=24

########################
## Terminal
########################
## 终端字体
term_font="Hack Nerd Font"
## 终端字体大小
term_font_size="14"

########################
## Hyprland
########################

## 多久锁屏 (秒)
hypr_lock_timeout=600

## 边框宽度
hypr_border=2
## 内边缘间隔
hypr_gap_in=6
## 外边缘间隔
hypr_gap_out=16
## 窗口圆角
hypr_radius=8
## 是否启用阴影 ("true" / "false")，没什么效果，推荐关闭
hypr_shadow_enable="false"
## 阴影半径
hypr_shadow_range=4
## 活动窗口透明度
hypr_opacity=1.0
## 不活动窗口透明度
hypr_inopacity=1.0
## 是否启用模糊
hypr_blur_enable="true"
## 模糊大小
hypr_blur_size=7
## 是否启用动画
hypr_anim_enable="true"
## 是否在移动或者改变大小时启用动画
hypr_anim_resize="false"
## 是否取消显示随机logo壁纸，false则自定义壁纸失效,使用随机壁纸
hypr_dis_random_logo="true"
## 是否关闭配置文件更改后自动重新加载，false为自动加载
hypr_dis_autoreload="true"
