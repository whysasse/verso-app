# Verso — Révision linguistique (fr-CA)

**Locale :** `fr-CA` (Québec French)
**Réviseur :** Claude (révision linguistique automatisée, à valider par un réviseur humain)
**Date :** 2026-06-21
**Statut :** `Révisé — en attente d'approbation finale`

Merci de réviser les traductions de **Verso**, un lecteur d'articles minimaliste pour iOS et Web. L'application utilise un vocabulaire réduit et cohérent — environ 280 chaînes en tout. Ce document vous guide à travers chaque section.

**Instructions :**
- Lisez chaque chaîne anglaise et sa traduction. Si la traduction est naturelle et correcte, cochez `[✓]`. Si quelque chose cloche (mauvais mot, formulation peu naturelle, registre incorrect, accent manquant, problème de formatage), marquez `[✗]` et inscrivez votre correction dans la marge ou à la fin de la section.
- Portez une **attention particulière** aux sections marquées **⚠️ pluriels** — le français traite `0` comme un singulier. Le framework gère cela automatiquement, mais le libellé doit fonctionner à chaque nombre.
- À la fin, remplissez le tableau **Résumé des modifications** avec toutes les corrections proposées.

**Changement de registre demandé pour cette passe :** Fabio a demandé un passage généralisé au **tutoiement** (tu/ton/ta/tes), niveau de langue familier mais standard — sans expressions trop familières, sans anglicismes, sans tournures propres à la France. Le `vous` d'origine (calqué sur le brouillon partagé avec le pt-BR) a donc été retiré partout où il s'adressait à l'utilisateur. Voir le résumé en fin de document pour le raisonnement détaillé sur les choix de terminologie.

---

## 1. Intégration

### OB-1 · Bienvenue

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✗] | `onboarding.welcome.headline` | Your articles. Your files. | *Tes articles. Tes fichiers.* | Registre : `vous` → `tu`. |
| [✗] | `onboarding.welcome.subheadline` | A quiet place to read. No accounts, no algorithms — just Markdown files in your iCloud Drive. | *Un endroit calme pour lire. Aucun compte, aucun algorithme — seulement des fichiers Markdown dans ton iCloud Drive.* | Registre : `votre` → `ton`. `iCloud Drive`, `Markdown` invariants. |
| [✓] | `onboarding.welcome.cta` | Get started | *Commencer* | Infinitif, registre neutre — fonctionne tel quel en tutoiement. |

### OB-2 · Sélecteur de thème

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✗] | `onboarding.theme.headline` | Choose your reading theme | *Choisis ton thème de lecture* | Registre : impératif `Choisissez` → `Choisis`; `votre` → `ton`. |
| [✗] | `onboarding.theme.subheadline` | You can change this any time from settings. | *Tu peux le modifier à tout moment dans les réglages.* | Registre : `Vous pouvez` → `Tu peux`. « Réglages » confirmé — terme exact utilisé par iOS en français. |
| [✓] | `onboarding.theme.continue` | Continue | *Continuer* | Infinitif, registre neutre. |
| [✓] | `theme.paper` | Paper | *Papier* | — |
| [✓] | `theme.sepia` | Sepia | *Sépia* | Accent correct. |
| [✓] | `theme.night` | Night | *Nuit* | — |
| [✓] | `theme.ink` | Ink | *Encre* | — |

### OB-3 · Configuration du dossier

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✗] | `onboarding.folder.headline` | Where should Verso save your articles? | *Où Verso doit-il enregistrer tes articles?* | Registre : `vos` → `tes`. `Verso` invariant. |
| [✗] | `onboarding.folder.subheadline` | Pick a folder in iCloud Drive. Verso saves each article as a Markdown file you can open anywhere. | *Choisis un dossier dans iCloud Drive. Verso enregistre chaque article comme un fichier Markdown que tu peux ouvrir n'importe où.* | Registre : `Choisissez` → `Choisis`, `vous pouvez` → `tu peux`. |
| [✓] | `onboarding.folder.chooseCta` | Choose folder… | *Choisir un dossier…* | Infinitif (bouton), registre neutre. |
| [✓] | `onboarding.folder.continueCta` | Continue | *Continuer* | Infinitif, registre neutre. |
| [✗] | `onboarding.folder.privacyNote` | Verso never uploads your files. They live in your iCloud Drive. | *Verso ne téléverse jamais tes fichiers. Ils restent dans ton iCloud Drive.* | Registre : `vos`/`votre` → `tes`/`ton`. **`téléverse` confirmé** — terme recommandé par l'OQLF pour « upload », pas un anglicisme. |
| [✗] | `onboarding.folder.obsidianTip` | Using Obsidian? Point Verso to a folder inside your vault and articles will appear there automatically. | *Tu utilises Obsidian? Pointe Verso vers un dossier dans ton coffre et les articles y apparaîtront automatiquement.* | Registre : `Vous utilisez`/`Pointez`/`votre` → `Tu utilises`/`Pointe`/`ton`. **`coffre` confirmé** — traduction officielle d'Obsidian pour « vault » dans son interface/documentation francophones. |

### OB-4 · Visite guidée

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `onboarding.tour.headline` | Here's how it works | *Voici comment ça fonctionne* | Pas de marqueur de registre. |
| [✗] | `onboarding.tour.step1` | Share any article from Safari or your browser to save it instantly. | *Partage n'importe quel article depuis Safari ou ton navigateur pour l'enregistrer instantanément.* | Registre : `Partagez`/`votre` → `Partage`/`ton`. `Safari` invariant. |
| [✗] | `onboarding.tour.step2` | Open Verso to read. Your list is always in sync with your files. | *Ouvre Verso pour lire. Ta liste est toujours synchronisée avec tes fichiers.* | Registre : `Ouvrez`/`Votre`/`vos` → `Ouvre`/`Ta`/`tes`. |
| [✗] | `onboarding.tour.step3` | Mark articles as read when you're done. They stay in your folder forever. | *Marque les articles comme lus une fois terminés. Ils restent dans ton dossier pour toujours.* | Registre : `Marquez`/`votre` → `Marque`/`ton`. |
| [✓] | `onboarding.tour.skip` | Skip | *Ignorer* | Infinitif, registre neutre. |
| [✓] | `onboarding.tour.startReading` | Start reading | *Commencer à lire* | Infinitif, registre neutre. |

