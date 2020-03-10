#!/bin/sh

p ./configs/.zshrc $HOME/.zshrc
cp ./configs/.xinitrc $HOME/.xinitrc
sudo cp -f ./configs/override.conf /etc/systemd/system/getty@tty1.service.d/override.conf
