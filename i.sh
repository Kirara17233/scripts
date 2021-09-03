#!/usr/bin/zsh

# Update the system clock
timedatectl set-ntp true

# Partition the disks
sed -e "s| *#.*||g" << EOF | fdisk /dev/sda
g     # create a new empty GPT(GUID) partition table
n     # add a new partition as EFI system
      # default partition number: 1
      # default starting sector
+512M # +512M as ending sector
t     # change the partition type
1     # EFI System
n     # add a new partition
      # default partition number: 2
      # default starting sector
      # ending sector(all the remaining space)
w     # write table to disk and exit
EOF

# Format the partitions
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount the file systems
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Install basic packages
pacstrap /mnt base base-devel linux linux-firmware dhcpcd openssh neovim sudo zsh git wget neofetch

# Change the default shell to zsh
rm /mnt/etc/skel/.bash*
sed -i "s|/bin/bash|/usr/bin/zsh|g" /mnt/etc/default/useradd /mnt/etc/passwd

# Configure the system
genfstab -U /mnt >> /mnt/etc/fstab

# Open pacman's color option
sed -i "s|#Color|Color|g" /mnt/etc/pacman.conf

# Get 
curl -o /mnt/step$loop.sh "https://raw.githubusercontent.com/Kirara17233/script/main/chroot.sh"
chmod +x /mnt/chroot.sh

# Chroot
arch-chroot /mnt /step1.sh $1 $2 $3 $4 $5 $6

# 重启
umount /mnt/boot
umount /mnt
reboot