### OB-5 · Consentement analytique

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✗] | `onboarding.analyticsConsent.headline` | Help make Verso better | *Aide à améliorer Verso* | Registre : impératif `Aidez` → `Aide`. |
| [✗] | `onboarding.analyticsConsent.subheadline` | Share anonymous usage data — no personal info, no article content, ever. | *Partage des données d'utilisation anonymes — aucune information personnelle, aucun contenu d'article, jamais.* | Registre : `Partagez` → `Partage`. |
| [✓] | `onboarding.analyticsConsent.acceptCta` | Sure, why not | *Bien sûr, pourquoi pas* | Ton informel approprié, s'accorde avec le tutoiement. Pas d'anglicisme. |
| [✓] | `onboarding.analyticsConsent.declineCta` | No thanks | *Non merci* | — |

---

## 2. Accueil · Liste d'articles

### Navigation et recherche

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `home.navTitle` | Verso | *Verso* | **Invariant** — nom de marque. |
| [✓] | `home.settings.accessibilityLabel` | Settings | *Réglages* | Terme système iOS — inchangé. |
| [✓] | `home.search.placeholder` | Search titles, text, or site… | *Rechercher titres, texte ou site…* | Placeholder nominal, pas de forme d'adresse. |
| [✓] | `home.search.cancel` | Cancel | *Annuler* | — |

### Filtre de date

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `home.dateFilter.label` | Added | *Ajouté* | — |
| [✓] | `home.dateFilter.any` | Any time | *N'importe quand* | — |
| [✓] | `home.dateFilter.week` | Past week | *Semaine dernière* | — |
| [✓] | `home.dateFilter.month` | Past month | *Mois dernier* | — |
| [✓] | `home.dateFilter.year` | Past year | *Année dernière* | — |

### Filtre d'étiquettes

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `home.tagFilter.button.accessibilityLabel` | Filter by tags | *Filtrer par étiquettes* | **`étiquette` confirmé** — terme standard Apple/Microsoft pour « tag ». |
| [✓] | `home.tagFilter.title` | Tags | *Étiquettes* | — |
| [✓] | `home.tagFilter.searchPlaceholder` | Search tags… | *Rechercher des étiquettes…* | — |
| [✓] | `home.tagFilter.allTags` | All tags | *Toutes les étiquettes* | — |
| [✓] | `home.tagFilter.noMatches` | No matching tags | *Aucune étiquette correspondante* | — |

### Filtres (pastilles) ⚠️ RISQUE DE TRONCATURE LE PLUS ÉLEVÉ

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `filter.all` | All | *Tous* | — |
| [✓] | `filter.unread` | Unread | *Non lus* | Pas de forme d'adresse. |
| [✓] | `filter.reading` | Reading | *En cours* | — |
| [✓] | `filter.read` | Read | *Lus* | — |
| [✓] | `filter.archived` | Archived | *Archivés* | — |

### ⚠️ Clés plurielles — vérifier chaque nombre (0, 1, 2, 5)

**Règle :** le français traite `0` comme un singulier (« 0 article », pas « 0 articles »).

| ✓ | Clé | Anglais (other) | Traduction (other) | Compte → résultat |
|---|-----|-----------------|---------------------|-------------------|
| [✓] | `filter.unread.accessibilityLabel` | Unread, {count} articles | *Non lus, {count} articles* | 0 : Non lus, 0 article · 1 : Non lus, 1 article · 2 : Non lus, 2 articles · 5 : Non lus, 5 articles |
| [✓] | `filter.reading.accessibilityLabel` | Reading, {count} articles | *En cours, {count} articles* | 0 : En cours, 0 article · 1 : En cours, 1 article · 2 : En cours, 2 articles · 5 : En cours, 5 articles |
| [✓] | `filter.read.accessibilityLabel` | Read, {count} articles | *Lus, {count} articles* | 0 : Lus, 0 article · 1 : Lus, 1 article · 2 : Lus, 2 articles · 5 : Lus, 5 articles |
| [✓] | `filter.archived.accessibilityLabel` | Archived, {count} articles | *Archivés, {count} articles* | 0 : Archivés, 0 article · 1 : Archivés, 1 article · 2 : Archivés, 2 articles · 5 : Archivés, 5 articles |
| [✓] | `dialog.bulkDelete.title` | Delete {count} articles? | *Supprimer {count} articles?* | 0 : Supprimer 0 article? · 1 : Supprimer 1 article? · 2 : Supprimer 2 articles? · 5 : Supprimer 5 articles? |
| [✓] | `import.done.summary` | {count} articles imported | *{count} articles importés* | 0 : 0 article importé · 1 : 1 article importé · 2 : 2 articles importés · 5 : 5 articles importés |
| [✓] | `import.done.skippedSuffix` | , {count} skipped | *, {count} ignorés* | 0 : , 0 ignoré · 1 : , 1 ignoré · 2 : , 2 ignorés · 5 : , 5 ignorés |

Aucun problème de registre — ces chaînes ne s'adressent pas directement à l'utilisateur.

### Carte d'article

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `articleCard.estimatedReadTime` | {N} min read | *{N} min de lecture* | « min » invariant — pas de variante plurielle requise. |
| [✗] | `articleCard.accessibilityHint` | Double tap to open | *Appuie deux fois pour ouvrir* | Registre : `Appuyez` → `Appuie`. Appliqué par cohérence à toutes les instructions VoiceOver. |

