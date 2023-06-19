#!/usr/bin/zsh

hostname=$1
swapsize=$2
rootpw=$3
user=$4
userpw=$5
model=$6

sed -i "s|#ParallelDownloads|ParallelDownloads|g" /etc/pacman.conf

# Partition the disks
sed -e "s| *#.*||g" << EOF | fdisk /dev/sda
g     # create a new empty GPT(GUID) partition table
n     # add a new partition as EFI system
      # default partition number: 1
      # default starting sector
+128M # +128M as ending sector
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
mount --mkdir /dev/sda1 /mnt/boot

# Install basic packages
pacstrap -K /mnt base base-devel linux linux-firmware dhcpcd stow openssh gdb neovim emacs sudo zsh git neofetch intel-ucode grub efibootmgr docker

# Change the default shell to zsh
rm /mnt/etc/skel/.bash*
sed -i "s|/bin/bash|/usr/bin/zsh|g" /mnt/etc/default/useradd /mnt/etc/passwd

# Generate an fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Get chroot.sh
curl -o /mnt/chroot.sh https://raw.githubusercontent.com/Kirara17233/scripts/main/chroot.sh
chmod +x /mnt/chroot.sh

# Chroot
arch-chroot /mnt /chroot.sh $hostname $swapsize $rootpw $user $userpw $model

# Reboot
umount -R /mnt
reboot
