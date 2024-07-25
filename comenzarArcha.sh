#!/bin/bash

# Variables
THEMES_DIR="/usr/share/themes"
PLANK_THEMES_DIR="/usr/share/plank/themes"
USER_HOME=$(eval echo ~${SUDO_USER})
GTK_DIR="$USER_HOME/gtk"
PLANK_DIR="$USER_HOME/plank"
ERROR_LOG="$USER_HOME/error_log.txt"
ERROR_COUNT=0

# Función para registrar errores
log_error() {
    echo "$1" >> $ERROR_LOG
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

# Limpiar archivo de log de errores
> $ERROR_LOG

# Actualiza los repositorios e instala las dependencias necesarias
sudo apt update || log_error "Error al actualizar los repositorios"
sudo apt install -y kitty-terminfo xvfb xfce4 xfce4-goodies mpv kdenlive simplescreenrecorder firefox plank papirus-icon-theme dbus-x11 neofetch krita sassc zip unzip make git || log_error "Error al instalar dependencias"

# Compila e instala los temas GTK
cd $GTK_DIR || log_error "Error al cambiar al directorio $GTK_DIR"
make build || log_error "Error al compilar los temas GTK"
make package || log_error "Error al empaquetar los temas GTK"
sudo mv $GTK_DIR/pkgs/* $THEMES_DIR || log_error "Error al mover los paquetes compilados al directorio de temas"

# Descomprime todos los archivos de temas
cd $THEMES_DIR || log_error "Error al cambiar al directorio $THEMES_DIR"
for theme in Catppuccin*.zip; do
    sudo unzip "$theme" || log_error "Error al descomprimir $theme"
done
sudo rm *.zip || log_error "Error al eliminar los archivos ZIP"

# Instala los temas de Plank
cd $PLANK_DIR || log_error "Error al cambiar al directorio $PLANK_DIR"
sudo cp -r Catppuccin Catppuccin-solid $PLANK_THEMES_DIR || log_error "Error al copiar los temas de Plank"

# Configuración de Docker
docker pull archlinux || log_error "Error al descargar la imagen de Arch Linux"
docker create -ti --privileged -v $USER_HOME:/home/user/ archlinux || log_error "Error al crear el contenedor de Docker"
docker start $(docker ps -a -q) || log_error "Error al iniciar el contenedor de Docker"
docker exec $(docker ps -a -q) useradd -G wheel user || log_error "Error al añadir el usuario en Docker"
docker exec $(docker ps -a -q) pacman -Syu --noconfirm || log_error "Error al actualizar los paquetes en Docker"
docker exec $(docker ps -a -q) pacman -S vim nano xfce4 xfce4-goodies xorg-server-xvfb neofetch firefox kdenlive krita plank sudo base-devel git sassc zip unzip noto-fonts noto-fonts-cjk noto-fonts-extra noto-fonts-emoji simplescreenrecorder papirus-icon-theme pulseaudio pavucontrol --noconfirm || log_error "Error al instalar paquetes en Docker"
docker cp sudoers $(docker ps -a -q):/etc/ || log_error "Error al copiar el archivo sudoers en Docker"
docker exec $(docker ps -a -q) chown root /etc/sudoers || log_error "Error al cambiar el propietario del archivo sudoers en Docker"
docker exec $(docker ps -a -q) su -c "git clone https://aur.archlinux.org/paru" -l user || log_error "Error al clonar el repositorio paru en Docker"
docker exec $(docker ps -a -q) su -c "chmod +x /home/user/compile-paru.sh" -l user || log_error "Error al cambiar permisos del script compile-paru.sh en Docker"
docker exec $(docker ps -a -q) su -c "/home/user/compile-paru.sh" -l user || log_error "Error al ejecutar el script compile-paru.sh en Docker"
docker exec $(docker ps -a -q) su -c "git clone https://github.com/catppuccin/gtk" -l user || log_error "Error al clonar el repositorio gtk en Docker"
docker exec $(docker ps -a -q) su -c "git clone https://github.com/catppuccin/plank" -l user || log_error "Error al clonar el repositorio plank en Docker"
docker exec $(docker ps -a -q) su -c "chmod +x /home/user/install-catppuccin.sh" -l user || log_error "Error al cambiar permisos del script install-catppuccin.sh en Docker"
docker exec $(docker ps -a -q) su -c "/home/user/install-catppuccin.sh" -l user || log_error "Error al ejecutar el script install-catppuccin.sh en Docker"
docker exec $(docker ps -a -q) su -c "paru -S --noconfirm chrome-remote-desktop" -l user || log_error "Error al instalar chrome-remote-desktop en Docker"

# Mostrar el número total de errores
echo "Número total de errores: $ERROR_COUNT"
