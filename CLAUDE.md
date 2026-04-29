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

### Si l'utilisateur donne un fichier local → le rendre accessible via URL :
```bash
npm run share -- /chemin/vers/video.mp4
# → génère une URL publique temporaire (14 jours) → utilise cette URL pour analyser
npm run analyze -- https://url-generee-par-share
```

Le script génère :
- Les frames dans `/tmp/video-frames/<timestamp>/frame_*.jpg`
- Un rapport `VIDEO_CONTEXT.md` avec toutes les métadonnées

### Après l'analyse — générer le code :
Lis chaque frame et génère le projet Remotion complet. Voir les détails ci-dessous.

## Commandes
```bash
npm run setup          # Setup environnement complet (ffmpeg + yt-dlp + npm install)
npm run share          # Uploader vidéo locale → URL publique (pour Codex)
npm run analyze        # Analyser une vidéo URL ou locale → frames + rapport
npm run dev            # Remotion Studio → localhost:3000
npm run render         # Rendre en MP4 → out/video.mp4
npm run preview        # Rendre + uploader + donner URL de visualisation
npm run open-preview   # Ouvrir preview.html (après npm run render)
npm run build          # Bundle production
```

## Visualiser la vidéo rendue

### Option 1 — Local (Claude Code / Cursor)
```bash
npm run dev          # Remotion Studio live → localhost:3000
npm run render       # Génère out/video.mp4
npm run open-preview # Ouvre preview.html dans le navigateur
```

### Option 2 — URL partageable (Codex / partage)
```bash
npm run preview      # Rend + uploade → donne URL publique valable 14 jours
```

### Option 3 — En ligne permanent (GitHub Pages)
Chaque push sur main déclenche automatiquement le rendu et le déploiement.
URL de visualisation : https://mouhamadtoure.github.io/remotion-video-cloner/

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

---

## Skills IA disponibles

### NotebookLM Research Assistant
Interroger les notebooks Google NotebookLM avec réponses sourcées et citées par Gemini. Zéro hallucination — réponses exclusivement depuis les documents uploadés.

**Déclencher sur :** mention de NotebookLM, URL `notebooklm.google.com/...`, "ask my NotebookLM", "check my docs", "query my notebook"

**Skill path :** `~/.claude/skills/notebooklm/` — TOUJOURS via `python scripts/run.py [script]`

```bash
# Workflow complet
cd ~/.claude/skills/notebooklm

# 1. Vérifier auth
python scripts/run.py auth_manager.py status

# 2. Auth (une seule fois — ouvre Chrome pour login Google)
python scripts/run.py auth_manager.py setup

# 3. Lister les notebooks
python scripts/run.py notebook_manager.py list

# 4. Ajouter un notebook
python scripts/run.py notebook_manager.py add --url "https://notebooklm.google.com/notebook/..." --name "Nom" --description "Contenu" --topics "topic1,topic2"

# 5. Poser une question
python scripts/run.py ask_question.py --question "ta question"
python scripts/run.py ask_question.py --question "..." --notebook-id [ID]
python scripts/run.py ask_question.py --question "..." --notebook-url "https://..."
```

Chaque réponse NotebookLM se termine par "Is that ALL you need to know?" → analyser les gaps → poser des follow-ups → synthétiser avant de répondre.

Limites : 50 requêtes/jour (compte gratuit) · chaque question = nouveau browser · upload manuel requis



### HyperFrames
Compositions vidéo HTML avec GSAP. Déclencher sur : title cards, overlays, captions, voiceovers, visuels audio-réactifs, transitions entre scènes, tout contenu vidéo HTML.
- Visual Identity Gate : toujours définir DESIGN.md avant d'écrire du HTML
- Layout avant animation (gsap.from pour entrées, gsap.to pour sorties finales uniquement)
- Jamais `Math.random()`, jamais `repeat: -1`, jamais de timelines async
- Enregistrer toujours : `window.__timelines["id"] = tl`
- Commandes : `npx hyperframes lint | validate | inspect | preview | render`

### Agent Browser
Automatisation browser via CDP (Chrome). Déclencher sur : naviguer un site, remplir un formulaire, cliquer un bouton, scraper des données, tester une app web, automatiser des actions browser.
```bash
npm i -g agent-browser && agent-browser install
agent-browser skills get core        # workflows + patterns
agent-browser skills get electron    # apps Electron
agent-browser skills get slack       # automatisation Slack
```

