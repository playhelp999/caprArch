#!/bin/sh

#copy .zsh rc file to set automatic startx
cp ./configs/.zshrc $HOME/.zshrc

#copy .xinitrc file to set keyboard layout
cp ./configs/.xinitrc $HOME/.xinitrc

#create folder and copy override.conf to set autologin
sudo mkdir /etc/systemd/system/getty@tty1.service.d/
sudo cp ./configs/override.conf /etc/systemd/system/getty@tty1.service.d/
