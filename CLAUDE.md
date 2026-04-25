# Video Cloner — Remotion Project

## Mission
Reproduire fidèlement n'importe quelle vidéo avec Remotion et l'adapter au projet de l'utilisateur.

## Setup OBLIGATOIRE (première fois ou environnement Codex/CI)
```bash
npm run setup   # installe ffmpeg + yt-dlp + npm install
```

## Analyser et reproduire une vidéo

### Si l'utilisateur donne une URL (TikTok, YouTube, Instagram, MP4 direct) :
```bash
npm run analyze -- https://url-de-la-video
```

### Si l'utilisateur donne un fichier local :
```bash
npm run analyze -- /chemin/vers/video.mp4
```

Le script génère :
- Les frames dans `/tmp/video-frames/<timestamp>/frame_*.jpg`
- Un rapport `VIDEO_CONTEXT.md` avec toutes les métadonnées

### Après l'analyse — générer le code :
Lis chaque frame et génère le projet Remotion complet. Voir les détails ci-dessous.

## Commandes
```bash
npm run setup    # Setup environnement complet
npm run analyze  # Analyser une vidéo (passer l'URL/chemin en argument)
npm run dev      # Remotion Studio → localhost:3000
npm run render   # Rendre en MP4
npm run build    # Bundle production
```

## Packages installés (26 total)

### Core Remotion (v4.0.451)
- `remotion` — useCurrentFrame, useVideoConfig, interpolate, spring, Sequence, Series, AbsoluteFill, Audio, Img, OffthreadVideo, staticFile
- `@remotion/transitions` — TransitionSeries, fade, slide, wipe, flip, clockWipe
- `@remotion/motion-blur` — CameraMotionBlur
- `@remotion/noise` — noise() pour animations organiques
- `@remotion/animation-utils` — makeTransform, translateX/Y, scale, rotate
- `@remotion/google-fonts` — chargement Google Fonts
- `@remotion/lottie` — animations Lottie After Effects
- `@remotion/rive` — animations Rive
- `@remotion/media-utils` — useAudioData, visualizeAudio
- `@remotion/captions` — sous-titres
- `@remotion/shapes` + `@remotion/paths` — formes SVG, morphing
- `@remotion/zod-types` — input props typées

### 3D & PostProcessing
- `@remotion/three` — ThreeCanvas
- `@react-three/fiber` — React Three Fiber
- `@react-three/drei` — useGLTF, Float, Environment, Text3D, Html
- `@react-three/postprocessing` — EffectComposer, Bloom, ChromaticAberration, DepthOfField
- `@react-spring/three` — spring physics 3D
- `postprocessing` — effets WebGL bas niveau
- `maath` — math utils Three.js
- `three` — Three.js core

### Animation & Assets
- `gsap` 3.15 — timelines complexes synchronisées avec useCurrentFrame
- `simple-icons` 16.17 — 3000+ icônes de marques (siNotion, siGoogle, siSlack...)

## Assets disponibles dans public/

```
public/
├── 3d/
│   ├── iphone.glb        ← mockup iPhone 3D
│   ├── laptop.glb        ← mockup MacBook 3D
│   └── box.glb           ← container 3D
├── audio/
│   ├── sfx/
│   │   ├── whoosh.mp3
│   │   ├── notification.mp3
│   │   └── click.mp3
│   └── music/
│       ├── ambient.mp3
│       └── upbeat.mp3
├── images/
│   ├── icons/            ← SVGs: google-drive, google-docs, microsoft-word,
│   │                        microsoft-excel, microsoft-teams, instagram,
│   │                        tiktok, slack, notion, figma, github, vercel
│   ├── mockups/          ← screenshots/logos de l'utilisateur (à placer ici)
│   └── logos/            ← logo de l'utilisateur (à placer ici)
├── lottie/
│   ├── loading.json
│   ├── success.json
│   └── confetti.json
└── fonts/
    ├── Inter-Regular.woff2
    ├── Inter-Bold.woff2
    └── Inter-Light.woff2
```

## Structure de code attendue

```
src/
├── Root.tsx                  ← registerRoot() + <Composition>
├── index.ts                  ← import Root
├── scenes/
│   ├── Scene01.tsx           ← une scène = un fichier
│   ├── Scene02.tsx
│   └── ...
├── components/
│   ├── GradientBackground.tsx
│   ├── AnimatedText.tsx
│   ├── NotificationCard.tsx
│   ├── AppIconGrid.tsx
│   └── ...
├── hooks/
│   └── useGsapTimeline.ts
└── assets/
    └── constants.ts          ← COLORS, TEXTS, TIMINGS, FONTS centralisés
```