### États vides

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `home.empty.noArticles.headline` | No articles yet | *Aucun article pour l'instant* | — |
| [✗] | `home.empty.noArticles.subheadline` | Share an article from Safari to get started. | *Partage un article depuis Safari pour commencer.* | Registre : `Partagez` → `Partage`. |
| [✓] | `home.empty.noResults.headline` | No results | *Aucun résultat* | — |
| [✗] | `home.empty.noResults.subheadline` | Try a different search term. | *Essaie un autre terme de recherche.* | Registre : `Essayez` → `Essaie`. |
| [✓] | `home.empty.archive.headline` | Nothing archived | *Rien d'archivé* | — |
| [✗] | `home.empty.archive.subheadline` | Articles you archive will appear here. | *Les articles que tu archives apparaîtront ici.* | Registre : `vous archivez` → `tu archives`. |
| [✓] | `home.empty.noUnread.headline` *(Web)* | Nothing unread | *Aucun article non lu* | needs_review levé. |
| [✓] | `home.empty.noReading.headline` *(Web)* | Nothing in progress | *Rien en cours* | needs_review levé. |
| [✓] | `home.empty.noRead.headline` *(Web)* | Nothing read yet | *Rien de lu pour l'instant* | needs_review levé. |

> **Note additionnelle (hors échantillon, trouvée dans `UI_COPY.md`) :** les sous-titres `home.empty.noUnread/noReading/noRead.subheadline` utilisaient aussi `vous`. Corrigés en tutoiement par cohérence — voir résumé, lignes 18–20.

### Actions par balayage

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `swipe.delete` | Delete | *Supprimer* | — |
| [✓] | `swipe.archive` | Archive | *Archiver* | — |
| [✓] | `swipe.unarchive` | Unarchive | *Désarchiver* | — |
| [✓] | `swipe.markRead` | Mark Read | *Marquer comme lu* | — |
| [✓] | `swipe.markUnread` | Mark Unread | *Marquer comme non lu* | — |

### Menu contextuel

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `contextMenu.open` | Open | *Ouvrir* | — |
| [✓] | `contextMenu.archive` | Archive | *Archiver* | — |
| [✓] | `contextMenu.markAsRead` | Mark as read | *Marquer comme lu* | — |
| [✓] | `contextMenu.markAsUnread` | Mark as unread | *Marquer comme non lu* | — |
| [✓] | `contextMenu.delete` | Delete | *Supprimer* | Destructif. |

### Dialogue de confirmation de suppression

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `dialog.deleteArticle.title` | Delete article? | *Supprimer l'article?* | — |
| [✗] | `dialog.deleteArticle.message` | This cannot be undone. The file will be permanently removed from your iCloud Drive. | *Cette action est irréversible. Le fichier sera définitivement supprimé de ton iCloud Drive.* | Registre : `votre` → `ton`. |
| [✓] | `dialog.deleteArticle.confirm` | Delete | *Supprimer* | — |
| [✓] | `dialog.deleteArticle.cancel` | Cancel | *Annuler* | — |

### Ajouter un article (dans l'application)

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `addArticle.navTitle` | Add Article | *Ajouter un article* | — |
| [✗] | `addArticle.idle.instructions` | Paste a link to save an article to your library. | *Colle un lien pour enregistrer un article dans ta bibliothèque.* | Registre : `Collez`/`votre` → `Colle`/`ta`. |
| [✗] | `addArticle.idle.placeholder` | Paste a link… | *Colle un lien…* | Registre : `Collez` → `Colle`. |
| [✓] | `addArticle.saving.message` | Saving article… | *Enregistrement de l'article…* | Forme nominale, pas d'adresse directe. |
| [✗] | `addArticle.success.headline` | Article saved! | *Article enregistré* | Point d'exclamation retiré — convention `UI_COPY.md` (« no exclamation marks »). Pas un changement de registre, mais une incohérence stylistique corrigée pour la même raison. |
| [✓] | `addArticle.failure.headline` | Could not save article | *Impossible d'enregistrer l'article* | — |
| [✓] | `addArticle.failure.tryAgain` | Try Again | *Réessayer* | — |
| [✓] | `addArticle.error.noLibraryFolder` | No library folder selected. | *Aucun dossier de bibliothèque sélectionné.* | — |

> **Note additionnelle :** `addArticle.success.subheadline` (« …dans votre bibliothèque. ») n'était pas dans l'échantillon, mais existe dans `UI_COPY.md` — corrigée en « ta bibliothèque » par cohérence.

---

## 3. Vue de lecture

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✗] | `reading.splitView.placeholder.headline` | Select an article | *Sélectionne un article* | Registre : impératif `Sélectionnez` → `Sélectionne`. Vue divisée iPad. |
| [✓] | `reading.back.accessibilityLabel` | Back to reading list | *Retour à la liste de lecture* | — |
| [✓] | `reading.openExternal.accessibilityLabel` | Open original article | *Ouvrir l'article original* | — |
| [✗] | `reading.immersiveHint` | Tap anywhere to reveal controls | *Touche n'importe où pour afficher les commandes* | Registre : `Touchez` → `Touche`. |
| [✓] | `reading.body.loading` | Loading… | *Chargement…* | — |
| [✓] | `reading.body.image.accessibilityLabel` | Image | *Image* | — |
| [✓] | `reading.relatedArticles.sectionHeader` | Related | *Articles connexes* | — |
| [✓] | `reading.header.byline` | By {author} | *Par {author}* | — |

### Éditeur d'étiquettes

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `tagsEditor.instructions` | Comma-separated tags. Stored in the article's YAML so they work with Obsidian. | *Étiquettes séparées par des virgules. Stockées dans le YAML de l'article pour fonctionner avec Obsidian.* | `Obsidian`, `YAML` invariants. |
| [✓] | `tagsEditor.placeholder` | e.g. research, design | *p. ex. recherche, design* | — |
| [✓] | `tagsEditor.saveFailed.title` | Couldn't save tags | *Impossible d'enregistrer les étiquettes* | — |
| [✗] | `tagsEditor.saveFailed.message` | Check folder access or disk space, then try again. | *Vérifie l'accès au dossier ou l'espace disque, puis réessaie.* | Registre : `Vérifiez`/`réessayez` → `Vérifie`/`réessaie`. |

