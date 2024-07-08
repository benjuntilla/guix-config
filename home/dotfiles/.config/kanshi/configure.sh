#!/bin/sh
# Variables
swaymsg set \$left_wallpaper /home/ben/.config/sway/1.jpg
swaymsg set \$right_wallpaper /home/ben/.config/sway/2.jpg
swaymsg set \$left_monitor $1
swaymsg set \$right_monitor $2

# Wallpapers
swaymsg output \$left_monitor background \$left_wallpaper fill
swaymsg output \$right_monitor background \$right_wallpaper fill
swaymsg output eDP-1 background \$right_wallpaper fill

# Focus
swaymsg focus output \$left_monitor

# Set workspaces
swaymsg workspace 1 output \$left_monitor
swaymsg workspace 3 output \$left_monitor
swaymsg workspace 5 output \$left_monitor
swaymsg workspace 7 output \$left_monitor
swaymsg workspace 9 output \$left_monitor
swaymsg workspace 2 output \$right_monitor
swaymsg workspace 4 output \$right_monitor
swaymsg workspace 6 output \$right_monitor
swaymsg workspace 8 output \$right_monitor
swaymsg workspace 0 output \$right_monitor

