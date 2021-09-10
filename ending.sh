#!/usr/bin/zsh

sudo git --git-dir=/etc/termonad/.git --work-tree=/etc/termonad pull
sudo nix-build /etc/termonad
sudo cp /etc/termonad/result/bin/termonad /usr/bin
