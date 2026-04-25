# Video Cloner — Remotion Project

## Rôle
Tu es un expert Remotion. Ce projet est conçu pour reproduire fidèlement n'importe quelle vidéo et l'adapter au projet de l'utilisateur.

## Projet local
- **Chemin :** `~/Downloads/Remotion-Templates/video-cloner/`
- **GitHub :** https://github.com/mouhamadtoure/remotion-video-cloner
- **Source Remotion :** `~/Downloads/Dossier Remotion/` (monorepo v4.0.451)
- **22 templates :** `~/Downloads/Remotion-Templates/`

## Commandes
```bash
npm run dev      # Remotion Studio → localhost:3000
npm run render   # Rendu MP4
npm run build    # Bundle production
```

## Packages installés (26 total)

### Core Remotion (tous en 4.0.451)
`remotion`, `@remotion/cli`, `@remotion/transitions`, `@remotion/motion-blur`,
`@remotion/noise`, `@remotion/animation-utils`, `@remotion/google-fonts`,
`@remotion/lottie`, `@remotion/rive`, `@remotion/media-utils`, `@remotion/media`,
`@remotion/captions`, `@remotion/shapes`, `@remotion/paths`, `@remotion/zod-types`

### 3D & PostProcessing
`@remotion/three`, `@react-three/fiber`, `@react-three/drei`, `three`,
`@react-three/postprocessing`, `postprocessing`, `@react-spring/three`, `maath`

### Animation & Assets
`gsap` (3.15), `simple-icons` (16.17 — 3000+ logos SVG)

## Assets disponibles dans public/

```
public/
├── 3d/
│   ├── iphone.glb        ← mockup iPhone 3D
│   ├── laptop.glb        ← mockup MacBook 3D
│   └── box.glb           ← container 3D
├── audio/
│   ├── sfx/whoosh.mp3, notification.mp3, click.mp3
│   └── music/ambient.mp3, upbeat.mp3
├── images/
│   └── icons/            ← SVGs: google-drive, google-docs, microsoft-word,
│                            microsoft-excel, microsoft-teams, instagram,
│                            tiktok, slack, notion, figma, github, vercel
├── lottie/
│   ├── loading.json, success.json, confetti.json
└── fonts/
    └── Inter-Regular/Bold/Light.woff2
```

## Workflow — Reproduire une vidéo

### Étape 1 — Analyser la vidéo
```bash
ffmpeg -i "video.mp4" -vf "fps=2,scale=800:-1" -frames:v 20 /tmp/frame_%02d.jpg
```
Lire chaque frame et extraire : scènes, timings, effets, couleurs hex, typographie, assets.

### Étape 2 — Structure du code
```
src/
├── Root.tsx              ← composition principale
├── scenes/Scene01.tsx… ← une scène par fichier
├── components/           ← UI réutilisable
├── hooks/                ← hooks custom
└── assets/constants.ts  ← couleurs, textes, timings
```

### Étape 3 — Patterns essentiels

**Fond dégradé pastel animé**
```tsx
<AbsoluteFill style={{
  background: 'linear-gradient(135deg, #e8f4ff 0%, #f0e8ff 100%)'
}} />
```

**Spring animation (entrée d'élément)**
```tsx
import { spring, useCurrentFrame, useVideoConfig } from 'remotion';
const frame = useCurrentFrame();
const { fps } = useVideoConfig();
const enter = spring({ frame, fps, config: { stiffness: 100, damping: 20 } });
```

**Bloom/Glow (Three.js)**
```tsx
import { EffectComposer, Bloom } from '@react-three/postprocessing';
<EffectComposer>
  <Bloom luminanceThreshold={0.2} intensity={1.5} mipmapBlur />
</EffectComposer>
```

**Icônes flottantes (bruit de Perlin)**
```tsx
import { noise } from '@remotion/noise';
const x = noise('x-' + i, frame / 60, 0) * 20;
const y = noise('y-' + i, 0, frame / 60) * 20;
```

**Notification card (slide depuis le bas)**
```tsx
const enter = spring({ frame: frame - delay, fps, config: { stiffness: 120 } });
const translateY = interpolate(enter, [0, 1], [60, 0]);
const opacity = interpolate(enter, [0, 1], [0, 1]);
```

**GSAP synchronisé avec Remotion**
```tsx
import gsap from 'gsap';
useEffect(() => {
  const tl = gsap.timeline({ paused: true });
  tl.to(ref.current, { x: 200, duration: 2 });
  tl.seek(frame / fps);
}, [frame]);
```

**Icône de marque (simple-icons)**
```tsx
import { siNotion } from 'simple-icons';
<svg viewBox="0 0 24 24" fill={`#${siNotion.hex}`}
  dangerouslySetInnerHTML={{ __html: siNotion.svg }} />
```

**Transitions entre scènes**
```tsx
import { TransitionSeries, linearTiming } from '@remotion/transitions';
import { fade } from '@remotion/transitions/fade';
import { slide } from '@remotion/transitions/slide';
```

**Motion blur**
```tsx
import { CameraMotionBlur } from '@remotion/motion-blur';
<CameraMotionBlur shutterAngle={180}>
  <MyScene />
</CameraMotionBlur>
```

## Règles absolues
1. **Travailler dans ce projet** (`video-cloner/`) sauf instruction contraire
2. **Une scène = un fichier** dans `src/scenes/`
3. **`extrapolateLeft/Right: 'clamp'`** sur toutes les interpolations
4. **`staticFile()`** pour tout asset dans `public/`
5. **`<OffthreadVideo>`** jamais `<Video>`
6. **Frames = secondes × fps** — tout en frames
7. **Livrer un projet complet** prêt pour `npm run dev`

## Ce que l'utilisateur doit toujours fournir
- Son logo (`public/images/logo.png`)
- Screenshots de son app (`public/images/mockups/`)
- Ses couleurs de marque (hex)
- Ses textes (titre, accroche, features, CTA)
- La vidéo à reproduire

## Prompt à utiliser pour reproduire une vidéo
Voir `CLONE_PROMPT.md` dans ce dossier — prompt complet à remplir et exécuter.
