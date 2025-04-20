#!/bin/zsh

# === CONFIGURAÇÃO ===
REPO_DIR="$HOME/Documentos/dotfiles"
BRANCH="main"
LOGFILE="$REPO_DIR/backup.log"

cd "$REPO_DIR" || {
  notify-send "❌ Erro no Backup de Dotfiles" "Diretório do repositório não encontrado."
  exit 1
}

# === VERIFICAÇÃO INICIAL ===
echo "🧠 Verificando repositório: $REPO_DIR"
git fetch origin "$BRANCH"

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

# === CHECA DIVERGÊNCIA ===
if [[ "$LOCAL" = "$REMOTE" ]]; then
  echo "✅ Local e remoto sincronizados."
elif [[ "$LOCAL" = "$BASE" ]]; then
  echo "⬇️ Local está atrás do remoto. Cancelando backup."
  notify-send "⚠️ Backup de Dotfiles" "Seu repositório local está desatualizado. Rode 'git pull'."
  exit 1
elif [[ "$REMOTE" = "$BASE" ]]; then
  echo "⬆️ Local à frente do remoto. Realizando push..."
  git push && {
    echo "🚀 Push realizado com sucesso!"
    notify-send "✅ Backup de Dotfiles" "Push pendente realizado com sucesso!"
  }
  exit 0
else
  echo "⚠️ Local e remoto divergiram. Requer intervenção manual."
  notify-send "⚠️ Backup de Dotfiles" "Branches divergiram. Resolva manualmente com pull rebase ou merge."
  exit 1
fi

# === VERIFICA MUDANÇAS LOCAIS ===
if [[ -n $(git status --porcelain) ]]; then
  echo "🔄 Mudanças detectadas. Realizando backup..."
  git add .
  COMMIT_MSG="Backup automático em $(date '+%d/%m/%Y %H:%M')"
  git commit -m "$COMMIT_MSG"
  git push && {
    echo "✅ Backup enviado com sucesso!"
    echo "$(date '+%F %T') - $COMMIT_MSG" >> "$LOGFILE"
    notify-send "✅ Backup de Dotfiles" "Backup feito com sucesso às $(date '+%H:%M')"
  }
else
  echo "📁 Nenhuma mudança detectada. Nada para fazer backup."
  notify-send "📁 Backup de Dotfiles" "Nenhuma mudança detectada. Nada a fazer."
fi
