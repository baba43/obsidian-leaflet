# Build & Deploy für unseren obsidian-leaflet Fork.
# Zielordner (OUTDIR = Plugin-Verzeichnis im Vault) kommt aus .env (siehe .env.example).
#
# Wichtig: Es werden nur Build-Artefakte geschrieben (main.js, styles.css,
# manifest.json) — die data.json (Marker-Typen/Farben im Vault) wird NIE angefasst.

-include .env
export

PLUGIN_FILES := main.js styles.css manifest.json

.PHONY: help install build deploy dev clean guard copy

help:
	@echo "make deploy   - Production-Build + in den Vault kopieren  (Standard)"
	@echo "make dev      - Dev-Build im Watch-Modus, schreibt direkt in den Vault"
	@echo "                (Hot-Reload lädt automatisch). Läuft bis Ctrl+C."
	@echo "make build    - nur Production bauen (ohne Kopieren)"
	@echo "make install  - npm-Abhängigkeiten installieren"
	@echo "make clean    - Build-Artefakte löschen"

# node_modules nur installieren, wenn nötig.
node_modules: package.json
	npm install
	@touch node_modules

install: node_modules

build: node_modules
	npm run build

# Production: bauen (Output ins Repo-Root) + in den Vault kopieren. Standard-Befehl.
deploy: guard node_modules
	npm run build
	@$(MAKE) --no-print-directory copy

# Dev: webpack im Watch-Modus. Schreibt main.js/styles.css/manifest.json DIREKT
# nach $(OUTDIR) (webpack.config.js: isDevMode -> output = OUTDIR) und rebuildet
# bei jeder Änderung. Läuft im Vordergrund bis Ctrl+C; Hot-Reload lädt neu.
dev: guard node_modules
	npm run dev

copy:
	cp $(PLUGIN_FILES) "$(OUTDIR)/"
	@echo "✓ Build kopiert nach $(OUTDIR)"

clean:
	rm -f main.js styles.css *.js.map

# Sicherstellen, dass das Ziel konfiguriert ist und existiert.
guard:
	@test -n "$(OUTDIR)" || { echo "FEHLER: OUTDIR nicht gesetzt — .env.example nach .env kopieren."; exit 1; }
	@test -d "$(OUTDIR)" || { echo "FEHLER: Zielordner existiert nicht: $(OUTDIR)"; exit 1; }
