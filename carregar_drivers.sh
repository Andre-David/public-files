#!/bin/bash

echo "[1/7] Criando blacklist do módulo 'snd_hdmi_lpe_audio'..."
echo "blacklist snd_hdmi_lpe_audio" | sudo tee /etc/modprobe.d/blacklist-audio-positivo.conf

echo "[2/7] Atualizando initramfs..."
if command -v update-initramfs >/dev/null; then
    sudo update-initramfs -u
elif command -v mkinitcpio >/dev/null; then
    sudo mkinitcpio -P
else
    echo "❌ Não foi possível atualizar o initramfs. Faça isso manualmente."
fi

echo "[3/7] Adicionando blacklist ao GRUB (opcional)..."
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="modprobe.blacklist=snd_hdmi_lpe_audio /' /etc/default/grub

echo "[4/7] Atualizando o GRUB..."
if command -v update-grub >/dev/null; then
    sudo update-grub
elif command -v grub-mkconfig >/dev/null; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "❌ Não foi possível atualizar o GRUB. Faça isso manualmente."
fi

echo "[5/7] Ativando microfone digital (DMIC), se disponível..."
MIC_IDS=$(amixer controls | grep "DMIC.*Enable" | cut -d= -f2 | cut -d, -f1)
if [ -n "$MIC_IDS" ]; then
    for id in $MIC_IDS; do
        amixer cset numid="$id" on
    done
    echo "✅ Microfone digital ativado."
else
    echo "ℹ️ Nenhum controle 'DMIC Enable' encontrado. Pulando essa etapa."
fi

echo "[6/7] Verificando se o módulo 'snd_hdmi_lpe_audio' está carregado..."
if lsmod | grep -q snd_hdmi_lpe_audio; then
    echo "⚠️ O módulo ainda está ativo. Reinicie o sistema para aplicar a blacklist."
else
    echo "✅ Módulo 'snd_hdmi_lpe_audio' não está carregado. Tudo certo."
fi

echo "[7/7] Detectando adaptador Wi-Fi Realtek e sugerindo driver..."
REALTEK_CHIP=$(lspci | grep -i realtek | grep -i network)
if [ -n "$REALTEK_CHIP" ]; then
    echo "🔍 Adaptador Realtek encontrado:"
    echo "$REALTEK_CHIP"
    
    # Sugestões de drivers mais comuns
    case "$REALTEK_CHIP" in
        *8723*|*8188*) 
            echo "➡️ Sugestão: instalar driver dkms para rtl8723de ou rtl8188eu."
            echo "Exemplo (Ubuntu/Debian): sudo apt install rtl8723de-dkms ou rtl8188eu-dkms"
            ;;
        *8821*) 
            echo "➡️ Sugestão: instalar driver dkms para rtl8821ce."
            echo "Exemplo (Ubuntu): sudo apt install rtl8821ce-dkms"
            ;;
        *)
            echo "ℹ️ Driver Realtek não identificado automaticamente. Consulte o modelo exato com:"
            echo "lspci -nn | grep -i network"
            ;;
    esac
else
    echo "✅ Nenhum adaptador Realtek detectado. Pulando essa etapa."
fi