### Marketing Psychology
70+ modèles mentaux psychologiques appliqués au marketing. Déclencher sur : "pourquoi les gens achètent", "biais cognitif", "persuasion", "preuve sociale", "ancrage", "aversion à la perte", "framing", "nudge", "pricing psychology".
- Toujours vérifier `.agents/product-marketing-context.md` si existe
- Identifier le modèle applicable → expliquer la psychologie → application marketing → implémentation éthique

### Impeccable
Design langage expert pour interfaces frontend production-grade. Déclencher sur : designer, redesigner, critiquer, auditer, polir, clarifier, animer une interface.
```bash
node .claude/skills/impeccable/scripts/load-context.mjs  # charger contexte
```
Commandes : `craft` · `shape` · `critique` · `audit` · `polish` · `bolder` · `quieter` · `distill` · `animate` · `colorize` · `typeset` · `layout` · `delight` · `overdrive` · `harden` · `adapt` · `optimize` · `live`
Interdictions absolues : gradient text, glassmorphism décoratif, side-stripe borders, hero-metric template, cards identiques répétées.

### iOS Simulator
22 scripts Python/Bash pour builder, tester et automatiser des apps iOS. Déclencher sur : build Xcode, lancer simulateur, interagir avec l'UI iOS, tester permissions, push notifications, Core Data/SwiftData.
```bash
bash scripts/sim_health_check.sh                              # vérifier env
python scripts/app_launcher.py --launch com.example.app      # lancer app
python scripts/screen_mapper.py                              # mapper l'écran
python scripts/navigator.py --find-text "Login" --tap        # interagir
python scripts/accessibility_audit.py                        # audit a11y
```
Toujours préférer l'accessibility tree (10-50 tokens) aux screenshots (1600-6300 tokens).

---

## LLM Council — Système de Conseil Multi-Perspectif

Système basé sur la méthodologie Karpathy : 5 conseillers indépendants analysent une question, se font une revue croisée anonyme, et un chairman synthétise le verdict final.

### Déclencheurs obligatoires
`council this` · `run the council` · `war room this` · `pressure-test this` · `stress-test this` · `debate this`

### Déclencheurs forts (si vrai choix avec enjeux)
`should I X or Y` · `which option` · `what would you do` · `is this the right move` · `I can't decide` · `I'm torn between`

### Les 5 Conseillers

| Conseiller | Rôle |
|---|---|
| **The Contrarian** | Cherche le défaut fatal, ce qui va rater, les risques cachés |
| **The First Principles Thinker** | Déconstruit les hypothèses, repart de zéro, questionne la vraie problématique |
| **The Expansionist** | Cherche l'upside ignoré, l'opportunité adjacente, ce qui est sous-valorisé |
| **The Outsider** | Zéro contexte — voit ce que les experts ne voient plus (malédiction de la connaissance) |
| **The Executor** | Seule question : est-ce faisable et quelle est la première action concrète ? |

### Processus (4 étapes)

1. **Cadrer** — Reformuler la question brute avec le contexte clé et les enjeux
2. **5 conseillers en parallèle** — Chacun répond indépendamment (150-300 mots), angle poussé à fond
3. **Revue par les pairs en parallèle** — Réponses anonymisées A-E, chaque conseiller évalue les 5 : meilleure réponse + angle mort + ce que tous ont raté
4. **Synthèse du Chairman** — Reçoit tout, produit le verdict : accords · désaccords · angles morts · recommandation · 1 action concrète

### Output
- `council-report-[timestamp].html` — rapport visuel propre, sections collapsibles
- `council-transcript-[timestamp].md` — transcript complet pour référence

### Règles
- Spawner les 5 conseillers EN PARALLÈLE (jamais séquentiellement)
- Anonymiser TOUJOURS pour la revue croisée
- Le chairman peut s'opposer à la majorité si le raisonnement le justifie
- Ne pas déclencher pour des questions factuelles ou des tâches de création simples

*Méthodologie Andrej Karpathy · Adaptation @olelehmann · Publié @tenfoldmarc*
