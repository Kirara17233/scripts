#!/usr/bin/zsh

run() {
  echo "$1 2>> /err.info" | zsh
  if [ "$?" -ne 0 ]; then
    run $1 /err.info
  fi
}

run "cd /etc/termonad"
run "sudo nix-build"
run "xfconf-query -c xsettings -p /Gtk/ShellShowsMenubar -n -t bool -s true"
run "xfconf-query -c xsettings -p /Gtk/ShellShowsAppmenu -n -t bool -s true"
