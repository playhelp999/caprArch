#!/bin/sh

cp ./configs/.zshrc $HOME/.zshrc
cp ./configs/.xinitrc $HOME/.xinitrc
cp -f ./configs/override.conf /etc/systemd/system/getty@tty1.service.d/
