#!/usr/bin/zsh

e="err.info"

run() {
  errpath="/mnt/$e"
  if [ $2 ]; then
    errpath=$2
  fi
  echo "$1 2>> $errpath" | zsh
  if [ "$?" -ne 0 ]; then
    run $1 $errpath
  fi
}

rm $e

# Update the system clock
run "timedatectl set-ntp true" $e

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
EOF" $e

# Format the partitions
run "mkfs.fat -F32 /dev/sda1" $e
run "mkfs.ext4 /dev/sda2" $e

# Mount the file systems
run "mount /dev/sda2 /mnt" $e
run "mkdir /mnt/boot" $e
run "mount /dev/sda1 /mnt/boot" $e

# Save err.info
run "cp $e /mnt/$e" $e

# Install basic packages
run "pacstrap /mnt base base-devel linux linux-firmware dhcpcd openssh neovim sudo zsh git neofetch intel-ucode grub efibootmgr"

# Change the default shell to zsh
run "rm /mnt/etc/skel/.bash*"
run "sed -i \"s|/bin/bash|/usr/bin/zsh|g\" /mnt/etc/default/useradd /mnt/etc/passwd"

# Generate an fstab file
run "genfstab -U /mnt >> /mnt/etc/fstab"

# Get chroot.sh
run "curl -o /mnt/chroot.sh https://raw.githubusercontent.com/Kirara17233/script/main/chroot.sh"
run "chmod +x /mnt/chroot.sh"

# Chroot
arch-chroot /mnt /chroot.sh $1 $2 $3 $4 $5 $6

# Reboot
run "umount /mnt/boot"
reboot
