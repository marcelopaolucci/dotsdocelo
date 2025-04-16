#!/bin/zsh

# Caminho da pasta onde estão seus dotfiles
cd ~/Documentos/dotfiles || exit 1

# Verifica se há mudanças
if [[ -n $(git status --porcelain) ]]; then
  echo "🔄 Mudanças detectadas. Fazendo backup..."
  git add .
  git commit -m "Backup automático em $(date '+%d/%m/%Y %H:%M')"
  git push
  echo "✅ Backup enviado para o GitHub com sucesso!"
else
  echo "📁 Nenhuma mudança detectada. Nada para fazer backup."
fi
