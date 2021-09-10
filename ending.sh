#!/usr/bin/zsh

sudo nix-build /etc/termonad
sudo cp /etc/termonad/result/bin/termonad /usr/bin
sudo rm /ending.sh
