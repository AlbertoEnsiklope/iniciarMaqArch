#!/bin/bash

# Variables
THEMES_DIR="/usr/share/themes"
PLANK_THEMES_DIR="/usr/share/plank/themes"
USER_HOME=$(eval echo ~${SUDO_USER})
GTK_DIR="$USER_HOME/gtk"
PLANK_DIR="$USER_HOME/plank"

# Actualiza los repositorios e instala las dependencias necesarias
sudo apt update
sudo apt install -y kitty-terminfo xvfb xfce4 xfce4-goodies mpv kdenlive simplescreenrecorder firefox-esr plank papirus-icon-theme dbus-x11 neofetch krita sassc zip unzip

# Compila e instala los temas GTK
cd $GTK_DIR
make build
make package
sudo mv $GTK_DIR/pkgs/* $THEMES_DIR

# Descomprime todos los archivos de temas
cd $THEMES_DIR
for theme in Catppuccin*.zip; do
    sudo unzip "$theme"
done
sudo rm *.zip

# Instala los temas de Plank
cd $PLANK_DIR
sudo cp -r Catppuccin Catppuccin-solid $PLANK_THEMES_DIR

# Configuración de Docker
docker pull archlinux
docker create -ti --privileged -v $USER_HOME:/home/user/ archlinux
docker start $(docker ps -a -q)
docker exec $(docker ps -a -q) useradd -G wheel user
docker exec $(docker ps -a -q) pacman -Syu --noconfirm
docker exec $(docker ps -a -q) pacman -S vim nano xfce4 xfce4-goodies xorg-server-xvfb neofetch firefox kdenlive krita plank sudo base-devel git sassc zip unzip noto-fonts noto-fonts-cjk noto-fonts-extra noto-fonts-emoji simplescreenrecorder papirus-icon-theme pulseaudio pavucontrol --noconfirm
docker cp sudoers $(docker ps -a -q):/etc/
docker exec $(docker ps -a -q) chown root /etc/sudoers
docker exec $(docker ps -a -q) su -c "git clone https://aur.archlinux.org/paru" -l user
docker exec $(docker ps -a -q) su -c "chmod +x /home/user/compile-paru.sh" -l user
docker exec $(docker ps -a -q) su -c "/home/user/compile-paru.sh" -l user
docker exec $(docker ps -a -q) su -c "git clone https://github.com/catppuccin/gtk" -l user
docker exec $(docker ps -a -q) su -c "git clone https://github.com/catppuccin/plank" -l user
docker exec $(docker ps -a -q) su -c "chmod +x /home/user/install-catppuccin.sh" -l user
docker exec $(docker ps -a -q) su -c "/home/user/install-catppuccin.sh" -l user
docker exec $(docker ps -a -q) su -c "paru -S --noconfirm chrome-remote-desktop" -l user

# Limpieza
# cd $USER_HOME
# rm -rf paru