### Barre de lecture (commandes inférieures)

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `reading.controls.decreaseFontSize` | Decrease font size | *Réduire la taille du texte* | — |
| [✓] | `reading.controls.increaseFontSize` | Increase font size | *Augmenter la taille du texte* | — |
| [✓] | `reading.controls.lineSpacing` | Line spacing | *Interligne* | — |
| [✓] | `reading.controls.margins` | Margins | *Marges* | — |
| [✓] | `reading.controls.theme` | Theme | *Thème* | — |
| [✓] | `reading.controls.markAsRead` | Mark as read | *Marquer comme lu* | — |
| [✓] | `reading.controls.tts.play` | Play text-to-speech | *Lire la synthèse vocale* | — |
| [✓] | `reading.controls.tts.pause` | Pause text-to-speech | *Mettre en pause la synthèse vocale* | — |

> **Note additionnelle :** `reading.controls.lineSpacing.hint`, `.margins.hint`, `.theme.hint` (« Appuyez deux fois pour ouvrir… ») ne sont pas dans l'échantillon mais existent dans `UI_COPY.md` — corrigées en `Appuie` par cohérence.

### Panneau des réglages de police/thème

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `reading.controlsSheet.fontSizeLabel` | Font size | *Taille du texte* | — |
| [✓] | `reading.controlsSheet.lineSpacingLabel` | Line spacing | *Interligne* | — |

---

## 4. Réglages de lecture (panneau inférieur)

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `readerSettings.title` | Reading settings | *Réglages de lecture* | — |
| [✓] | `readerSettings.fontSize.sectionLabel` | Text size | *Taille du texte* | — |
| [✓] | `readerSettings.fontSize.xs` | XS | *TPS* | « Très petit, 14 points ». |
| [✓] | `readerSettings.fontSize.s` | S | *P* | « Petit, 16 points ». |
| [✓] | `readerSettings.fontSize.m` | M | *M* | « Moyen, 18 points, par défaut ». |
| [✓] | `readerSettings.fontSize.l` | L | *G* | « Grand, 20 points ». |
| [✓] | `readerSettings.fontSize.xl` | XL | *TG* | « Très grand, 22 points ». |
| [✓] | `readerSettings.fontSize.xxl` | XXL | *TTG* | « Très très grand, 26 points ». |
| [✓] | `readerSettings.lineSpacing.sectionLabel` | Line spacing | *Interligne* | — |
| [✓] | `readerSettings.lineSpacing.compact` | Compact | *Compact* | — |
| [✓] | `readerSettings.lineSpacing.normal` | Normal | *Normal* | — |
| [✓] | `readerSettings.lineSpacing.relaxed` | Relaxed | *Détendu* | — |
| [✓] | `readerSettings.lineSpacing.airy` | Airy | *Aéré* | — |
| [✓] | `readerSettings.theme.sectionLabel` | Theme | *Thème* | — |
| [✓] | `readerSettings.margins.sectionLabel` | Margins | *Marges* | — |

---

## 5. Réglages (modal)

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `settings.title` | Settings | *Réglages* | — |
| [✓] | `settings.section.reading` | Reading | *Lecture* | — |
| [✓] | `settings.font.sectionLabel` | Font | *Police* | — |
| [✓] | `settings.font.preview` | The quick brown fox jumps over the lazy dog | *Portez ce vieux whisky au juge blond qui fume* | **Exception volontaire au tutoiement.** Pangramme français figé, pas une adresse à l'utilisateur — comme « the quick brown fox » en anglais. Aucun changement. |
| [✓] | `settings.fontSize.sectionLabel` | Size | *Taille* | — |
| [✓] | `settings.fontSize.valueLabel` | {size}pt | *{size}pt* | « pt » invariant. |
| [✓] | `settings.section.storage` | Storage | *Stockage* | — |
| [✓] | `settings.folder.rowLabel` | Articles folder | *Dossier des articles* | — |
| [✓] | `settings.folder.emptyValue` | Not set | *Non défini* | — |
| [✓] | `settings.import.rowLabel` | Import Articles | *Importer des articles* | — |
| [✓] | `settings.section.about` | About | *À propos* | — |
| [✓] | `settings.about.versionRowLabel` | Version {version} | *Version {version}* | — |
| [✓] | `settings.privacyPolicy.rowLabel` | Privacy Policy | *Politique de confidentialité* | — |
| [✓] | `settings.section.privacy` | Privacy | *Confidentialité* | — |
| [✓] | `settings.analytics.rowLabel` | Share anonymous data | *Partager des données anonymes* | Infinitif, registre neutre. |
| [✓] | `settings.analytics.subtitle` | No personal info or article content, ever. | *Aucune information personnelle ni contenu d'article, jamais.* | — |
| [✓] | `privacyPolicy.navTitle` | Privacy Policy | *Politique de confidentialité* | — |

### Dialogue de changement de dossier

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✗] | `dialog.changeFolder.title` | Move your existing articles to the new folder? | *Déplacer tes articles existants vers le nouveau dossier?* | Registre : `vos` → `tes`. |
| [✗] | `dialog.changeFolder.message` | Your old folder won't be touched if you choose No. | *Ton ancien dossier ne sera pas touché si tu choisis Non.* | Registre : `Votre`/`vous choisissez` → `Ton`/`tu choisis`. |
| [✓] | `dialog.changeFolder.yes` | Move Articles | *Déplacer les articles* | — |
| [✓] | `dialog.changeFolder.no` | Keep in Old Folder | *Garder dans l'ancien dossier* | — |
| [✓] | `dialog.changeFolder.cancel` | Cancel | *Annuler* | — |

### Importation

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `import.idle.headline` | Import Articles | *Importer des articles* | — |
| [✗] | `import.idle.subtitle` | Import your reading list from GoodLinks, Instapaper, Pocket, Readwise Reader, or Matter. | *Importe ta liste de lecture depuis GoodLinks, Instapaper, Pocket, Readwise Reader ou Matter.* | Registre : `Importez`/`votre` → `Importe`/`ta`. Noms de produits tiers invariants. |
| [✓] | `import.idle.selectFileButton` | Select Export File | *Sélectionner le fichier d'exportation* | Infinitif, registre neutre. |
| [✓] | `import.parsing.message` | Reading file… | *Lecture du fichier…* | — |
| [✓] | `import.writing.message` | Importing articles… | *Importation des articles…* | — |
| [✓] | `import.done.headline` | Import Complete | *Importation terminée* | — |

