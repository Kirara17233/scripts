#!/usr/bin/zsh

e="err.info"

run() {
  echo $1 | zsh
  if [ $? -ne 0 ]; then
    run $1
  fi
}

# Update the system clock
run "timedatectl set-ntp true"

# Partition the disks
run "sed -e \"s| *#.*||g\" << EOF | fdisk /dev/sda
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
EOF"

# Format the partitions
run "mkfs.fat -F32 /dev/sda1"
run "mkfs.ext4 /dev/sda2"

# Mount the file systems
run "mount /dev/sda2 /mnt"
run "mkdir /mnt/boot"
run "mount /dev/sda1 /mnt/boot"

# Install basic packages
run "pacstrap /mnt base base-devel linux linux-firmware dhcpcd openssh neovim sudo zsh git neofetch intel-ucode grub efibootmgr docker"

# Change the default shell to zsh
run "rm /mnt/etc/skel/.bash*"
run "sed -i \"s|/bin/bash|/usr/bin/zsh|g\" /mnt/etc/default/useradd /mnt/etc/passwd"

# Generate an fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Get chroot.sh
run "curl -o /mnt/chroot.sh https://raw.githubusercontent.com/Kirara17233/script/main/chroot.sh"
run "chmod +x /mnt/chroot.sh"

# Chroot
arch-chroot /mnt /chroot.sh $1 $2 $3 $4 $5 $6

# Reboot
run "umount /mnt/boot"
reboot
