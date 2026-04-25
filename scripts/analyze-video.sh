#!/bin/bash
# ============================================================
# analyze-video.sh — Analyse une vidéo et prépare le contexte
# pour qu'un AI puisse la reproduire avec Remotion
#
# Usage :
#   bash scripts/analyze-video.sh https://www.tiktok.com/@user/video/123
#   bash scripts/analyze-video.sh https://youtube.com/shorts/abc
#   bash scripts/analyze-video.sh /chemin/local/video.mp4
#   bash scripts/analyze-video.sh https://example.com/video.mp4
# ============================================================

set -e

INPUT="$1"
FRAMES_DIR="/tmp/video-frames"
OUTPUT_DIR="$FRAMES_DIR/$(date +%s)"
VIDEO_PATH="$OUTPUT_DIR/source.mp4"

if [ -z "$INPUT" ]; then
  echo "❌ Usage: bash scripts/analyze-video.sh <URL ou chemin>"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
echo "📂 Dossier d'analyse : $OUTPUT_DIR"

# ── 1. Récupération de la vidéo ──────────────────────────────
echo ""
echo "⬇️  Récupération de la vidéo..."

if [[ "$INPUT" == http* ]]; then
  # URL directe MP4
  if [[ "$INPUT" == *.mp4 || "$INPUT" == *.mov || "$INPUT" == *.webm ]]; then
    curl -sL "$INPUT" -o "$VIDEO_PATH"
    echo "✅ Vidéo téléchargée (direct)"
  else
    # TikTok, YouTube, Instagram, Twitter, etc.
    yt-dlp "$INPUT" \
      --format "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
      --merge-output-format mp4 \
      --output "$VIDEO_PATH" \
      --no-playlist \
      --quiet
    echo "✅ Vidéo téléchargée via yt-dlp"
  fi
else
  # Fichier local
  if [ -f "$INPUT" ]; then
    cp "$INPUT" "$VIDEO_PATH"
    echo "✅ Vidéo locale copiée"
  else
    echo "❌ Fichier introuvable : $INPUT"
    exit 1
  fi
fi

# ── 2. Métadonnées ────────────────────────────────────────────
echo ""
echo "📊 Métadonnées :"
DURATION=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$VIDEO_PATH" 2>/dev/null | cut -d. -f1)
FPS=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$VIDEO_PATH" 2>/dev/null | bc 2>/dev/null || echo "30")
WIDTH=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=width -of csv=p=0 "$VIDEO_PATH" 2>/dev/null)
HEIGHT=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=height -of csv=p=0 "$VIDEO_PATH" 2>/dev/null)

echo "  Durée    : ${DURATION}s"
echo "  FPS      : $FPS"
echo "  Résolution : ${WIDTH}x${HEIGHT}"
echo "  Frames totales : $((DURATION * FPS))"

# ── 3. Extraction des frames ──────────────────────────────────
echo ""
echo "🎞️  Extraction des frames..."

# 2 frames/sec pour vidéo courte, 1 frame/sec pour plus longue
if [ "$DURATION" -lt 30 ] 2>/dev/null; then
  RATE="fps=2"
  MAX_FRAMES=30
else
  RATE="fps=1"
  MAX_FRAMES=40
fi

ffmpeg -i "$VIDEO_PATH" \
  -vf "${RATE},scale=800:-1" \
  -frames:v $MAX_FRAMES \
  -q:v 3 \
  "$OUTPUT_DIR/frame_%03d.jpg" \
  -y -loglevel quiet

FRAME_COUNT=$(ls "$OUTPUT_DIR"/frame_*.jpg 2>/dev/null | wc -l | tr -d ' ')
echo "✅ $FRAME_COUNT frames extraites"

# ── 4. Rapport de contexte ────────────────────────────────────
REPORT="$OUTPUT_DIR/VIDEO_CONTEXT.md"
cat > "$REPORT" << EOF
# Contexte Vidéo — Analyse pour Remotion

## Métadonnées
- **Source :** $INPUT
- **Durée :** ${DURATION}s
- **FPS :** $FPS
- **Résolution :** ${WIDTH}x${HEIGHT}
- **Frames totales :** $((DURATION * FPS))
- **Format Remotion :** durationInFrames=${DURATION}×${FPS}=$((DURATION * FPS)), fps=${FPS}, width=${WIDTH}, height=${HEIGHT}

## Frames extraites
- **Dossier :** $OUTPUT_DIR
- **Nombre :** $FRAME_COUNT frames
- **Format :** frame_001.jpg à frame_$(printf '%03d' $FRAME_COUNT).jpg

## Instructions pour l'AI

Lis chaque frame dans l'ordre et extrait :

### 1. Scènes et timings
Pour chaque scène identifiée :
- Frame de début / Frame de fin
- Durée en frames (à ${FPS}fps)
- Description du contenu

### 2. Par scène, identifie :
- **Fond :** couleur hex, dégradé (valeurs exactes), image/vidéo
- **Éléments :** mockups 3D, icônes, textes, UI components
- **Animation :** spring (stiffness/damping), interpolate (linear/easing), timing
- **Effets :** blur, glow, shadow, motion blur, 3D rotation
- **Transitions :** fade, slide, wipe (durée en frames)
- **Audio :** SFX sur quels events, musique background

### 3. Typographie
- Police (Google Font ou custom ?)
- Tailles (px ou vw)
- Poids (400/500/600/700)
- Couleurs hex
- Animations (apparition mot par mot, lettre par lettre, fade)

### 4. Palette
- Couleurs primaires hex
- Couleurs de fond hex
- Couleurs de texte hex

## Assets disponibles dans ce projet
- public/3d/ : iphone.glb, laptop.glb, box.glb
- public/audio/sfx/ : whoosh.mp3, notification.mp3, click.mp3
- public/audio/music/ : ambient.mp3, upbeat.mp3
- public/lottie/ : loading.json, success.json, confetti.json
- public/fonts/ : Inter-Regular/Bold/Light.woff2
- public/images/icons/ : google-drive, google-docs, microsoft-word,
  microsoft-excel, microsoft-teams, instagram, tiktok, slack, notion,
  figma, github, vercel (SVG)

## Maintenant génère le code Remotion complet

Structure attendue :
\`\`\`
src/
├── Root.tsx
├── scenes/Scene01.tsx, Scene02.tsx...
├── components/ (NotificationCard, AppIcon, GradientBg...)
└── assets/constants.ts (couleurs, textes, timings)
\`\`\`

Règles :
- Une scène = un fichier
- extrapolateRight/Left: 'clamp' sur toutes les interpolations
- staticFile() pour tout asset dans public/
- OffthreadVideo jamais Video
- Projet complet prêt pour : npm run dev
EOF

echo ""
echo "📋 Rapport généré : $REPORT"
echo ""
echo "════════════════════════════════════════════"
echo "✅ ANALYSE TERMINÉE"
echo ""
echo "Frames : $OUTPUT_DIR/frame_*.jpg"
echo "Rapport : $REPORT"
echo ""
echo "👉 Donne maintenant à l'AI :"
echo "   1. Les frames (frame_001.jpg à frame_$(printf '%03d' $FRAME_COUNT).jpg)"
echo "   2. Le fichier VIDEO_CONTEXT.md"
echo "   3. Ton prompt d'adaptation (CLONE_PROMPT.md)"
echo "════════════════════════════════════════════"