> **Note additionnelle :** `import.idle.noFolderWarning` (« Définissez votre dossier d'articles… ») n'est pas dans l'échantillon mais existe dans `UI_COPY.md` — corrigée en « Définis ton dossier d'articles… » par cohérence.

---

## 6. À propos

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `about.title` | About Verso | *À propos de Verso* | — |
| [✓] | `about.version.rowLabel` | Version | *Version* | — |
| [✓] | `about.acknowledgements.rowLabel` | Open-source acknowledgements | *Remerciements open source* | « open source » — emprunt établi, sans équivalent courant en contexte logiciel, conservé sans trait d'union. |
| [✓] | `about.github.rowLabel` | View on GitHub | *Voir sur GitHub* | `GitHub` invariant. |
| [✓] | `about.privacyPolicy.rowLabel` | Privacy policy | *Politique de confidentialité* | — |
| [✓] | `about.footer` | Verso {version} · Built with care | *Verso {version} · Conçu avec soin* | `Verso` invariant. Point médian confirmé correct. |

---

## 7. Extension de partage

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `share.title` | Save to Verso | *Enregistrer dans Verso* | `Verso` invariant. |
| [✓] | `share.save.default` | Save | *Enregistrer* | — |
| [✓] | `share.save.loading` | Saving… | *Enregistrement…* | — |
| [✓] | `share.save.success` | Saved | *Enregistré* | — |
| [✓] | `share.save.error` | Try again | *Réessayer* | — |
| [✓] | `share.cancel` | Cancel | *Annuler* | — |
| [✓] | `share.error.noFolder.message` | Folder not configured. | *Dossier non configuré.* | — |
| [✓] | `share.error.noFolder.cta` | Open Verso to finish setup | *Ouvrir Verso pour terminer la configuration* | — |

### Extension de partage — Échec d'analyse

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `share.error.headline` | Couldn't save this article. | *Impossible d'enregistrer cet article.* | — |
| [✗] | `share.error.subheadline` | The page couldn't be read. You can open it directly in Safari. | *La page n'a pas pu être lue. Tu peux l'ouvrir directement dans Safari.* | Registre : `Vous pouvez` → `Tu peux`. |
| [✓] | `share.error.openInSafari` | Open in Safari | *Ouvrir dans Safari* | — |
| [✓] | `share.error.dismiss` | Dismiss | *Fermer* | — |

### Extension de partage — URL en double

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `share.duplicate.headline` | Article already saved | *Article déjà enregistré* | — |
| [✗] | `share.duplicate.subheadline` | This link is already in your library as "{existingTitle}". | *Ce lien est déjà dans ta bibliothèque sous le nom « {existingTitle} ».* | Registre : `votre` → `ta`. Guillemets `« »` confirmés corrects. |
| [✓] | `share.duplicate.updateExisting` | Update existing | *Mettre à jour l'existant* | — |
| [✓] | `share.duplicate.saveCopy` | Save as copy | *Enregistrer une copie* | « (Copy) » → « (Copie) » confirmé. |
| [✓] | `share.duplicate.cancel` | Cancel | *Annuler* | — |
| [✓] | `share.duplicate.success.saved` | Saved | *Enregistré* | — |
| [✓] | `share.duplicate.success.updated` | Updated | *Mis à jour* | — |

---

## 8. Erreurs et messages système

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✗] | `error.offline.banner.headline` | You're offline. | *Tu es hors ligne.* | Registre : `Vous êtes` → `Tu es`. « hors ligne » confirmé correct. |
| [✓] | `error.offline.banner.subheadline` | Saved articles are still available. | *Les articles enregistrés restent disponibles.* | — |
| [✓] | `error.offline.articleUnavailable` | Not available offline. | *Non disponible hors ligne.* | — |
| [✓] | `error.parsing.headline` | Couldn't read this article. | *Impossible de lire cet article.* | — |
| [✓] | `error.parsing.subheadline` | The page may be behind a paywall or require a login. | *La page est peut-être derrière un mur payant ou exige une connexion.* | **`mur payant` confirmé, conservé.** L'OQLF recommande officiellement « verrou d'accès payant », mais ce terme est lourd pour une micro-copie d'erreur. « Mur payant » est largement utilisé dans les médias québécois et se lit plus naturellement — choix éditorial délibéré. |
| [✓] | `error.parsing.openInSafari` | Open in Safari | *Ouvrir dans Safari* | — |
| [✓] | `error.parsing.dismiss` | Dismiss | *Fermer* | — |
| [✓] | `error.noFolder.headline` | No folder selected. | *Aucun dossier sélectionné.* | — |
| [✗] | `error.noFolder.subheadline` | Choose a folder in iCloud Drive to start saving articles. | *Choisis un dossier dans iCloud Drive pour commencer à enregistrer des articles.* | Registre : `Choisissez` → `Choisis`. |
| [✓] | `error.noFolder.cta` | Choose folder | *Choisir un dossier* | — |
| [✓] | `error.folderMissing.headline` | Folder not found. | *Dossier introuvable.* | — |
| [✗] | `error.folderMissing.subheadline` | The folder may have been moved or deleted. Choose a new one to continue. | *Le dossier a peut-être été déplacé ou supprimé. Choisis-en un nouveau pour continuer.* | Registre : `Choisissez-en` → `Choisis-en`. |
| [✓] | `error.folderMissing.cta` | Choose new folder | *Choisir un nouveau dossier* | — |
| [✓] | `error.iCloudUnavailable.headline` | iCloud Drive is unavailable. | *iCloud Drive est indisponible.* | `iCloud Drive` invariant. |
| [✗] | `error.iCloudUnavailable.subheadline` | Go to Settings → [Your Name] → iCloud to re-enable it. | *Va dans Réglages → [Your Name] → iCloud pour le réactiver.* | Registre : `Allez` → `Va`. **⚠️ Toujours en suspens** — le chemin exact des Réglages doit être confirmé sur un appareil iOS réel en fr-CA avant publication; signalé depuis le brouillon original, indépendant du tutoiement. |
| [✓] | `error.fileWrite.message` | Couldn't save article. | *Impossible d'enregistrer l'article.* | — |
| [✗] | `error.fileWrite.subtext` | Check that your folder is accessible and try again. | *Vérifie que ton dossier est accessible et réessaie.* | Registre : `Vérifiez`/`votre`/`réessayez` → `Vérifie`/`ton`/`réessaie`. |
| [✓] | `error.fileRead.headline` | This article couldn't be loaded. | *Cet article n'a pas pu être chargé.* | — |
| [✓] | `error.fileRead.cta` | Open original | *Ouvrir l'original* | — |
| [✗] | `error.generic` | Something went wrong. Please try again. | *Une erreur s'est produite. Réessaie.* | Registre : `Veuillez réessayer` → `Réessaie`. |

