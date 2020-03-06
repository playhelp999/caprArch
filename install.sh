# boot partition size, in MB
boot_partition_size=500

# home partition size, in GB
home_partition_size=80

# checks wheter there is multilib repo enabled properly or not
IS_MULTILIB_REPO_DISABLED=$(cat /etc/pacman.conf | grep "#\[multilib\]" | wc -l)
if [ "$IS_MULTILIB_REPO_DISABLED" == "1" ]
then
    echo "You need to enable [multilib] repository inside /etc/pacman.conf file before running this script, aborting installation"
    exit -1
fi
echo "[multilib] repo correctly enabled, continuing"

# syncing system datetime
timedatectl set-ntp true

# getting latest mirrors for italy and germany
wget -O mirrorlist "https://archlinux32.org/mirrorlist?country=fr&country=de&country=ch&protocol=https&ip_version=4&ip_version=6"
sed -ie 's/^.//g' ./mirrorlist
mv ./mirrorlist /etc/pacman.d/mirrorlist

# updating mirrors
pacman -Syyy

# adding fzf for making disk selection easier
pacman -S fzf --noconfirm

# open dialog for installation type
install_type=$(printf 'UEFI installation (recommended)\nBIOS installation' | fzf | awk '{print $1}')

# open dialog for disk selection
selected_disk=$(sudo fdisk -l | grep 'Disk /dev/' | awk '{print $2,$3,$4}' | sed 's/,$//' | fzf | sed -e 's/\/dev\/\(.*\):/\1/' | awk '{print $1}')  

if [ "${install_type}" == "UEFI" ]; then
    # formatting disk for UEFI install type
    echo "Formatting disk for UEFI install type"
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/${selected_disk}
      g # gpt partitioning
      n # new partition
        # default: primary partition
        # default: partition 1
      +${boot_partition_size}M # mb on boot partition
        # default: yes if asked
      n # new partition
        # default: primary partition
        # default: partition 2
      +${home_partition_size}G # gb for home partition
        # default: yes if asked
      n # new partition
        # default: primary partition
        # default: partition 3
        # default: all space left of for root partition
        # default: yes if asked
      t # change partition type
      1 # selecting partition 1
      1 # selecting EFI partition type
      w # writing changes to disk
EOF
else
    # formatting disk for BIOS install type
    echo "Formatting disk for BIOS install type"
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/${selected_disk}
      o # gpt partitioning
      n # new partition
        # default: primary partition
        # default: partition 1
        # default: select first default sector value
      +${boot_partition_size}M # mb on boot partition
        # default: yes if asked
      n # new partition
        # default: primary partition
        # default: partition 2
        # default: select second default sector value
      +${home_partition_size}G # gb for home partition
        # default: yes if asked
      n # new partition
        # default: primary partition
        # default: partition 3
        # default: all space left of for root partition
        # default: yes if asked
      w # writing changes to disk
EOF
fi

# outputting partition changes
fdisk -l /dev/${selected_disk}

# partition filesystem formatting
yes | mkfs.fat -F32 /dev/${selected_disk}1
yes | mkfs.ext4 /dev/${selected_disk}2
yes | mkfs.ext4 /dev/${selected_disk}3

# disk mount
mount /dev/${selected_disk}3 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/${selected_disk}1 /mnt/boot
mount /dev/${selected_disk}2 /mnt/home

# pacstrap-ping desired disk
pacstrap /mnt base base-devel vim grub networkmanager linux linux-headers \
alacritty git zsh intel-ucode amd-ucode cpupower vlc \
xorg-server xorg-xinit ttf-dejavu ttf-liberation ttf-inconsolata noto-fonts \
chromium firefox xf86-video-intel zip unzip unrar \
pulseaudio mate-media pamixer telegram-desktop python python-pip wget \
openssh xorg-xrandr noto-fonts-emoji imagemagick xclip light \
ttf-roboto playerctl papirus-icon-theme hwloc p7zip \
nemo linux-firmware tree man fzf zsh-syntax-highlighting xdotool cronie \
python-dbus bind-tools xfce4

# generating fstab
genfstab -U /mnt >> /mnt/etc/fstab

# adding multilib repo inside chroot install environment
arch-chroot /mnt echo "[multilib]" >> /etc/pacman.conf
arch-chroot /mnt echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

# updating repo status
arch-chroot /mnt pacman -Syyy

# setting right timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

# enabling font presets for better font rendering
arch-chroot /mnt ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
arch-chroot /mnt ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
arch-chroot /mnt ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

# synchronizing timer
arch-chroot /mnt hwclock --systohc

# localizing system
arch-chroot /mnt sed -ie 's/#it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/g' /etc/locale.gen
arch-chroot /mnt sed -ie 's/#it_IT ISO-8859-1/it_IT ISO-8859-1/g' /etc/locale.gen

