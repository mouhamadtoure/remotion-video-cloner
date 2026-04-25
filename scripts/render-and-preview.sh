#!/bin/bash
# ============================================================
# render-and-preview.sh — Rend la vidéo Remotion et partage le résultat
#
# Usage :
#   bash scripts/render-and-preview.sh [composition-id]
#   npm run preview
#
# Rend la vidéo, l'uploade en ligne, et donne l'URL pour la voir
# ============================================================

COMP_ID="${1:-MyComposition}"
OUT_DIR="out"
OUT_FILE="$OUT_DIR/video.mp4"

echo "🎬 Rendu de la composition '$COMP_ID'..."
mkdir -p "$OUT_DIR"

# Rendu avec Remotion
npx remotion render src/index.ts "$COMP_ID" "$OUT_FILE" \
  --codec h264 \
  --log error

if [ ! -f "$OUT_FILE" ]; then
  echo "❌ Erreur : le fichier rendu n'existe pas ($OUT_FILE)"
  exit 1
fi

SIZE=$(du -sh "$OUT_FILE" | cut -f1)
echo "✅ Rendu terminé : $OUT_FILE ($SIZE)"
echo ""

# Ouvrir localement (macOS)
if command -v open &>/dev/null; then
  echo "📺 Ouverture locale..."
  open "$OUT_FILE"
fi

# Upload pour partager
echo "📤 Upload pour partager en ligne..."
FILENAME="remotion-render-$(date +%Y%m%d-%H%M%S).mp4"

URL=$(curl -s --upload-file "$OUT_FILE" "https://transfer.sh/$FILENAME")

if [ -z "$URL" ] || [[ "$URL" == *"error"* ]]; then
  URL=$(curl -s -F "file=@$OUT_FILE" "https://0x0.st")
fi

echo ""
echo "════════════════════════════════════════════"
echo "✅ VIDÉO RENDUE ET DISPONIBLE"
echo ""
echo "📁 Local     : $OUT_FILE"

if [ -n "$URL" ]; then
  echo "🔗 En ligne  : $URL"
  echo "⏳ Expire    : dans 14 jours"
  if command -v pbcopy &>/dev/null; then
    echo "$URL" | pbcopy
    echo "📋 URL copiée dans le presse-papiers !"
  fi
fi

echo ""
echo "👁️  Pour voir dans Remotion Studio :"
echo "   npm run dev"
echo "════════════════════════════════════════════"