---

## 9. Étiquettes d'accessibilité uniquement (VoiceOver)

**Décision de registre :** tutoyées par cohérence — VoiceOver lit littéralement « touche deux fois » comme une adresse directe à la personne.

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✗] | `a11y.articleRow.hint` | Double tap to open | *Touche deux fois pour ouvrir* | Registre : `Touchez` → `Touche`. |
| [✓] | `a11y.filterChip.selected` | Currently selected | *Actuellement sélectionné* | — |
| [✗] | `a11y.filterChip.unselected` | Double tap to filter | *Touche deux fois pour filtrer* | Registre : `Touchez` → `Touche`. |
| [✓] | `a11y.themeChip.selected` | Currently selected | *Actuellement sélectionné* | — |
| [✗] | `a11y.themeChip.unselected` | Double tap to select | *Touche deux fois pour sélectionner* | Registre : `Touchez` → `Touche`. |
| [✓] | `a11y.fontOption.selected` | {fontName}, selected | *{fontName}, sélectionné* | — |
| [✓] | `a11y.fontSize.label` | {label}, {points} points | *{label}, {points} points* | — |
| [✓] | `a11y.fontSize.default` | {label}, {points} points, default | *{label}, {points} points, par défaut* | — |
| [✓] | `a11y.progress.label` | Reading progress | *Progression de lecture* | — |
| [✓] | `a11y.progress.value` | {N} percent | *{N} pour cent* | Pas de variante plurielle — confirmé. |
| [✓] | `a11y.skeletonLoading` | Loading articles | *Chargement des articles* | — |
| [✓] | `a11y.deleteAction` | Delete article | *Supprimer l'article* | — |
| [✓] | `a11y.archiveAction` | Archive article | *Archiver l'article* | — |
| [✓] | `a11y.unarchiveAction` | Unarchive article | *Désarchiver l'article* | — |

> **Note additionnelle :** `filter.chip.unselected.hint` (section 2) porte la même instruction « Appuyez deux fois » et a reçu la même correction par cohérence — voir résumé.

---

## 10. Écran de lancement

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `launch.brandName` | Verso | *Verso* | **Invariant** — nom de marque. |

---

## 11. Chaînes Web uniquement

| ✓ | Clé | Anglais | Traduction | Notes |
|---|-----|---------|------------|-------|
| [✓] | `web.unsupportedBrowser.headline` | Browser not supported | *Navigateur non pris en charge* | needs_review levé. |
| [✗] | `web.unsupportedBrowser.subheadline` | Verso Web uses the File System Access API, which requires Chrome or Edge 86+. Please open this page in a supported browser. | *Verso Web utilise l'API File System Access, qui nécessite Chrome ou Edge 86+. Ouvre cette page dans un navigateur pris en charge.* | Registre : `Veuillez ouvrir` → `Ouvre`. Termes techniques invariants. needs_review levé. |
| [✓] | `web.changeFolder.label` | Change folder | *Changer de dossier* | needs_review levé. |
| [✓] | `web.fontFamily.system` | System | *Système* | needs_review levé. |
| [✓] | `web.fontFamily.mono` | Mono | *Mono* | needs_review levé. |
| [✓] | `web.fontFamily.georgia` | Georgia | *Georgia* | **Invariant** — nom de police. |
| [✓] | `web.fontFamily.dyslexic` | OpenDyslexic | *OpenDyslexic* | **Invariant** — nom de police/marque. |
| [✓] | `web.reader.toggleControls.show` | Show controls | *Afficher les commandes* | needs_review levé. |
| [✓] | `web.reader.toggleControls.hide` | Hide controls | *Masquer les commandes* | needs_review levé. |
| [✓] | `web.reader.backButton.label` | Library | *Bibliothèque* | needs_review levé. |
| [✗] | `web.reader.error.noFolder` | No folder selected. Go back and choose your library folder. | *Aucun dossier sélectionné. Reviens en arrière et choisis ton dossier de bibliothèque.* | Registre : `Revenez`/`choisissez`/`votre` → `Reviens`/`choisis`/`ton`. needs_review levé. |
| [✗] | `web.reader.error.permissionDenied` | Folder permission denied. Go back and re-select your library. | *Autorisation du dossier refusée. Reviens en arrière et resélectionne ta bibliothèque.* | Registre : `Revenez`/`resélectionnez`/`votre` → `Reviens`/`resélectionne`/`ta`. needs_review levé. |
| [✓] | `web.reader.error.articleNotFound` | Article not found: {filename} | *Article introuvable : {filename}* | needs_review levé. |
| [✓] | `web.reader.error.loadFailed` | Failed to load article | *Échec du chargement de l'article* | needs_review levé. |
| [✓] | `web.reader.error.fallback` | Article not found. | *Article introuvable.* | needs_review levé. |
| [✓] | `web.reader.backToLibrary.label` | Back to library | *Retour à la bibliothèque* | needs_review levé. |

