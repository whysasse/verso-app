# Verso — App Store Connect Listing, fr-CA & pt-BR Draft (FAB-275 step 8)

**Version:** 1.0 | **Date:** 2026-08-25 | **Status:** Draft

**Status:** Draft translation for Fabio's review — nothing here is submitted. Translates the subtitle/description/keywords/promotional text from [APP_STORE_LISTING.md](APP_STORE_LISTING.md) into fr-CA and pt-BR. Register follows the decisions already locked in `docs/copy/UI_COPY_LINGUISTIC_REVIEW_fr-CA.md` and `_pt-BR.md` (tutoiement + no anglicisms/France-specific phrasing for fr-CA; natural, colloquial `você` register for pt-BR), but **this document itself has not been through that same linguistic-review pass** — it's new text, not translated `UI_COPY.md` strings, so treat it with the same scrutiny before it ships. All English source text is pulled as-is from `APP_STORE_LISTING.md` per Fabio's confirmation it's ready to translate; note that doc's own subtitle field still listed 3 untranslated options as of this writing — **Fabio picked #2 ("Your articles, saved as files") during this session**, so that's the one translated below.

**Invariant terms kept as-is in both locales** (per `docs/LOCALIZATION.md` §4): `Verso` · `Obsidian` · `iCloud Drive` · `Markdown` · `Safari` · `GitHub` · `OpenDyslexic` · `New York` · `San Francisco` · `Georgia` (font names) · `Chrome` · `Pocket` · `Instapaper` · `GoodLinks` (product names) · `YAML`. Theme *labels* are translated (Papier/Sépia/Nuit/Encre — Papel/Sépia/Noite/Tinta), matching `docs/LOCALIZATION.md` §5.

**App name field:** the ASC record is registered as `Version Reader` (English) because `Verso` was already taken — see `APP_STORE_LISTING.md`. Kept as `Version Reader` in both locales below rather than translating a registered product name. ASC does let you set a different localized "Name" per language if you'd rather have a French/Portuguese storefront name instead — that's a call for Fabio, not assumed here.

---

## fr-CA (Québec French)

### Subtitle (30 characters max)

```
Tes articles, tes fichiers
```
(26 characters. Mirrors the ownership angle of the chosen EN option — "your articles, your files.")

### Description (4000 characters max)

```
Verso est un lecteur d'articles minimaliste, conçu pour les gens qui veulent posséder leur lecture, et non la louer d'une appli.

Enregistre des articles depuis Safari, Chrome ou n'importe quelle appli, d'un seul partage — Verso retire les publicités et le fouillis, puis enregistre chacun comme un simple fichier Markdown dans un dossier que tu choisis sur ton iCloud Drive. Aucune base de données propriétaire. Aucun compte. Aucune dépendance. Tes articles ne sont que des fichiers, toujours lisibles dans n'importe quel éditeur de texte, et synchronisés entre tes appareils via ton propre iCloud.

Si tu utilises Obsidian, pointe-le vers le même dossier et tes articles enregistrés apparaissent automatiquement comme des notes — étiquettes, statut de lecture et position de défilement vivent tous dans le YAML du fichier, entièrement compatible avec ton coffre.

UNE EXPÉRIENCE DE LECTURE CALME, COMME UN LIVRE
• Quatre thèmes : Papier, Sépia, Nuit et Encre
• Choisis New York, Georgia, San Francisco ou OpenDyslexic
• Le mode immersif cache l'interface pendant que tu lis — touche l'écran pour la faire réapparaître
• Progression de lecture suivie automatiquement : Non lu → En cours → Lu
• Filtre et cherche dans ta bibliothèque en quelques secondes

APPORTE TA BIBLIOTHÈQUE EXISTANTE
• Importe depuis Pocket, Instapaper ou GoodLinks — tes articles enregistrés deviennent instantanément des fichiers Markdown, prêts à lire ou à déposer directement dans Obsidian

CONÇU POUR RESPECTER TES DONNÉES
• Fonctionne entièrement hors ligne une fois les articles enregistrés
• Aucune publicité, aucun suivi par défaut
• Statistiques d'utilisation optionnelles et entièrement anonymes, désactivables en tout temps dans les Réglages — rien de personnel ou d'identifiable n'est jamais recueilli

Verso est un projet open source. Consulte le code ou signale un problème à github.com/whysasse/verso-app.
```

### Keywords (100 characters max, comma-separated)

```
lire plus tard,markdown,obsidian,icloud,liste de lecture,pocket,instapaper,goodlinks,enregistrer
```
(96 characters. "read later" / "reading list" / "save" translated as real Québécois French search terms — `lire plus tard`, `liste de lecture`, `enregistrer` — since App Store search indexing is per-locale; product/brand names stay invariant.)

### Promotional text (170 characters max)

