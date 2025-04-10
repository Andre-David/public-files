#!/bin/bash

echo "== Iniciando carregamento de módulos para áudio bytcr-rt5640 =="

MODULOS=(
  snd_soc_rt5640
  snd_intel_sst_acpi
  snd_soc_sst_bytcr_rt5640
)

for MOD in "${MODULOS[@]}"; do
  echo "→ Carregando módulo: $MOD"
  sudo modprobe "$MOD" 2>/dev/null && echo "✓ $MOD carregado" || echo "✗ Falha ao carregar $MOD"
done

echo -e "\n== Verificando dispositivos de áudio =="
aplay -l || echo "Nenhum dispositivo encontrado"

echo -e "\n== Verificando presença no /etc/modules =="

for MOD in "${MODULOS[@]}"; do
  if ! grep -q "^$MOD" /etc/modules; then
    echo "$MOD" | sudo tee -a /etc/modules > /dev/null
    echo "✓ Adicionado $MOD ao /etc/modules"
  else
    echo "✓ $MOD já presente no /etc/modules"
  fi
done

echo -e "\nReinicie o sistema para aplicar os módulos persistentemente."