---

## Vérification du rendu des diacritiques

Hors du périmètre de cette passe linguistique — nécessite un test visuel sur appareil/navigateur réel à chaque taille de lecture (XS à XXL). Aucune chaîne fr-CA ci-dessus n'introduit de nouveau caractère diacritique.

| Glyphe | OpenDyslexic | Police système | Notes |
|--------|-------------|----------------|-------|
| `ç` | ☐ | ☐ | Cédille |
| `ã` | ☐ | ☐ | Tilde + a |
| `õ` | ☐ | ☐ | Tilde + o |
| `â` | ☐ | ☐ | Circonflexe + a |
| `ê` | ☐ | ☐ | Circonflexe + e |
| `é` | ☐ | ☐ | Aigu + e |
| `à` | ☐ | ☐ | Grave + a |
| `ü` | ☐ | ☐ | Tréma + u |
| `ô` | ☐ | ☐ | Circonflexe + o |
| `î` | ☐ | ☐ | Circonflexe + i |
| `û` | ☐ | ☐ | Circonflexe + u |
| `ë` | ☐ | ☐ | Tréma + e |

---

## Résumé des modifications

Chaque ligne correspond à une chaîne dont le texte fr-CA a changé. Les lignes **(hors échantillon)** ne figuraient pas dans le tableau de révision original mais existent dans `docs/copy/UI_COPY.md` ; corrigées par cohérence et déjà appliquées là-bas.

