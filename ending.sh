#!/usr/bin/zsh

cd /etc/termonad
sudo nix-build
sudo cp /etc/termonad/result/bin/termonad /usr/bin
sudo rm /ending.sh
