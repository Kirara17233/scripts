#!/usr/bin/zsh

hostname=$1
swapsize=$2
rootpw=$3
user=$4
userpw=$5
model=$6

run() {
  echo $1 | zsh
  if [ $? -ne 0 ]; then
    run $1
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
run "git clone https://github.com/Kirara17233/config /etc/config"
run "git --git-dir=/etc/config/.git --work-tree=/etc/config remote set-url origin git@github.com:Kirara17233/config"
run "ln -sf /etc/config/.gitconfig /etc/skel/.gitconfig"
run "ln -sf /etc/config/.gitconfig /root/.gitconfig"

# SSH configuration
run "mkdir /etc/skel/.ssh"
run "mkdir /root/.ssh"
run "ln -sf /etc/config/.ssh/authorized_keys /etc/skel/.ssh/authorized_keys"
run "touch /etc/ssh/id_rsa"
run "ln -sf /etc/ssh/id_rsa /etc/skel/.ssh/id_rsa"
run "ln -sf /etc/ssh/id_rsa /root/.ssh/id_rsa"

# Zsh configuration
run "git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /etc/oh-my-zsh"
run "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /etc/oh-my-zsh/custom/themes/powerlevel10k"
run "git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /etc/oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
run "git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /etc/oh-my-zsh/custom/plugins/zsh-autosuggestions"
run "ln -sf /etc/config/.zshrc /etc/skel/.zshrc"
run "ln -sf /etc/config/.zshrc /root/.zshrc"

# Xmonad and sound system configuration
if [ $model -eq 1 ];then
  run "rm -rf /usr/local/bin"
  run "ln -sf /etc/config/bin /usr/local"
  run "mkdir /etc/skel/.xmonad"
  run "mkdir /etc/skel/.xmobar"
  run "ln -sf /etc/config/.xmonad/xmonad.hs /etc/skel/.xmonad/xmonad.hs"
  run "ln -sf /etc/config/.xmobar/xmobar.hs /etc/skel/.xmobar/xmobar.hs"
  run "mkdir /etc/skel/.config"
  run "mkdir /etc/skel/.config/rofi"
  run "ln -sf /etc/config/.config/rofi/config.rasi /etc/skel/.config/rofi/config.rasi"
  run "mkdir /var/lib/alsa"
  run "ln -sf /etc/config/asound.state /var/lib/alsa/asound.state"
  run "mkdir /etc/skel/.config/gtk-3.0"
  run "mkdir /etc/skel/.config/xfce4"
  run "mkdir /etc/skel/.config/xfce4/xfconf"
  run "mkdir /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml"
  run "mkdir /etc/skel/.config/termonad"
  run "ln -sf /etc/config/.config/gtk-3.0/settings.ini /etc/skel/.config/gtk-3.0/settings.ini"
  run "ln -sf /etc/config/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
  run "ln -sf /etc/config/.config/termonad/termonad.hs /etc/skel/.config/termonad/termonad.hs"
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

# Neovim configuration
run "mkdir /etc/xdg/nvim/autoload"
run "curl -fLo /etc/xdg/nvim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
run "ln -sf /etc/config/archlinux.vim /usr/share/nvim/archlinux.vim"
run "ln -sf /etc/config/picom.conf /etc/xdg/picom.conf"

# Enable dhcpcd and ssh
run "systemctl enable dhcpcd sshd"

# Add a new user
run "useradd -m -G wheel $user"
run "echo \"$user:$userpw\" | chpasswd"

# Install yay
run "su $user << EOF
git clone --depth=1 https://aur.archlinux.org/yay.git /home/$user/yay
(cd /home/$user/yay && makepkg -rsi --noconfirm)
rm -rf /home/$user/yay
EOF
"

# Install GUI packages
if [ $model -eq 1 ];then
  run "groupadd autologin"
  run "gpasswd -a $user autologin"
  run "su $user << EOF
  yay -S --noconfirm xf86-video-vmware open-vm-tools alsa-utils numlockx gobject-introspection nix\
      xorg-server xorg-xsetroot xwallpaper wmctrl xorg-xrandr gtk3 lightdm xmonad xmonad-contrib picom xmobar xfce4-panel vala-panel-appmenu-registrar vala-panel-appmenu-xfce rofi\
      xxd-standalone ttf-meslo-nerd-font-powerlevel10k ttf-jetbrains-mono noto-fonts-sc jdk-openjdk jetbrains-toolbox visual-studio-code-bin google-chrome bash-pipes cmatrix
EOF
"
  run "git clone --depth=1 https://github.com/cdepillabout/termonad /etc/termonad"

  run "systemctl enable lightdm vmtoolsd vmware-vmblock-fuse"

  # Open autologin
  run "sed -i \"s|#autologin-user=|autologin-user=$user|g\" /etc/lightdm/lightdm.conf"
  run "sed -i \"s|#autologin-session=|autologin-session=xmonad|g\" /etc/lightdm/lightdm.conf"
fi

# Cleanup script
run "rm /chroot.sh"
