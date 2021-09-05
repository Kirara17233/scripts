#!/usr/bin/zsh

hostname=$1
swapsize=$2
rootpw=$3
user=$4
userpw=$5
model=$6

run() {
  errpath=/err.info
  if [ $2 ]; then
    errpath=$2
  fi
  echo "$1 2>> $errpath" | zsh
  echo $1 >> /cmd
  if [ "$?" -ne 0 ]; then
    run $1 $errpath
  fi
}

# Set the time zone
run "ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime"
run "hwclock --systohc"

# Open pacman's color option
run "sed -i \"s|#Color|Color|g\" /etc/pacman.conf"

# Link vi and vim to neovim
run "ln -sf /usr/bin/nvim /usr/bin/vi"
run "ln -sf /usr/bin/nvim /usr/bin/vim"

# Change sudo
run "sed -i \"s|# %wheel ALL=(ALL) ALL|%wheel ALL=(ALL) NOPASSWD:ALL|g\" /etc/sudoers"

# Git configuration
run "git clone https://github.com/Kirara17233/config /root/config"
run "cp -r /root/config/git /etc"
run "ln -sf /etc/git/.gitconfig /etc/skel/.gitconfig"
run "ln -sf /etc/git/.gitconfig /root/.gitconfig"

# SSH configuration
run "cp -r /root/config/.ssh /etc/ssh"
run "mkdir /etc/skel/.ssh"
run "ln -sf /etc/ssh/.ssh/authorized_keys /etc/skel/.ssh/authorized_keys"
run "ln -sf /etc/ssh/.ssh/id_rsa /etc/skel/.ssh/id_rsa"

# Zsh configuration
run "git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /etc/oh-my-zsh"
run "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /etc/oh-my-zsh/custom/themes/powerlevel10k"
run "git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /etc/oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
run "git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /etc/oh-my-zsh/custom/plugins/zsh-autosuggestions"
run "cp /root/config/.p10k.zsh /etc/oh-my-zsh"
run "cp /root/config/.zshrc /etc/oh-my-zsh"
run "ln -sf /etc/oh-my-zsh/.zshrc /etc/skel/.zshrc"
run "ln -sf /etc/oh-my-zsh/.zshrc /root/.zshrc"

run "# Xmonad and sound system configuration"
if [ $model -eq 1 ];then
  run "cp -r /root/config/xmonad /etc"
  run "mkdir /etc/skel/.xmonad"
  run "ln -sf /etc/xmonad/xmonad.hs /etc/skel/.xmonad/xmonad.hs"
  run "cp -r /root/config/colors /etc"
  run "ln -sf /etc/colors/MaterialOcean /etc/colors/main"
  run "cp -r /root/config/.config/rofi /etc"
  run "mkdir /etc/skel/.config"
  run "mkdir /etc/skel/.config/rofi"
  run "ln -sf /etc/rofi/config.rasi /etc/skel/.config/rofi/config.rasi"
  run "cp -r /root/config/alsa /var/lib"
fi

# Localization
run "sed -i \"s|#en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|g\" /etc/locale.gen"
run "sed -i \"s|#zh_CN.UTF-8 UTF-8|zh_CN.UTF-8 UTF-8|g\" /etc/locale.gen"
run "locale-gen"
run "echo LANG=en_US.UTF-8 > /etc/locale.conf"

# Network configuration
run "echo $hostname > /etc/hostname"
run "echo \"127.0.0.1	localhost
::1		localhost
127.0.1.1	$hostname.localdomain	$hostname\" >> /etc/hosts"

# Reset root password
run "echo root:$rootpw | chpasswd"

# Boot loader
run "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub"
run "grub-mkconfig -o /boot/grub/grub.cfg"

# Create a swapfile
run "dd if=/dev/zero of=/swapfile bs=1M count=$swapsize status=progress"
run "chmod 600 /swapfile"
run "mkswap /swapfile"
run "swapon /swapfile"
run "sed -i \"7i /swapfile					none		swap		defaults	0 0\" /etc/fstab"

# Install GUI packages
if [ $model -eq 1 ];then
  run "pacman -S --noconfirm xf86-video-vmware xorg-server xorg-xsetroot gtk3 nix"

  # 安装termonad
  run "git clone --depth=1 https://github.com/cdepillabout/termonad /etc/termonad"
  run "cd /etc/termonad"
  run "nix-build"
  run "cp /etc/termonad/result/bin/termonad /usr/bin/termonad"
  run "cp /root/config/.config/termonad/termonad.hs /etc/termonad"
  run "mkdir /etc/skel/.config/termonad"
  run "ln -sf /etc/termonad/termonad.hs /etc/skel/.config/termonad/termonad.hs"

  run "cp /root/config/.config/gtk-3.0/settings.ini /etc/gtk-3.0"
  run "mkdir /etc/skel/.config/gtk-3.0"
  run "ln -sf /etc/gtk-3.0/settings.ini /etc/skel/.config/gtk-3.0/settings.ini"
fi

# Neovim configuration
run "mkdir /etc/xdg/nvim/autoload"
run "curl -fLo /etc/xdg/nvim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
run "cp /root/config/archlinux.vim /usr/share/nvim"

# Enable dhcpcd and ssh
run "systemctl enable dhcpcd sshd"

# Add a new user
run "useradd -m -G wheel $user"
run "echo \"$user:$userpw\" | chpasswd"

# Install yay
run "su $user << EOF
git clone --depth=1 https://aur.archlinux.org/yay.git /home/$user/yay
cd /home/$user/yay
makepkg -rsi --noconfirm
cd ~
rm -rf /home/$user/yay
EOF
" /home/$user/err.info

# Install GUI packages
if [ $model -eq 1 ];then
  run "groupadd autologin"
  run "gpasswd -a $user autologin"
  su $user <<EOF
  yay -S --noconfirm xwallpaper xxd-standalone gobject-introspection vala-panel-appmenu-xfce picom alsa-utils lightdm numlockx xmonad xmonad-contrib xfce4-panel xmobar rofi ttf-meslo-nerd-font-powerlevel10k ttf-jetbrains-mono noto-fonts-sc open-vm-tools jdk-openjdk jetbrains-toolbox visual-studio-code-bin google-chrome
EOF

  run "xfconf-query -c xsettings -p /Gtk/ShellShowsMenubar -n -t bool -s true"
  run "xfconf-query -c xsettings -p /Gtk/ShellShowsAppmenu -n -t bool -s true"

  run "systemctl enable lightdm vmtoolsd vmware-vmblock-fuse"

  # Open autologin
  run "sed -i \"s|#autologin-user=|autologin-user=$user|g\" /etc/lightdm/lightdm.conf"
  run "sed -i \"s|#autologin-session=|autologin-session=xmonad|g\" /etc/lightdm/lightdm.conf"
fi

# 清理文件
run "rm /chroot.sh"

# 退出chroot
exit