```
Enregistre tes articles en fichiers Markdown, dans ton propre iCloud Drive. Fonctionne seul, ou pointe Obsidian vers le même dossier pour les voir comme notes.
```
(159 characters)

---

## pt-BR (Brazilian Portuguese)

### Subtitle (30 characters max)

```
Seus artigos, seus arquivos
```
(27 characters. Same ownership mirroring as fr-CA — "your articles, your files.")

### Description (4000 characters max)

```
O Verso é um leitor de artigos minimalista, feito para quem quer ser dono da própria leitura, não alugá-la de um app.

Salve artigos do Safari, do Chrome ou de qualquer app com um único compartilhamento — o Verso remove anúncios e distrações, e salva cada um como um arquivo Markdown simples numa pasta que você escolhe no seu iCloud Drive. Sem banco de dados proprietário. Sem conta. Sem dependência de um app. Seus artigos são só arquivos, sempre legíveis em qualquer editor de texto, e sincronizados entre seus aparelhos pelo seu próprio iCloud.

Se você usa o Obsidian, aponte-o para a mesma pasta e seus artigos salvos aparecem automaticamente como notas — etiquetas, status de leitura e posição de rolagem ficam todos no YAML do arquivo, totalmente compatível com o seu vault.

UMA EXPERIÊNCIA DE LEITURA CALMA, COMO UM LIVRO
• Quatro temas: Papel, Sépia, Noite e Tinta
• Escolha New York, Georgia, San Francisco ou OpenDyslexic
• O modo imersivo esconde a interface enquanto você lê — toque na tela para trazê-la de volta
• Progresso de leitura registrado automaticamente: Não lido → Lendo → Lido
• Filtre e pesquise sua biblioteca em segundos

TRAGA SUA BIBLIOTECA ATUAL
• Importe do Pocket, Instapaper ou GoodLinks — seus artigos salvos viram arquivos Markdown na hora, prontos para ler ou soltar direto no Obsidian

FEITO PARA RESPEITAR SEUS DADOS
• Funciona totalmente sem conexão depois que os artigos são salvos
• Sem anúncios, sem rastreamento por padrão
• Estatísticas de uso opcionais e totalmente anônimas, que você pode desativar quando quiser em Configurações — nada pessoal ou identificável é coletado

O Verso é um projeto de código aberto. Veja o código ou registre um problema em github.com/whysasse/verso-app.
```

### Keywords (100 characters max, comma-separated)

```
ler depois,markdown,obsidian,icloud,lista de leitura,pocket,instapaper,goodlinks,salvar artigos
```
(95 characters)

### Promotional text (170 characters max)

```
Salve seus artigos como arquivos Markdown no seu próprio iCloud Drive. Funciona sozinho, ou aponte o Obsidian para a mesma pasta e eles aparecem como notas.
```
(156 characters)

---

## Register notes applied

**fr-CA:** Tutoiement throughout (`tes`/`ton`/`ta`), matching Fabio's locked decision in `UI_COPY_LINGUISTIC_REVIEW_fr-CA.md`. No anglicisms — `hors ligne` not "off-line," `appli` not "app," `enregistrer` not a borrowed verb. `open source` kept as the accepted loanword, matching the existing `about.acknowledgements.rowLabel` shipped copy rather than translating it to "code source ouvert." No France-specific phrasing (no `télécharger` for save/upload, no metropolitan idioms).

**pt-BR:** Natural, colloquial `você` register, matching the calibration in `UI_COPY_LINGUISTIC_REVIEW_pt-BR.md`'s approved corrections (e.g. "vai guardar" over "deve guardar," "ficam"/"continuam" over the more literary "permanecem"). Avoided the anglicisms the review explicitly flagged — no "off-line" (used "sem conexão" instead, per Fabio's explicit request in that doc), no "paywall." `vault` and `app` kept in English per the review's confirmation that the Brazilian Obsidian community uses `vault` untranslated; `app` likewise is standard colloquial Brazilian Portuguese, not treated as an anglicism to avoid.

## Open items

- [ ] Fabio review/edit both translations — this doc has not been through a linguistic-review pass the way `UI_COPY.md` was (see `docs/copy/UI_COPY_LINGUISTIC_REVIEW_fr-CA.md` / `_pt-BR.md`, still awaiting his sign-off themselves per FAB-275 step 7).
- [ ] Confirm subtitle option #2 is still the one Fabio wants — picked during this session; the base `APP_STORE_LISTING.md` doc still needs its own subtitle checkbox resolved.
- [ ] Decide whether the ASC "Name" field should also be localized per-storefront, or stay `Version Reader` everywhere.
- [ ] **Québec Bill 96 compliance posture — not addressed here.** Whether shipping a French Québec storefront listing triggers any additional French-language requirement under Bill 96 for app distribution needs Fabio's (or a lawyer's) call before this is submitted. Tracked as open in `docs/BACKLOG.md` FAB-275 step 8.
