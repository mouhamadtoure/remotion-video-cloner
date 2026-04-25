#!/bin/bash
# ============================================================
# share-video.sh — Rend une vidéo locale accessible via URL publique
# Utilise transfer.sh (gratuit, pas de compte, expire en 14 jours)
#
# Usage :
#   bash scripts/share-video.sh /chemin/video.mp4
#   npm run share -- /chemin/video.mp4
#
# Retourne une URL publique que tu peux donner à Codex, Cursor ou Claude
# ============================================================

INPUT="$1"

if [ -z "$INPUT" ]; then
  echo "❌ Usage: bash scripts/share-video.sh /chemin/vers/video.mp4"
  echo ""
  echo "Ce script uploade ta vidéo locale vers une URL publique temporaire."
  echo "Utilise ensuite cette URL avec Codex, Cursor ou n'importe quel AI."
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "❌ Fichier introuvable : $INPUT"
  exit 1
fi

FILENAME=$(basename "$INPUT")
SIZE=$(du -sh "$INPUT" | cut -f1)

echo "📤 Upload de '$FILENAME' ($SIZE)..."
echo "   Service : transfer.sh (gratuit, expire dans 14 jours)"
echo ""

# Upload vers transfer.sh
URL=$(curl -s --upload-file "$INPUT" "https://transfer.sh/$FILENAME")

if [ -z "$URL" ] || [[ "$URL" == *"error"* ]]; then
  echo "⚠️  transfer.sh indisponible, tentative avec 0x0.st..."
  URL=$(curl -s -F "file=@$INPUT" "https://0x0.st")
fi

if [ -z "$URL" ] || [[ "$URL" == *"error"* ]]; then
  echo "⚠️  Tentative avec file.io..."
  RESPONSE=$(curl -s -F "file=@$INPUT" "https://file.io/?expires=14d")
  URL=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('link',''))" 2>/dev/null)
fi

if [ -z "$URL" ]; then
  echo "❌ Tous les services d'upload sont indisponibles."
  echo "   Solution alternative : upload manuellement sur https://transfer.sh"
  exit 1
fi

echo "════════════════════════════════════════════"
echo "✅ VIDÉO DISPONIBLE EN LIGNE"
echo ""
echo "🔗 URL publique :"
echo "   $URL"
echo ""
echo "👉 Copie cette URL et donne-la à Codex avec le prompt :"
echo ""
echo "   \"Reproduis cette vidéo : $URL"
echo "   Adapte à mon projet : [description]"
echo "   Lance d'abord : npm run setup"
echo "   Puis analyse : npm run analyze -- $URL\""
echo ""
echo "⏳ Cette URL expire dans 14 jours."
echo "════════════════════════════════════════════"

# Copier l'URL dans le presse-papiers (macOS)
if command -v pbcopy &>/dev/null; then
  echo "$URL" | pbcopy
  echo "📋 URL copiée dans le presse-papiers !"
fi
