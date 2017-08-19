#!/bin/sh
echo ">> XSET settings"
xset -dpms s off s noblank s 0 0 s noexpose
echo ">> GCONF load custom settings"

gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ use-custom-command true
gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ custom-command "/bin/bash -c 'cd; exec /bin/bash'"

gsettings set org.mate.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.mate.screensaver idle-activation-enabled false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