| # | Section | Clé | Avant | Corrigé | Raison |
|---|---------|-----|-------|---------|--------|
| 1 | OB-1 | `onboarding.welcome.headline` | Vos articles. Vos fichiers. | Tes articles. Tes fichiers. | Tutoiement |
| 2 | OB-1 | `onboarding.welcome.subheadline` | …dans votre iCloud Drive. | …dans ton iCloud Drive. | Tutoiement |
| 3 | OB-2 | `onboarding.theme.headline` | Choisissez votre thème de lecture | Choisis ton thème de lecture | Tutoiement |
| 4 | OB-2 | `onboarding.theme.subheadline` | Vous pouvez le modifier… | Tu peux le modifier… | Tutoiement |
| 5 | OB-3 | `onboarding.folder.headline` | …enregistrer vos articles? | …enregistrer tes articles? | Tutoiement |
| 6 | OB-3 | `onboarding.folder.subheadline` | Choisissez… que vous pouvez ouvrir… | Choisis… que tu peux ouvrir… | Tutoiement |
| 7 | OB-3 | `onboarding.folder.privacyNote` | …vos fichiers… votre iCloud Drive. | …tes fichiers… ton iCloud Drive. | Tutoiement |
| 8 | OB-3 | `onboarding.folder.obsidianTip` | Vous utilisez Obsidian? Pointez… votre coffre… | Tu utilises Obsidian? Pointe… ton coffre… | Tutoiement |
| 9 | OB-4 | `onboarding.tour.step1` | Partagez… votre navigateur… | Partage… ton navigateur… | Tutoiement |
| 10 | OB-4 | `onboarding.tour.step2` | Ouvrez Verso… Votre liste… vos fichiers. | Ouvre Verso… Ta liste… tes fichiers. | Tutoiement |
| 11 | OB-4 | `onboarding.tour.step3` | Marquez… votre dossier… | Marque… ton dossier… | Tutoiement |
| 12 | OB-5 | `onboarding.analyticsConsent.headline` | Aidez à améliorer Verso | Aide à améliorer Verso | Tutoiement |
| 13 | OB-5 | `onboarding.analyticsConsent.subheadline` | Partagez des données… | Partage des données… | Tutoiement |
| 14 | Carte d'article | `articleCard.accessibilityHint` | Appuyez deux fois pour ouvrir | Appuie deux fois pour ouvrir | Tutoiement (VoiceOver) |
| 15 | États vides | `home.empty.noArticles.subheadline` | Partagez un article… | Partage un article… | Tutoiement |
| 16 | États vides | `home.empty.noResults.subheadline` | Essayez un autre terme… | Essaie un autre terme… | Tutoiement |
| 17 | États vides | `home.empty.archive.subheadline` | …que vous archivez… | …que tu archives… | Tutoiement |
| 18 | États vides *(hors échantillon)* | `home.empty.noUnread.subheadline` | …que vous n'avez pas encore lus… | …que tu n'as pas encore lus… | Tutoiement |
| 19 | États vides *(hors échantillon)* | `home.empty.noReading.subheadline` | …que vous lisez actuellement… | …que tu lis actuellement… | Tutoiement |
| 20 | États vides *(hors échantillon)* | `home.empty.noRead.subheadline` | …que vous terminez de lire… | …que tu termines de lire… | Tutoiement |
| 21 | Dialogue suppression | `dialog.deleteArticle.message` | …de votre iCloud Drive. | …de ton iCloud Drive. | Tutoiement |
| 22 | Ajouter un article | `addArticle.idle.instructions` | Collez un lien… votre bibliothèque. | Colle un lien… ta bibliothèque. | Tutoiement |
| 23 | Ajouter un article | `addArticle.idle.placeholder` | Collez un lien… | Colle un lien… | Tutoiement |
| 24 | Ajouter un article | `addArticle.success.headline` | Article enregistré! | Article enregistré | Cohérence stylistique (pas de point d'exclamation) |
| 25 | Ajouter un article *(hors échantillon)* | `addArticle.success.subheadline` | …dans votre bibliothèque. | …dans ta bibliothèque. | Tutoiement |
| 26 | Vue de lecture | `reading.splitView.placeholder.headline` | Sélectionnez un article | Sélectionne un article | Tutoiement |
| 27 | Vue de lecture | `reading.immersiveHint` | Touchez n'importe où… | Touche n'importe où… | Tutoiement |
| 28 | Éditeur d'étiquettes | `tagsEditor.saveFailed.message` | Vérifiez… puis réessayez. | Vérifie… puis réessaie. | Tutoiement |
| 29 | Barre de lecture *(hors échantillon)* | `reading.controls.lineSpacing.hint` | Appuyez deux fois… | Appuie deux fois… | Tutoiement (VoiceOver) |
| 30 | Barre de lecture *(hors échantillon)* | `reading.controls.margins.hint` | Appuyez deux fois… | Appuie deux fois… | Tutoiement (VoiceOver) |
| 31 | Barre de lecture *(hors échantillon)* | `reading.controls.theme.hint` | Appuyez deux fois… | Appuie deux fois… | Tutoiement (VoiceOver) |
| 32 | Réglages modal | `dialog.changeFolder.title` | Déplacer vos articles… | Déplacer tes articles… | Tutoiement |
| 33 | Réglages modal | `dialog.changeFolder.message` | Votre ancien dossier… si vous choisissez Non. | Ton ancien dossier… si tu choisis Non. | Tutoiement |
| 34 | Importation | `import.idle.subtitle` | Importez votre liste… | Importe ta liste… | Tutoiement |
| 35 | Importation *(hors échantillon)* | `import.idle.noFolderWarning` | Définissez votre dossier… | Définis ton dossier… | Tutoiement |
| 36 | Extension de partage | `share.error.subheadline` | …Vous pouvez l'ouvrir… | …Tu peux l'ouvrir… | Tutoiement |
| 37 | Extension de partage | `share.duplicate.subheadline` | …dans votre bibliothèque… | …dans ta bibliothèque… | Tutoiement |
| 38 | Erreurs système | `error.offline.banner.headline` | Vous êtes hors ligne. | Tu es hors ligne. | Tutoiement |
| 39 | Erreurs système | `error.noFolder.subheadline` | Choisissez un dossier… | Choisis un dossier… | Tutoiement |
| 40 | Erreurs système | `error.folderMissing.subheadline` | Choisissez-en un nouveau… | Choisis-en un nouveau… | Tutoiement |
| 41 | Erreurs système | `error.iCloudUnavailable.subheadline` | Allez dans Réglages… | Va dans Réglages… | Tutoiement |
| 42 | Erreurs système | `error.fileWrite.subtext` | Vérifiez que votre dossier… réessayez. | Vérifie que ton dossier… réessaie. | Tutoiement |
| 43 | Erreurs système | `error.generic` | …Veuillez réessayer. | …Réessaie. | Tutoiement |
| 44 | Accessibilité | `a11y.articleRow.hint` | Touchez deux fois pour ouvrir | Touche deux fois pour ouvrir | Tutoiement (VoiceOver) |
| 45 | Accessibilité | `a11y.filterChip.unselected` | Touchez deux fois pour filtrer | Touche deux fois pour filtrer | Tutoiement (VoiceOver) |
| 46 | Accessibilité | `a11y.themeChip.unselected` | Touchez deux fois pour sélectionner | Touche deux fois pour sélectionner | Tutoiement (VoiceOver) |
| 47 | Accessibilité *(hors échantillon)* | `filter.chip.unselected.hint` | Appuyez deux fois pour filtrer | Appuie deux fois pour filtrer | Tutoiement (VoiceOver) |
| 48 | Web | `web.unsupportedBrowser.subheadline` | …Veuillez ouvrir cette page… | …Ouvre cette page… | Tutoiement |
| 49 | Web | `web.reader.error.noFolder` | Revenez en arrière et choisissez votre dossier… | Reviens en arrière et choisis ton dossier… | Tutoiement |
| 50 | Web | `web.reader.error.permissionDenied` | Revenez en arrière et resélectionnez votre bibliothèque. | Reviens en arrière et resélectionne ta bibliothèque. | Tutoiement |

**Décisions terminologiques confirmées par recherche (aucun changement, vérifiées sur demande) :**
- `téléverser` (upload) — terme recommandé par l'OQLF, conservé.
- `coffre` (Obsidian vault) — traduction officielle d'Obsidian en français, conservée.
- `mur payant` (paywall) — terme officiel OQLF est « verrou d'accès payant », mais `mur payant` est l'usage courant au Québec et plus naturel en micro-copie ; conservé par choix éditorial.
- `étiquette` (tag) — terme logiciel standard, conservé.
- `open source` — emprunt établi sans équivalent courant, conservé sans trait d'union.

**Aucun changement nécessaire :** la phrase-pangramme de `settings.font.preview` reste inchangée — ce n'est pas une adresse à l'utilisateur, donc le tutoiement ne s'applique pas.

*(50 chaînes corrigées sur ~228 chaînes contenant une forme d'adresse directe à l'utilisateur dans l'échantillon + hors échantillon ; les chaînes restantes — étiquettes nominales, boutons à l'infinitif, noms de marque invariants — ne portaient pas de marqueur de registre.)*

---

## Approbation

- **Nombre total de clés révisées :** ~228 (échantillon) + 7 clés additionnelles trouvées hors échantillon dans `UI_COPY.md`, corrigées par cohérence
- **Modifications proposées :** 50 (voir tableau ci-dessus) — déjà appliquées dans `docs/copy/UI_COPY.md`, colonne `fr-CA`
- **Problèmes critiques (pluriel / diacritiques / troncature) :** 0 nouveau problème introduit par cette passe. Un point reste en suspens, indépendant du tutoiement : `error.iCloudUnavailable.subheadline` nécessite une vérification du chemin exact des Réglages iOS sur un appareil réel fr-CA.

**Signature du réviseur :** Claude (passe automatisée) — à valider par Fabio ou un réviseur humain fr-CA avant publication finale.

**Date :** 2026-06-21

**Prochaine étape :** Les corrections ci-dessus ont déjà été appliquées dans `docs/copy/UI_COPY.md` (colonne fr-CA), avec une note de convention ajoutée en tête du document précisant le tutoiement. Une fois ce document approuvé, `generate.py` peut être relancé pour propager les modifications vers `Localizable.xcstrings`, `L10n.swift`, et tous les fichiers Web `messages/*.json`.
