#!/usr/bin/zsh

hostname=#hostname
rootpw=#rootpw
model=#model
token=#token

gitrepo=https://raw.githubusercontent.com/Kirara17233/config/main

# 设置时区
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

# 链接neovim
ln -s /usr/bin/nvim /usr/bin/vi
ln -s /usr/bin/nvim /usr/bin/vim

# visudo
sed -i "s|# %wheel ALL=(ALL) ALL|%wheel ALL=(ALL) NOPASSWD:ALL|g" /etc/sudoers

# 配置
mkdir /etc/git
curl -o /etc/git/.gitconfig "https://raw.githubusercontent.com/Kirara17233/config/main/.gitconfig"
ln -s /etc/git/.gitconfig /etc/skel/.gitconfig
ln -s /etc/git/.gitconfig /root/.gitconfig

mkdir /etc/ssh/.ssh
mkdir /etc/skel/.ssh

if [ "$token" != "#token" ];then
    curl -o /etc/ssh/.ssh/id_rsa "https://raw.githubusercontent.com/Kirara17233/rsa/main/id_rsa?token=$token"
    ln -s /etc/ssh/.ssh/id_rsa /etc/skel/.ssh/id_rsa
fi

curl -o /etc/ssh/.ssh/authorized_keys "$gitrepo/.ssh/authorized_keys"
ln -s /etc/ssh/.ssh/authorized_keys /etc/skel/.ssh/authorized_keys

git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /etc/oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /etc/oh-my-zsh/custom/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /etc/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /etc/oh-my-zsh/custom/plugins/zsh-autosuggestions
curl -o /etc/oh-my-zsh/.p10k.zsh "$gitrepo/.p10k.zsh"
curl -o /etc/oh-my-zsh/.zshrc "$gitrepo/.zshrc"
ln -s /etc/oh-my-zsh/.zshrc /etc/skel/.zshrc
ln -s /etc/oh-my-zsh/.zshrc /root/.zshrc

if [ $model -eq 1 ];then
    mkdir /etc/xmonad
    curl -o /etc/xmonad/xmonad.hs "$gitrepo/xmonad.hs"
    mkdir /etc/skel/.xmonad
    ln -s /etc/xmonad/xmonad.hs /etc/skel/.xmonad/xmonad.hs
    curl -o /var/lib/alsa/asound.state "$gitrepo/asound.state"
fi

# 设置Locale
sed -i "s|#en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|g" /etc/locale.gen
sed -i "s|#zh_CN.UTF-8 UTF-8|zh_CN.UTF-8 UTF-8|g" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# 设置主机名
echo "$hostname" > /etc/hostname
echo "127.0.0.1	localhost
::1		localhost
127.0.1.1	$hostname.localdomain	$hostname" >> /etc/hosts

# 设置Root密码
echo "root:$rootpw" | chpasswd

# 引导
pacman -S --noconfirm intel-ucode grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

# 配置网络
systemctl enable dhcpcd sshd

# 链接
systemctl enable install

# 退出chroot
exit
