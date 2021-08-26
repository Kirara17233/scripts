#!/usr/bin/zsh

# 更新系统时间
timedatectl set-ntp true

# 分区与格式化

echo "g
n


+512M
t
1
n



w" | fdisk /dev/sda

# 格式化分区
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# 挂载分区
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# 安装基本包
pacstrap /mnt base base-devel linux linux-firmware dhcpcd openssh neovim sudo zsh git

# 配置shell
rm /mnt/etc/skel/.bash*
sed -i "s|/bin/bash|/usr/bin/zsh|g" /mnt/etc/default/useradd
sed -i "s|/bin/bash|/usr/bin/zsh|g" /mnt/etc/passwd

# 配置Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# 下载后续脚本
for loop in 1 2
do
    curl -o /mnt/step$loop.sh "https://raw.githubusercontent.com/Kirara17233/script/main/step$loop.sh"
done
curl -o /mnt/usr/lib/systemd/system/install.service "https://raw.githubusercontent.com/Kirara17233/script/main/install.service"
chmod +x /mnt/step*.sh

# 参数
sed -i "s|#hostname|$1|g" /mnt/step*.sh
sed -i "s|#swapsize|$2|g" /mnt/step*.sh
sed -i "s|#rootpw|$3|g" /mnt/step*.sh
sed -i "s|#user|$4|g" /mnt/step*.sh
sed -i "s|#userpw|$5|g" /mnt/step*.sh
sed -i "s|#model|$6|g" /mnt/step*.sh

if [ $5 ];then
    sed -i "s|#token|$7|g" /mnt/step*.sh
fi

# 开启pacman色彩选项
sed -i "s|#Color|Color|g" /mnt/etc/pacman.conf

# Chroot
arch-chroot /mnt /step1.sh

# 重启
umount /mnt/boot
umount /mnt
reboot
