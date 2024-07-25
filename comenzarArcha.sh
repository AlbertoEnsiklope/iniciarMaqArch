#!/bin/bash

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Docker no está instalado. Instalando Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Verificar si Python 3 está instalado
if ! command -v python3 &> /dev/null; then
    echo "Python 3 no está instalado. Instalando Python 3..."
    sudo apt update
    sudo apt install -y python3
fi

# Descargar la imagen de Arch Linux
echo "Descargando la imagen de Arch Linux..."
sudo docker pull archlinux

# Crear y arrancar un contenedor de Docker basado en Arch Linux
echo "Creando y arrancando el contenedor de Docker..."
sudo docker run -d --name arch_container archlinux sleep infinity

# Añadir un usuario al contenedor
echo "Añadiendo un usuario al contenedor..."
sudo docker exec arch_container useradd -m -s /bin/bash user
sudo docker exec arch_container passwd -d user

# Actualizar los paquetes del contenedor e instalar dependencias
echo "Actualizando paquetes e instalando dependencias..."
sudo docker exec arch_container bash -c "pacman -Syu --noconfirm && pacman -S --noconfirm python3 gtk3 sudo"

# Instalar el tema GTK "Catppuccin"
echo "Instalando el tema GTK 'Catppuccin'..."
sudo docker exec arch_container bash -c "git clone https://github.com/catppuccin/gtk.git && cd gtk && ./install.sh"

# Instalar Chrome Remote Desktop
echo "Instalando Chrome Remote Desktop..."
sudo docker exec arch_container bash -c "pacman -S --noconfirm git base-devel && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && paru -S --noconfirm chrome-remote-desktop"

# Configurar el entorno de escritorio XFCE para Chrome Remote Desktop
echo "Configurando el entorno de escritorio XFCE..."
sudo docker exec arch_container bash -c "pacman -S --noconfirm xfce4 xfce4-goodies"
sudo docker exec arch_container bash -c "echo 'exec startxfce4' > /home/user/.xinitrc"
sudo docker exec arch_container bash -c "chown user:user /home/user/.xinitrc"

# Solicitar el código de configuración de Chrome Remote Desktop
read -p "Introduce el código de configuración de Chrome Remote Desktop: " CRD_CODE
sudo docker exec arch_container bash -c "su - user -c 'DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=\"$CRD_CODE\"'"

# Verificar permisos
echo "Verificando permisos..."
sudo docker exec arch_container bash -c "usermod -aG chrome-remote-desktop user"

echo "Configuración completa. El contenedor de Docker está ejecutando Arch Linux con XFCE y es accesible de forma remota a través de Chrome Remote Desktop."
