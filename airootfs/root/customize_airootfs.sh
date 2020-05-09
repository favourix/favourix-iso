#!/bin/bash

set -e -u

#removing latest kernel
#pacman -R linux --noconfirm

#localization
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

#root config
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

#fix permissions
chown -R root:root /etc
chown -R root:root /root
chmod 700 /root

# add liveuser
useradd -m liveuser -u 500 -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel"
chown -R liveuser:users /home/liveuser
echo "liveuser:liveuser" | chpasswd

#enable autologin
groupadd -r autologin
gpasswd -a liveuser autologin
groupadd -r nopasswdlogin
gpasswd -a liveuser nopasswdlogin

#config files
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

#fix hibernate
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf



#enable installer
groupadd -r installer
gpasswd -a liveuser installer

#enable services
systemctl enable pacman-init.service choose-mirror.service
systemctl set-default multi-user.target
systemctl enable lightdm.service
systemctl set-default graphical.target
#systemctl enable dhcpcd.service
systemctl enable NetworkManager.service
systemctl enable org.cups.cupsd.service
systemctl enable bluetooth.service
systemctl enable ntpd.service
systemctl enable avahi-daemon.service
systemctl enable avahi-daemon.socket


#Enable Calamares Desktop
#ln -s /usr/share/applications/calamares.desktop /home/liveuser/Desktop/calamares.desktop
cp /usr/share/applications/calamares.desktop /home/liveuser/Desktop/calamares.desktop
chmod +rx /home/liveuser/Desktop/calamares.desktop
chown liveuser /home/liveuser/Desktop/calamares.desktop


#pacman init
pacman-key --init
pacman-key --populate archlinux
pacman-key --populate favourix

#get new mirrorlist
reflector -f 30 -l 30 --number 10 --save /etc/pacman.d/mirrorlist
#pacman -Sc --noconfirm
#pacman -Syyu --noconfirm
pacman -Sy --noconfirm
