#!/bin/sh

cp ./configs/.zshrc $HOME/.zshrc
cp ./configs/.xinitrc $HOME/.xinitrc

sudo mkdir /etc/systemd/system/getty@tty1.service.d/
sudo cp ./configs/override.conf /etc/systemd/system/getty@tty1.service.d/
