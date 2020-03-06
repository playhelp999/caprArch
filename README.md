# What is caprArch?

`caprArch` is a featureful, yet simple Arch Linux install script

# Features
- Easy to configure, install and use
- Automatic disk partitioning
- XFCE friendly desktop environment

# Support

This software is a fork of a frequently updated project, and if it's not known to you I am not a developer so I will not frequently update this project as the parent project is.

## So, here is a fun Disclaimer

THIS PIECE OF SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTIES OF ANY KIND. I AM NOT RESPONSIBLE FOR ANY USAGE OF THIS SCRIPT, OR ANY IMPORTANT DISK ACCIDENTALLY FORMATTED BY THIS INSTALL SCRIPT, OR YOUR ENTIRE SYSTEM EXPLODING, OR WHATEVER.

REALLY. USE AT YOUR OWN RISK.

# Configuration & Installation Procedure

- Download the official Arch Linux .iso file from the [official site download section](https://archlinux32.org/download/)

- Flash it onto an USB drive with softwares like `dd`, Rufus, balenaEtcher or whatever, stick it in the desired PC and boot the provided live environment, as per the ArchWiki installation page

- Inside this live environment you should now connect to the internet using either ethernet or wifi as you like (use `wifi-menu` or `nmcli` or as your preference), then download the latest script from this repository with the following command:

```bash
wget https://raw.githubusercontent.com/playhelp999/caprArch/master/install.sh
```

- Modify it to fit your own purposes (I suggest you to edit the partition mounts, change hostname, username, purge packages and features you don't need and so on, or do like [zetaemme](https://github.com/zetaemme/zls) and myself included and fork this repository as a base for your own Arch Linux install script!)

```bash
vim ./install.sh
```

- Change file permissions to make it executable, of course!

```bash
chmod +x ./install.sh
```

- Execute `install.sh` script and insert the information required when prompted

```bash
./install.sh
```

## License

This software is released under MIT License.
Read LICENSE for more information.
