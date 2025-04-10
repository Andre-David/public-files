#!/bin/bash

OUT="diagnostico_audio_$(hostname)_$(date +%Y%m%d).log"
echo "Iniciando diagnóstico - $(date)" > "$OUT"

echo -e "\n==== VERSÃO DO KERNEL ====\n" >> "$OUT"
uname -r >> "$OUT"

echo -e "\n==== ARQUITETURA E MODO DE INICIALIZAÇÃO ====\n" >> "$OUT"
uname -m >> "$OUT"
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "Legacy" >> "$OUT"

echo -e "\n==== MÓDULOS DE ÁUDIO CARREGADOS ====\n" >> "$OUT"
lsmod | grep -iE 'snd|soc|sof|bytcr|rt5640' >> "$OUT"

echo -e "\n==== DISPOSITIVOS DE ÁUDIO ALSA ====\n" >> "$OUT"
aplay -l >> "$OUT" 2>/dev/null
aplay -L >> "$OUT" 2>/dev/null

echo -e "\n==== INFORMAÇÕES DO ALSA (/proc/asound) ====\n" >> "$OUT"
cat /proc/asound/cards >> "$OUT" 2>/dev/null
cat /proc/asound/devices >> "$OUT" 2>/dev/null
cat /proc/asound/modules >> "$OUT" 2>/dev/null

echo -e "\n==== FIRMWARE CARREGADO (dmesg) ====\n" >> "$OUT"
dmesg | grep -i firmware >> "$OUT"

echo -e "\n==== DISPOSITIVOS PCI DE ÁUDIO ====\n" >> "$OUT"
lspci -nnk | grep -A3 -i audio >> "$OUT"

echo -e "\n==== DISPOSITIVOS ACPI E I2C ====\n" >> "$OUT"
ls /sys/bus/acpi/devices/ >> "$OUT"
ls /sys/bus/i2c/devices/ >> "$OUT"

echo -e "\n==== STATUS DO SOF (Sound Open Firmware) ====\n" >> "$OUT"
dmesg | grep -i sof >> "$OUT"

echo -e "\n==== PACOTES INSTALADOS RELACIONADOS A SOM E FIRMWARE ====\n" >> "$OUT"
dpkg -l | grep -iE 'alsa|pulse|firmware|sof|ucm' >> "$OUT"

echo -e "\n==== DMESG FILTRADO (ÁUDIO) ====\n" >> "$OUT"
dmesg | grep -iE 'audio|snd|soc|sof|bytcr|rt5640' >> "$OUT"

echo -e "\nDiagnóstico concluído. Arquivo: $OUT"
