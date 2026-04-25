#!/bin/bash
# ============================================================
# Codex Setup Script — installe tout l'environnement nécessaire
# Lance ce script EN PREMIER dans tout environnement Codex/CI
# Usage : bash scripts/codex-setup.sh
# ============================================================

set -e
echo "🚀 Setup Video Cloner pour Codex..."

# ── 1. Détection OS ──────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"
echo "OS: $OS | Arch: $ARCH"

# ── 2. ffmpeg ────────────────────────────────────────────────
if ! command -v ffmpeg &>/dev/null; then
  echo "📦 Installation ffmpeg..."
  if [ "$OS" = "Linux" ]; then
    apt-get update -qq && apt-get install -y ffmpeg 2>/dev/null || \
    snap install ffmpeg 2>/dev/null || \
    { wget -q https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -O /tmp/ffmpeg.tar.xz
      tar -xf /tmp/ffmpeg.tar.xz -C /tmp/
      cp /tmp/ffmpeg-*-static/ffmpeg /usr/local/bin/
      cp /tmp/ffmpeg-*-static/ffprobe /usr/local/bin/
      chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe; }
  elif [ "$OS" = "Darwin" ]; then
    brew install ffmpeg
  fi
else
  echo "✅ ffmpeg $(ffmpeg -version 2>&1 | head -1 | cut -d' ' -f3)"
fi

# ── 3. yt-dlp ────────────────────────────────────────────────
if ! command -v yt-dlp &>/dev/null; then
  echo "📦 Installation yt-dlp..."
  curl -sL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
  chmod +x /usr/local/bin/yt-dlp
else
  echo "✅ yt-dlp $(yt-dlp --version)"
fi

# ── 4. Node.js dependencies ──────────────────────────────────
echo "📦 npm install..."
npm install --legacy-peer-deps --silent
echo "✅ Dépendances installées"

# ── 5. Dossiers nécessaires ───────────────────────────────────
mkdir -p /tmp/video-frames public/images/mockups public/images/logos
echo "✅ Dossiers créés"

echo ""
echo "✅ Setup terminé ! Prêt à reproduire des vidéos."
echo ""
echo "Utilisation :"
echo "  bash scripts/analyze-video.sh <URL_VIDEO>"
echo "  bash scripts/analyze-video.sh <CHEMIN_LOCAL.mp4>"