# generating locale
arch-chroot /mnt locale-gen

# setting system language
arch-chroot /mnt echo "LANG=it_IT.UTF-8" >> /mnt/etc/locale.conf

# setting machine name
arch-chroot /mnt echo "caprarch" >> /mnt/etc/hostname

# setting hosts file
arch-chroot /mnt echo "127.0.0.1 localhost" >> /mnt/etc/hosts
arch-chroot /mnt echo "::1 localhost" >> /mnt/etc/hosts
arch-chroot /mnt echo "127.0.1.1 caprarch.localdomain caprarch" >> /mnt/etc/hosts

# making sudoers do sudo stuff without requiring password typing
arch-chroot /mnt sed -ie 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

# make initframs
arch-chroot /mnt mkinitcpio -p linux

# setting root password
arch-chroot /mnt sudo -u root /bin/zsh -c 'echo "Insert root password: " && read root_password && echo -e "$root_password\n$root_password" | passwd root'

# making user luca
arch-chroot /mnt useradd -m -G wheel -s /bin/zsh luca

# setting luca password
arch-chroot /mnt sudo -u root /bin/zsh -c 'echo "Insert luca password: " && read luca_password && echo -e "$luca_password\n$luca_password" | passwd luca'

# installing grub bootloader
if [ "${install_type}" == "UEFI" ]; then
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --removable
else
    arch-chroot /mnt grub-install --target=i386-pc /dev/${selected_disk}
fi

# adding more timeout time for grub
arch-chroot /mnt sed -ie 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=15/g' /etc/default/grub

# making grub auto config
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# changing governor to performance
arch-chroot /mnt echo "governor='performance'" >> /mnt/etc/default/cpupower

# making services start at boot
arch-chroot /mnt systemctl enable cpupower.service
arch-chroot /mnt systemctl enable NetworkManager.service
arch-chroot /mnt systemctl enable cronie.service
arch-chroot /mnt systemctl enable sshd.service

# enabling and starting DNS resolver via systemd-resolved
arch-chroot /mnt systemctl enable systemd-resolved.service
arch-chroot /mnt systemctl start systemd-resolved.service

# making i3 default for startx for both root and luca
arch-chroot /mnt echo "exec startxfce4" >> /mnt/root/.xinitrc
arch-chroot /mnt echo "exec startxfce4" >> /mnt/home/luca/.xinitrc

# installing yay
arch-chroot /mnt sudo -u luca git clone https://aur.archlinux.org/yay.git /home/luca/yay_tmp_install
arch-chroot /mnt sudo -u luca /bin/zsh -c "cd /home/luca/yay_tmp_install && yes | makepkg -si"
arch-chroot /mnt rm -rf /home/luca/yay_tmp_install

# installing various packages from AUR
arch-chroot /mnt sudo -u luca yay -S downgrade --noconfirm
arch-chroot /mnt sudo -u luca yay -S whatsapp-nativefier --noconfirm

# installing better font rendering packages
arch-chroot /mnt sudo -u luca /bin/zsh -c "yes | yay -S freetype2-infinality-remix fontconfig-infinality-remix cairo-infinality-remix"

# installing oh-my-zsh
arch-chroot /mnt sudo -u luca /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# installing pi theme for zsh
arch-chroot /mnt sudo -u luca /bin/zsh -c "wget -O /home/luca/.oh-my-zsh/themes/pi.zsh-theme https://raw.githubusercontent.com/tobyjamesthomas/pi/master/pi.zsh-theme"

# installing vundle
arch-chroot /mnt sudo -u luca mkdir /home/luca/.vim
arch-chroot /mnt sudo -u luca mkdir /home/luca/.vim/bundle
arch-chroot /mnt sudo -u luca git clone https://github.com/VundleVim/Vundle.vim.git /home/luca/.vim/bundle/Vundle.vim

# create pictures folder, secrets folder and moving default wallpaper
arch-chroot /mnt sudo -u luca mkdir /home/luca/Pictures/
arch-chroot /mnt sudo -u luca mkdir /home/luca/.secrets/

# enabled [multilib] repo on installed system
arch-chroot /mnt echo "[multilib]" >> /etc/pacman.conf
arch-chroot /mnt echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

# enable features on /etc/pacman.conf file
arch-chroot /mnt sed -ie 's/#UseSyslog/UseSyslog/g' /etc/pacman.conf
arch-chroot /mnt sed -ie 's/#Color/Color/g' /etc/pacman.conf
arch-chroot /mnt sed -ie 's/#TotalDownload/TotalDownload/g' /etc/pacman.conf
arch-chroot /mnt sed -ie 's/#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf

# unmounting all mounted partitions
umount -R /mnt

# syncing disks
sync

echo ""
echo "INSTALLATION COMPLETE! enjoy :)"
echo ""

sleep 3
