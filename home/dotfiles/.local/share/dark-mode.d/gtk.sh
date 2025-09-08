#!/usr/bin/env bash
# Switch GTK applications to dark theme

# Set GTK3 theme
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# Set icon theme (optional - adjust as needed)
# gsettings set org.gnome.desktop.interface icon-theme "Adwaita-dark"

# For GTK4 applications
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# Update GTK2 theme
mkdir -p ~/.config/gtk-2.0
echo 'gtk-theme-name="Adwaita-dark"' > ~/.config/gtk-2.0/gtkrc

# Notify running applications
dbus-send --session --type=signal /org/gnome/SettingsDaemon/Power org.gnome.SettingsDaemon.Power.ScreenChanged
