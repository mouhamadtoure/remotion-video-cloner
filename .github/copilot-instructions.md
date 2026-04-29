# GitHub Copilot Instructions

## NotebookLM Research Assistant

Quand l'utilisateur mentionne NotebookLM, partage une URL `notebooklm.google.com/...`, ou dit "ask my NotebookLM" / "check my docs" / "query my notebook" :

**Skill path :** `~/.claude/skills/notebooklm/`
**Règle absolue :** TOUJOURS utiliser `python scripts/run.py [script]` — jamais les scripts directement.

### Workflow
```bash
cd ~/.claude/skills/notebooklm

# Vérifier l'auth
python scripts/run.py auth_manager.py status

# Auth initiale (ouvre Chrome → login Google)
python scripts/run.py auth_manager.py setup

# Lister les notebooks
python scripts/run.py notebook_manager.py list

# Poser une question (notebook actif)
python scripts/run.py ask_question.py --question "ta question"

# Notebook spécifique
python scripts/run.py ask_question.py --question "..." --notebook-id [ID]
python scripts/run.py ask_question.py --question "..." --notebook-url "https://notebooklm.google.com/notebook/..."

# Ajouter un notebook
python scripts/run.py notebook_manager.py add --url "[URL]" --name "[nom]" --description "[desc]" --topics "[topics]"
```

### Suivi obligatoire
Chaque réponse NotebookLM finit par "Is that ALL you need to know?" → identifier les gaps → poser des follow-ups → synthétiser.

### Limites
- 50 requêtes/jour (compte gratuit Google)
- Chaque question = nouveau browser (quelques secondes)
- Upload manuel requis dans NotebookLM

---

## HyperFrames
Compositions vidéo HTML + GSAP. Déclencher sur : title cards, overlays, captions, transitions vidéo.
Commandes : `npx hyperframes lint | validate | inspect | preview | render`

## Agent Browser
Automatisation Chrome via CDP. `npm i -g agent-browser && agent-browser skills get core`

## Impeccable
Design UI expert. Setup : `node .claude/skills/impeccable/scripts/load-context.mjs`
Commandes : craft · shape · critique · audit · polish · bolder · animate · colorize

## iOS Simulator
22 scripts pour builder/tester des apps iOS.
```bash
bash ~/.claude/skills/ios-simulator/scripts/sim_health_check.sh
python ~/.claude/skills/ios-simulator/scripts/screen_mapper.py
```

## LLM Council
Déclencher sur : "council this", "war room this", "pressure-test this", "should I X or Y", "I can't decide"
5 conseillers → revue croisée anonyme → verdict Chairman.

## Marketing Psychology
70+ modèles mentaux marketing. Déclencher sur : biais cognitifs, persuasion, pricing psychology, pourquoi les gens achètent.
