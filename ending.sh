#!/usr/bin/zsh

xfconf-query -c xsettings -p /Gtk/ShellShowsMenubar -n -t bool -s true
xfconf-query -c xsettings -p /Gtk/ShellShowsAppmenu -n -t bool -s true
cd /etc/termonad
sudo nix-build
sudo rm /ending.sh
