#!/bin/bash

echo "== Instalando arquivos UCM para chtnau8824 =="

# Instalar dependência git caso não tenha
sudo apt install -y git

# Clonar repositório
cd /tmp
git clone https://github.com/thesofproject/alsa-ucm-conf.git

# Verificar existência dos arquivos
if [ ! -d alsa-ucm-conf/ucm2/conf.d/chtnau8824 ]; then
    echo "✗ Arquivos chtnau8824 não encontrados no repositório."
    exit 1
fi

# Copiar arquivos para o sistema
sudo cp -r alsa-ucm-conf/ucm2/conf.d/chtnau8824* /usr/share/alsa/ucm2/conf.d/

echo "✓ Arquivos UCM copiados para /usr/share/alsa/ucm2/conf.d/"

# Reiniciar PipeWire (ou PulseAudio)
echo "== Reiniciando servidor de áudio =="

if systemctl --user is-active pipewire &>/dev/null; then
    systemctl --user restart pipewire pipewire-pulse wireplumber
    echo "✓ PipeWire reiniciado"
else
    pulseaudio -k
    pulseaudio --start
    echo "✓ PulseAudio reiniciado"
fi

echo -e "\nVerifique com 'pactl list sinks short' se o áudio foi ativado."