#!/usr/bin/zsh

swapsize=#swapsize
user=#user
userpw=#userpw
model=#model

# 创建交换文件
dd if=/dev/zero of=/swapfile bs=1M count=$swapsize status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
sed -i "7i /swapfile                                       none            swap            defaults        0 0" /etc/fstab

# 新建用户
useradd -m -G wheel $user
echo "$user:$userpw" | chpasswd

if [ $model -eq 1 ];then
    groupadd autologin
    gpasswd -a $user autologin
fi

# 安装yay
su $user <<EOF
git clone --depth=1 https://aur.archlinux.org/yay.git /home/$user/yay
cd /home/$user/yay
makepkg -rsi --noconfirm
cd ..
rm -rf /home/$user/yay
EOF

# 下载vim-plug
mkdir /etc/xdg/nvim/autoload
curl -fLo /etc/xdg/nvim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "
call plug#begin('/etc/xdg/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jiangmiao/auto-pairs'
call plug#end()

nmap <silent> q :q! <cr>

let g:airline_powerline_fonts = 1
\"let g:airline_theme='deus'
let g:airline_theme='bubblegum'
\"let g:airline_theme='minimalist'
set nu" >> /usr/share/nvim/archlinux.vim

# 安装软件
if [ $model -eq 1 ];then
    su $user <<EOF
    yay -S --noconfirm xf86-video-vmware xorg-server xorg-xsetroot breeze-gtk xwallpaper gtk3 picom alsa-utils lightdm numlockx xmonad xmonad-contrib xmobar rofi ttf-meslo-nerd-font-powerlevel10k alacritty ttf-jetbrains-mono noto-fonts-sc open-vm-tools jdk-openjdk jetbrains-toolbox visual-studio-code-bin google-chrome
EOF

    systemctl enable lightdm vmtoolsd vmware-vmblock-fuse

    # 启用自动登录
    sed -i "s|#autologin-user=|autologin-user=$user|g" /etc/lightdm/lightdm.conf
    sed -i "s|#autologin-session=|autologin-session=xmonad|g" /etc/lightdm/lightdm.conf
fi

# 解除
systemctl disable install

# 清理文件
rm /usr/lib/systemd/system/install.service
rm /step*.sh

# 重启
reboot
