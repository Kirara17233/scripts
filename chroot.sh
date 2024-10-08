#!/usr/bin/zsh

hostname=$1
swapsize=$2
rootpw=$3
user=$4
userpw=$5
model=$6

# Git configuration
git clone https://github.com/Kirara17233/configs /configs
git --git-dir=/configs/.git --work-tree=/configs remote set-url origin git@github.com:Kirara17233/configs
cp -af /configs/cli/* /

# Set the time zone
cp /usr/share/zoneinfo/PRC /etc/localtime
hwclock --systohc

# Open pacman and makepkg's option
sed -i "s|#Color|Color|g" /etc/pacman.conf
sed -i "s|#ParallelDownloads|ParallelDownloads|g" /etc/pacman.conf
sed -i "s|-march=x86-64 -mtune=generic|-march=native|g" /etc/makepkg.conf
sed -i "s|-Cforce-frame-pointers=yes|-Cforce-frame-pointers=yes -C target-cpu=native|g" /etc/makepkg.conf
sed -i "s|#MAKEFLAGS=\"-j|MAKEFLAGS=\"-j1|g" /etc/makepkg.conf

# Change sudo
sed -i "s|# %wheel ALL=(ALL:ALL) NOPASSWD: ALL|%wheel ALL=(ALL:ALL) NOPASSWD: ALL|g" /etc/sudoers

# Zsh configuration
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /etc/oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /etc/oh-my-zsh/custom/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /etc/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /etc/oh-my-zsh/custom/plugins/zsh-autosuggestions

# Localization
sed -i "s|#en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|g" /etc/locale.gen
sed -i "s|#zh_CN.UTF-8 UTF-8|zh_CN.UTF-8 UTF-8|g" /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# Network configuration
echo $hostname > /etc/hostname
echo "127.0.0.1	localhost
::1		localhost
127.0.1.1	$hostname.localdomain	$hostname" >> /etc/hosts

# Reset root password
echo root:$rootpw | chpasswd

# Boot loader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

# Create a swapfile
dd if=/dev/zero of=/swapfile bs=1G count=$swapsize status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
sed -i "7i /swapfile					none		swap		defaults	0 0" /etc/fstab
sed -i "8i /dev/sdb1			/home/$user/Desktop		ext4		defaults	0 0" /etc/fstab

# Neovim configuration
mkdir /etc/xdg/nvim/autoload
curl -fLo /etc/xdg/nvim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Enable dhcpcd and ssh
systemctl enable dhcpcd sshd

# Xmonad and sound system configuration
if [ $model -eq 1 ];then
  cp -af /configs/gui/* /
fi

# Add a new user
useradd -m -G wheel $user
echo "$user:$userpw" | chpasswd

# Install yay
su $user << EOF
git clone --depth=1 https://aur.archlinux.org/yay.git /home/$user/yay
(cd /home/$user/yay && makepkg -rsi --noconfirm)
rm -rf /home/$user/yay
EOF

# Install GUI packages
if [ $model -eq 1 ];then
  groupadd autologin
  gpasswd -a $user autologin
  su $user << EOF
  yay -S --noconfirm budgie-desktop
  yay -Rsn --noconfirm budgie-desktop
  yay -S --noconfirm xf86-video-vmware open-vm-tools alsa-utils numlockx gobject-introspection nix\
      xorg-server xorg-xsetroot xwallpaper wmctrl xorg-xrandr gtk3 appmenu-gtk-module lightdm xmonad xmonad-contrib picom xmobar xfce4-panel vala-panel-appmenu-xfce vala-panel-appmenu-registrar rofi\
      bpytop gnome-keyring ttf-meslo-nerd-font-powerlevel10k ttf-jetbrains-mono ttf-font-awesome ttf-nerd-fonts-symbols noto-fonts noto-fonts-sc noto-fonts-emoji jdk-openjdk jetbrains-toolbox visual-studio-code-bin google-chrome
  mkdir ~/Desktop
EOF
  chown -R $user /opt/visual-studio-code
  git clone --depth=1 https://github.com/cdepillabout/termonad /etc/termonad

  systemctl enable lightdm vmtoolsd vmware-vmblock-fuse

  # Open autologin
  sed -i "s|#autologin-user=|autologin-user=$user|g" /etc/lightdm/lightdm.conf
  sed -i "s|#autologin-session=|autologin-session=xmonad|g" /etc/lightdm/lightdm.conf
fi

# Cleanup script
rm /chroot.sh