## Patterns essentiels

### Spring d'entrée standard
```tsx
import { spring, useCurrentFrame, useVideoConfig, interpolate } from 'remotion'
const frame = useCurrentFrame()
const { fps } = useVideoConfig()
const enter = spring({ frame, fps, config: { stiffness: 100, damping: 20 } })
const opacity = interpolate(enter, [0, 1], [0, 1], { extrapolateRight: 'clamp' })
const y = interpolate(enter, [0, 1], [40, 0], { extrapolateRight: 'clamp' })
```

### Fond dégradé animé
```tsx
<AbsoluteFill style={{
  background: 'linear-gradient(135deg, #e8f4ff 0%, #f0e8ff 50%, #fff5e8 100%)'
}} />
```

### Bloom / Glow (Three.js)
```tsx
import { EffectComposer, Bloom } from '@react-three/postprocessing'
<EffectComposer>
  <Bloom luminanceThreshold={0.1} intensity={2.0} mipmapBlur />
</EffectComposer>
```

### Icônes flottantes (Perlin noise)
```tsx
import { noise } from '@remotion/noise'
const x = noise('float-x-' + id, frame / 80, 0) * 15
const y = noise('float-y-' + id, 0, frame / 80) * 15
```

### Notification card en cascade
```tsx
const delay = index * 18
const f = Math.max(0, frame - delay)
const enter = spring({ frame: f, fps, config: { stiffness: 120, damping: 18 } })
const translateY = interpolate(enter, [0, 1], [60, 0], { extrapolateRight: 'clamp' })
const opacity = interpolate(enter, [0, 1], [0, 1], { extrapolateRight: 'clamp' })
```

### Icône de marque Simple Icons
```tsx
import { siNotion } from 'simple-icons'
<svg viewBox="0 0 24 24" style={{ width: 32, height: 32 }}
  fill={`#${siNotion.hex}`}
  dangerouslySetInnerHTML={{ __html: siNotion.svg }}
/>
```

### GSAP synchronisé avec Remotion
```tsx
import gsap from 'gsap'
import { useRef, useEffect } from 'react'
const ref = useRef<HTMLDivElement>(null)
useEffect(() => {
  if (!ref.current) return
  const tl = gsap.timeline({ paused: true })
  tl.fromTo(ref.current, { scale: 0.5, opacity: 0 }, { scale: 1, opacity: 1, duration: 0.5 })
  tl.seek(frame / fps)
}, [frame, fps])
```

### Transition entre scènes
```tsx
import { TransitionSeries, linearTiming } from '@remotion/transitions'
import { fade } from '@remotion/transitions/fade'
<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={90}>
    <Scene01 />
  </TransitionSeries.Sequence>
  <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: 15 })} />
  <TransitionSeries.Sequence durationInFrames={90}>
    <Scene02 />
  </TransitionSeries.Sequence>
</TransitionSeries>
```

## Règles absolues
1. **`extrapolateLeft: 'clamp', extrapolateRight: 'clamp'`** sur TOUTES les interpolations
2. **`staticFile()`** pour TOUT asset dans public/
3. **`<OffthreadVideo>`** jamais `<Video>`
4. **Frames = secondes × fps** — tout en frames
5. **Une scène = un fichier** dans src/scenes/
6. **Centraliser** couleurs/textes/timings dans src/assets/constants.ts
7. **Livrer un projet complet** prêt pour `npm run dev` sans modification manuelle
8. **TypeScript strict** — pas de `any`

## Informations projet (à mettre à jour par l'utilisateur)
- **GitHub :** https://github.com/mouhamadtoure/remotion-video-cloner
- **Source Remotion :** `~/Downloads/Dossier Remotion/` (monorepo v4.0.451)
- **22 templates :** `~/Downloads/Remotion-Templates/`

## Ce que l'utilisateur doit fournir
- Son logo → `public/images/logos/logo.png`
- Screenshots de son app → `public/images/mockups/`
- Ses couleurs de marque (hex) → à mettre dans `src/assets/constants.ts`
- Ses textes (titre, accroche, features, CTA)
- La vidéo à reproduire (URL ou fichier local)
