# 🎬 Video Cloner — Prompt à utiliser avec Claude

Copie-colle ce prompt en remplaçant les sections entre [crochets] :

---

**Analyse cette vidéo et recrée-la fidèlement avec Remotion, adaptée à mon projet.**

Le projet Remotion est prêt dans `~/Downloads/Remotion-Templates/video-cloner/`.
Il contient déjà tous les packages nécessaires :
- `remotion` core (interpolate, spring, useCurrentFrame, useVideoConfig)
- `@remotion/three` + `@react-three/fiber` + `@react-three/drei` (3D)
- `@remotion/transitions` (fade, slide, wipe, flip, clockWipe)
- `@remotion/motion-blur` (flou de mouvement)
- `@remotion/noise` (animations organiques flottantes)
- `@remotion/animation-utils` (makeTransform, CSS 3D)
- `@remotion/google-fonts` (polices)
- `@remotion/lottie` (animations After Effects)
- `@remotion/media-utils` (audio data, visualisation)
- `@remotion/captions` (sous-titres)
- `@remotion/shapes` + `@remotion/paths` (formes SVG)

**Extrais et reproduis :**
- La structure narrative complète (toutes les scènes, timings en frames à 30fps)
- Chaque effet visuel (transitions, spring animations, motion blur, glow, blur, 3D, particules)
- La typographie exacte (police, taille, poids, couleurs, animations lettres/mots)
- La palette de couleurs et fonds (dégradés, couleurs hex exactes)
- Le rythme de montage (durée de chaque scène, style de cut)
- Les composants UI (notifications, cartes, mockups, icônes)

**Adapte le contenu à mon projet :**
- Mon projet : [DESCRIPTION — ex: "Application SaaS de gestion RH pour entreprises africaines"]
- Mon logo : [CHEMIN ou "pas encore disponible"]
- Mes couleurs de marque : [HEX — ex: "#1a1a2e, #6c63ff, #ffffff"]
- Ma police : [ex: "Inter" ou "à choisir selon le style"]
- Mes textes à intégrer :
  - Titre : [ex: "Gérez vos RH simplement"]
  - Accroche : [ex: "Paie, congés, documents — tout en un"]
  - Features : [liste]
  - CTA : [ex: "Essai gratuit 14 jours"]
- Assets à utiliser : [dossier ou liste de fichiers dans public/images/]

**Livre :**
1. `src/Root.tsx` — composition principale enregistrée
2. `src/scenes/Scene01.tsx`, `Scene02.tsx`... — une scène par fichier
3. `src/components/` — composants réutilisables (NotificationCard, AppIcon, etc.)
4. `public/` — liste des assets à placer (images, audio, 3D)
5. Instructions pour `npm run dev` et `npm run render`

---

## Structure du projet

```
video-cloner/
├── src/
│   ├── Root.tsx              ← enregistrement compositions
│   ├── scenes/               ← une scène = un fichier
│   ├── components/           ← UI réutilisable
│   ├── hooks/                ← hooks custom
│   └── assets/               ← constantes (couleurs, textes)
├── public/
│   ├── images/               ← logos, icônes, screenshots
│   ├── audio/                ← musique, SFX
│   ├── 3d/                   ← fichiers GLB/GLTF
│   └── fonts/                ← polices custom
└── package.json              ← tous les packages déjà installés
```
