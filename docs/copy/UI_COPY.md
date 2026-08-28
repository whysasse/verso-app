# Verso — UI Copy & Microcopy

All user-visible text strings for Verso, across **both platforms (iOS and Web)**. Developers on either platform should treat this as the single source of truth when implementing screens — the same keys feed the iOS String Catalog and the Web message dictionary, so wording never drifts between platforms. The English strings below are the development base locale (`en`); translated locales are tracked in `docs/LOCALIZATION.md`.

**Conventions:**
- `{placeholder}` — dynamic value substituted at runtime
- ⚠️ **plural** — needs language-aware plural variants. Do **not** hard-code `count == 1`: use CLDR plural categories (iOS String Catalog / ICU on Web), because French treats 0 as singular and Brazilian Portuguese treats 0 as plural. See `docs/LOCALIZATION.md` §2. The `fr-CA` / `pt-BR` cells below show the representative ("other") form only — the actual `.xcstrings` / ICU plural variants are produced during FAB-275 steps 4–5.
- Tone: sentence case, no exclamation marks, minimal and warm
- Strings marked *invariant* (e.g. brand names) must not be translated — see `docs/LOCALIZATION.md` §4 for the full list (`Verso`, `Obsidian`, `iCloud Drive`, `Markdown`, `Safari`, `GitHub`, `OpenDyslexic`, theme enum keys). Invariant cells repeat the `en` string unchanged.
- `en-CA` is an alias of `en` (no separate column — see `docs/LOCALIZATION.md` §1).
- `fr-CA` / `pt-BR` strings below are a **first draft** (FAB-275 step 3, shared string source). Final linguistic/diacritic QA happens in step 7.
- `fr-CA` register: **tutoiement** (tu/ton/ta/tes), no `vous`. Confirmed during the fr-CA linguistic review (`docs/copy/UI_COPY_LINGUISTIC_REVIEW_fr-CA.md`) — Quebec consumer apps default to `tu`; `vous` reads as stiff/corporate for this product. Avoid France-specific phrasing and English loanwords where a standard Quebec term exists (e.g. `téléverser` not `uploader`, `courriel` not `email` if the word is ever needed). The settings.font.preview pangram is the one exception — it's a fixed sample sentence, not address copy, so it keeps its original imperative form.

---

## 1. Onboarding

### OB-1 · Welcome

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `onboarding.welcome.headline` | Headline | Your articles. Your files. | Tes articles. Tes fichiers. | Seus artigos. Seus arquivos. | — |
| `onboarding.welcome.subheadline` | Subheadline | A quiet place to read. No accounts, no algorithms — just Markdown files in your iCloud Drive. | Un endroit calme pour lire. Aucun compte, aucun algorithme — seulement des fichiers Markdown dans ton iCloud Drive. | Um lugar tranquilo para ler. Sem contas, sem algoritmos — apenas arquivos Markdown no seu iCloud Drive. | — |
| `onboarding.welcome.cta` | Primary button | Get started | Commencer | Começar | — |

### OB-2 · Theme Picker

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `onboarding.theme.headline` | Headline | Choose your reading theme | Choisis ton thème de lecture | Escolha seu tema de leitura | — |
| `onboarding.theme.subheadline` | Subheadline | You can change this any time from settings. | Tu peux le modifier à tout moment dans les réglages. | Você pode alterar isso a qualquer momento nas configurações. | — |
| `onboarding.theme.continue` | Primary button | Continue | Continuer | Continuar | — |
| `theme.paper` | Theme label | Paper | Papier | Papel | Shared with Settings / Reader Settings |
| `theme.sepia` | Theme label | Sepia | Sépia | Sépia | Shared |
| `theme.night` | Theme label | Night | Nuit | Noite | Shared |
| `theme.ink` | Theme label | Ink | Encre | Tinta | Shared |

### OB-3 · Folder Setup

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `onboarding.folder.headline` | Headline | Where should Verso save your articles? | Où Verso doit-il enregistrer tes articles? | Onde o Verso deve guardar seus artigos? | Corrected "store" → "save" during step 4 view-wiring pass to match shipped code — fr-CA/pt-BR already said "save" (enregistrer/guardar), so en was the stale one. |
| `onboarding.folder.subheadline` | Subheadline | Pick a folder in iCloud Drive. Verso saves each article as a Markdown file you can open anywhere. | Choisis un dossier dans iCloud Drive. Verso enregistre chaque article comme un fichier Markdown que tu peux ouvrir n'importe où. | Escolha uma pasta no iCloud Drive. O Verso salva cada artigo como um arquivo Markdown que você pode abrir em qualquer lugar. | Code previously had different wording ("Articles are saved as Markdown files — yours to keep."); switched to this canonical copy during step 4 view-wiring pass since fr-CA/pt-BR were already translated against it. |
| `onboarding.folder.chooseCta` | Folder-picker row placeholder (shown before a folder is selected; replaced by the folder name once one is) | Choose folder… | Choisir un dossier… | Escolher pasta… | Added ellipsis during step 4 view-wiring pass to match the row-placeholder treatment shipped in code (not a standalone button as the original "Primary button" location implied). |
| `onboarding.folder.continueCta` | Primary button | Continue | Continuer | Continuar | Added during step 4 view-wiring pass — missed in the original audit. |
| `onboarding.folder.privacyNote` | Caption below Continue button | Verso never uploads your files. They live in your iCloud Drive. | Verso ne téléverse jamais tes fichiers. Ils restent dans ton iCloud Drive. | O Verso nunca envia seus arquivos para a nuvem. Eles ficam no seu iCloud Drive. | Added during step 4 view-wiring pass — missed in the original audit. |
| `onboarding.folder.obsidianTip` | Tip text | Using Obsidian? Point Verso to a folder inside your vault and articles will appear there automatically. | Tu utilises Obsidian? Pointe Verso vers un dossier dans ton coffre et les articles y apparaîtront automatiquement. | Usa o Obsidian? Aponte o Verso para uma pasta dentro do seu vault e os artigos vão aparecer lá automaticamente. | Documented but not yet shown in `OnboardingFolderPickerView.swift` — adding it is a UI change, not just a wiring fix. Tracked as FAB-280, see docs/BACKLOG.md. |

### OB-4 · Quick Tour

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `onboarding.tour.headline` | Headline | Here's how it works | Voici comment ça fonctionne | Veja como funciona | — |
| `onboarding.tour.step1` | Step 1 label | Share any article from Safari or your browser to save it instantly. | Partage n'importe quel article depuis Safari ou ton navigateur pour l'enregistrer instantanément. | Compartilhe qualquer artigo do Safari ou do seu navegador para salvá-lo instantaneamente. | — |
| `onboarding.tour.step2` | Step 2 label | Open Verso to read. Your list is always in sync with your files. | Ouvre Verso pour lire. Ta liste est toujours synchronisée avec tes fichiers. | Abra o Verso para ler. Sua lista está sempre sincronizada com seus arquivos. | — |
| `onboarding.tour.step3` | Step 3 label | Mark articles as read when you're done. They stay in your folder forever. | Marque les articles comme lus une fois terminés. Ils restent dans ton dossier pour toujours. | Marque os artigos como lidos quando terminar. Eles permanecem na sua pasta para sempre. | — |
| `onboarding.tour.skip` | Text button | Skip | Ignorer | Pular | — |
| `onboarding.tour.next` | Text/chevron button on non-final tour steps | Next | Suivant | Próximo | Added FAB-285 — explicit advance control alongside swipe, for discoverability and VoiceOver/Switch Control users. |
| `onboarding.tour.startReading` | Primary button | Start reading | Commencer à lire | Começar a ler | — |

QuickTourView now implements the 3-step carousel (FAB-281). The interim illustration keys (`onboarding.tour.illustration*`) are retired — they were removed from the generated artifacts alongside the carousel rewrite and should not be referenced in new code. As of FAB-285, the 3 tour steps are flattened into `OnboardingFlowView`'s own outer `TabView` (tags 4–6) rather than nested in a second `TabView` inside `QuickTourView` — two stacked paging containers on the same axis were absorbing the swipe gesture. `QuickTourView` no longer owns its own page-dot indicator; `OnboardingFlowView`'s single 7-dot indicator covers the whole flow.

### OB-5 · Analytics Consent

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `onboarding.analyticsConsent.headline` | Headline | Help make Verso better | Aide à améliorer Verso | Ajude a melhorar o Verso | Added during step 4 view-wiring pass — missed in the original audit. |
| `onboarding.analyticsConsent.subheadline` | Subheadline | Share anonymous usage data — no personal info, no article content, ever. | Partage des données d'utilisation anonymes — aucune information personnelle, aucun contenu d'article, jamais. | Compartilhe dados de uso anônimos — sem informações pessoais, sem conteúdo de artigos, nunca. | — |
| `onboarding.analyticsConsent.acceptCta` | Primary button | Sure, why not | Bien sûr, pourquoi pas | Claro, por que não | — |
| `onboarding.analyticsConsent.declineCta` | Secondary button | No thanks | Non merci | Não, obrigado | — |

---

## 2. Home · Article List

### Navigation

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `home.navTitle` | Navigation bar large title | Verso | Verso | Verso | Invariant — brand name |
| `home.settings.accessibilityLabel` | Settings icon button | Settings | Réglages | Configurações | — |
| `home.archiveToggle.showArchive` | Archive toggle accessibility label | Show archived articles | Afficher les articles archivés | Mostrar artigos arquivados | — |
| `home.archiveToggle.showLibrary` | Archive toggle accessibility label (active) | Show reading list | Afficher la liste de lecture | Mostrar lista de leitura | — |
| `home.sort.newestFirst` | Sort toggle accessibility label | Sort newest first | Trier du plus récent | Ordenar do mais recente | — |
| `home.sort.oldestFirst` | Sort toggle accessibility label (active) | Sort oldest first | Trier du plus ancien | Ordenar do mais antigo | — |
| `home.pullToRefresh.accessibilityLabel` | Pull-to-refresh | Refresh article list | Actualiser la liste d'articles | Atualizar lista de artigos | — |

### Search

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `home.search.placeholder` | Search bar placeholder | Search titles, text, or site… | Rechercher titres, texte ou site… | Buscar títulos, texto ou site… | Updated during step 4 view-wiring pass — code's placeholder is more specific than the doc's original "Search titles…" (search now also matches body text and site name), value corrected to match shipped behaviour. |
| `home.search.clear.accessibilityLabel` | Clear search button | Clear search | Effacer la recherche | Limpar busca | — |
| `home.search.cancel` | Cancel button (keyboard visible) | Cancel | Annuler | Cancelar | — |

### Date Filter

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `home.dateFilter.label` | Row label, left of the date-range menu | Added | Ajouté | Adicionado | Added during step 4 view-wiring pass — missed in the original audit (date-range filter postdates it). |
| `home.dateFilter.any` | Date-range menu option | Any time | N'importe quand | Qualquer período | — |
| `home.dateFilter.week` | Date-range menu option | Past week | Semaine dernière | Última semana | — |
| `home.dateFilter.month` | Date-range menu option | Past month | Mois dernier | Último mês | — |
| `home.dateFilter.year` | Date-range menu option | Past year | Année dernière | Último ano | — |

### Tag Filter

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `home.tagFilter.button.accessibilityLabel` | Tag-filter icon button (top of list) | Filter by tags | Filtrer par étiquettes | Filtrar por etiquetas | Added during step 4 view-wiring pass — tag filtering postdates the original audit. "Tag" rendered as étiquette/etiqueta (standard software term), not a literal "mot-clé"/"marcador". |
| `home.tagFilter.title` | Side panel header | Tags | Étiquettes | Etiquetas | — |
| `home.tagFilter.searchPlaceholder` | Side panel search field | Search tags… | Rechercher des étiquettes… | Buscar etiquetas… | — |
| `home.tagFilter.allTags` | Row that clears the tag selection | All tags | Toutes les étiquettes | Todas as etiquetas | — |
| `home.tagFilter.noMatches` | Empty state inside the panel | No matching tags | Aucune étiquette correspondante | Nenhuma etiqueta correspondente | — |
| `home.tagFilter.close.accessibilityLabel` | Close (X) button | Close tag filter | Fermer le filtre d'étiquettes | Fechar filtro de etiquetas | — |

### Filter Chips

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `filter.all` | Filter chip label | All | Tous | Todos | — |
| `filter.unread` | Filter chip label | Unread | Non lus | Não lidos | — |
| `filter.reading` | Filter chip label | Reading | En cours | Lendo | — |
| `filter.read` | Filter chip label | Read | Lus | Lidos | — |
| `filter.archived` | Filter chip label | Archived | Archivés | Arquivados | Added during step 4 view-wiring pass — `FilterChipBar.swift` renders a chip for every `ArticleStatus` case, including `.archived`, which the original audit missed. |
| `filter.all.accessibilityLabel` | VoiceOver label | All articles, {count} total | Tous les articles, {count} au total | Todos os artigos, {count} no total | ⚠️ plural |
| `filter.unread.accessibilityLabel` | VoiceOver label | Unread, {count} articles | Non lus, {count} articles | Não lidos, {count} artigos | ⚠️ plural |
| `filter.reading.accessibilityLabel` | VoiceOver label | Reading, {count} articles | En cours, {count} articles | Lendo, {count} artigos | ⚠️ plural |
| `filter.read.accessibilityLabel` | VoiceOver label | Read, {count} articles | Lus, {count} articles | Lidos, {count} artigos | ⚠️ plural |
| `filter.archived.accessibilityLabel` | VoiceOver label | Archived, {count} articles | Archivés, {count} articles | Arquivados, {count} artigos | ⚠️ plural. Added during step 4 view-wiring pass — see note on `filter.archived`. |
| `filter.chip.selected.hint` | VoiceOver hint (any chip) | Currently selected | Actuellement sélectionné | Selecionado atualmente | — |
| `filter.chip.unselected.hint` | VoiceOver hint (any chip) | Double tap to filter | Appuie deux fois pour filtrer | Toque duas vezes para filtrar | — |

### Article Card

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `articleCard.accessibilityLabel` | VoiceOver row label | {title}, {source}, {estimated read time} | {title}, {source}, {estimated read time} | {title}, {source}, {estimated read time} | Dynamic — template only, no literal text to translate |
| `articleCard.accessibilityHint` | VoiceOver row hint | Double tap to open | Appuie deux fois pour ouvrir | Toque duas vezes para abrir | — |
| `articleCard.estimatedReadTime` | Read time label | {N} min read | {N} min de lecture | {N} min de leitura | ⚠️ plural: "1 min read" / "{N} min read". `{N}` = ⌈wordCount ÷ WPM⌉. Use a single documented constant **WPM = 220** for MVP. Word count is derived from the **article's** content language, not the UI language. fr-CA/pt-BR: "min" is already an invariant abbreviation in both languages, no plural variant needed. |

### Status Badges

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `status.unread` | Badge / accessibility | Unread | Non lu | Não lido | Singular agreement (describes one article); also used in filter chips and Reading View |
| `status.reading` | Badge / accessibility | Reading | En cours | Lendo | — |
| `status.read` | Badge / accessibility | Read | Lu | Lido | — |

### Empty States

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `home.empty.noArticles.headline` | Empty state headline | No articles yet | Aucun article pour l'instant | Nenhum artigo ainda | — |
| `home.empty.noArticles.subheadline` | Empty state subheadline | Share an article from Safari to get started. | Partage un article depuis Safari pour commencer. | Compartilhe um artigo do Safari para começar. | — |
| `home.empty.noResults.headline` | Search empty state headline | No results | Aucun résultat | Nenhum resultado | — |
| `home.empty.noResults.subheadline` | Search empty state subheadline | Try a different search term. | Essaie un autre terme de recherche. | Tente outro termo de busca. | — |
| `home.empty.archive.headline` | Archive empty state headline | Nothing archived | Rien d'archivé | Nada arquivado | — |
| `home.empty.archive.subheadline` | Archive empty state subheadline | Articles you archive will appear here. | Les articles que tu archives apparaîtront ici. | Os artigos que você arquivar vão aparecer aqui. | — |
| `home.empty.noUnread.headline` | Unread-filter empty state headline | Nothing unread | Aucun article non lu | Nenhum artigo não lido | Added during step 5 web-wiring pass — Web has a per-filter empty state with no iOS equivalent (iOS doesn't filter the list by read status the same way). needs_review. |
| `home.empty.noUnread.subheadline` | Unread-filter empty state subheadline | Articles you haven't read yet will appear here. | Les articles que tu n'as pas encore lus apparaîtront ici. | Os artigos que você ainda não leu vão aparecer aqui. | needs_review. |
| `home.empty.noReading.headline` | Reading-filter empty state headline | Nothing in progress | Rien en cours | Nada em andamento | Added during step 5 web-wiring pass — same as `home.empty.noUnread.headline`. needs_review. |
| `home.empty.noReading.subheadline` | Reading-filter empty state subheadline | Articles you're currently reading will appear here. | Les articles que tu lis actuellement apparaîtront ici. | Os artigos que você está lendo no momento vão aparecer aqui. | needs_review. |
| `home.empty.noRead.headline` | Read-filter empty state headline | Nothing read yet | Rien de lu pour l'instant | Nada lido ainda | Added during step 5 web-wiring pass — same as `home.empty.noUnread.headline`. needs_review. |
| `home.empty.noRead.subheadline` | Read-filter empty state subheadline | Articles you finish reading will appear here. | Les articles que tu termines de lire apparaîtront ici. | Os artigos que você terminar de ler vão aparecer aqui. | needs_review. |
| `home.loading.accessibilityLabel` | Skeleton loading state | Loading articles | Chargement des articles | Carregando artigos | — |

### Swipe Actions

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `swipe.delete` | Swipe-left action label | Delete | Supprimer | Excluir | Red |
| `swipe.archive` | Swipe-left action label | Archive | Archiver | Arquivar | — |
| `swipe.unarchive` | Swipe-left action label (archive view) | Unarchive | Désarchiver | Desarquivar | — |
| `swipe.markRead` | Swipe-right action label | Mark Read | Marquer comme lu | Marcar como lido | Added during step 4 view-wiring pass. Distinct copy/casing from `contextMenu.markAsRead` ("Mark as read") — same action, different control, intentionally not deduplicated since the two surfaces were authored with different wording independently. |
| `swipe.markUnread` | Swipe-right action label | Mark Unread | Marquer comme non lu | Marcar como não lido | Added during step 4 view-wiring pass. See note on `swipe.markRead`. |

### Bulk Select

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `home.bulkSelect.select` | Toolbar button — enters bulk-select mode | Select | Sélectionner | Selecionar | Added during step 4 view-wiring pass — bulk select postdates the original audit. |
| `home.bulkSelect.cancel` | Toolbar button — exits bulk-select mode | Cancel | Annuler | Cancelar | — |
| `home.bulkSelect.markRead` | Bottom bar action (selection non-empty) | Mark read | Marquer comme lu | Marcar como lido | — |
| `home.bulkSelect.delete` | Bottom bar action (selection non-empty) | Delete | Supprimer | Excluir | Destructive |
| `dialog.bulkDelete.title` | Confirmation dialog title | Delete {count} articles? | Supprimer {count} articles? | Excluir {count} artigos? | ⚠️ plural (this row shows the "other"/plural form; singular "one" form authored directly in codegen, same pattern as the other ⚠️-flagged keys). Confirm/Cancel buttons reuse `dialog.deleteArticle.confirm` / `dialog.deleteArticle.cancel` (identical wording, no new key needed). |

### Context Menu

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `contextMenu.open` | Context menu item | Open | Ouvrir | Abrir | — |
| `contextMenu.archive` | Context menu item | Archive | Archiver | Arquivar | — |
| `contextMenu.unarchive` | Context menu item | Unarchive | Désarchiver | Desarquivar | — |
| `contextMenu.markAsRead` | Context menu item | Mark as read | Marquer comme lu | Marcar como lido | — |
| `contextMenu.markAsUnread` | Context menu item | Mark as unread | Marquer comme non lu | Marcar como não lido | — |
| `contextMenu.delete` | Context menu item | Delete | Supprimer | Excluir | Destructive |

### Delete Confirmation Dialog

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `dialog.deleteArticle.title` | Dialog title | Delete article? | Supprimer l'article? | Excluir artigo? | — |
| `dialog.deleteArticle.message` | Dialog message | This cannot be undone. The file will be permanently removed from your iCloud Drive. | Cette action est irréversible. Le fichier sera définitivement supprimé de ton iCloud Drive. | Esta ação não pode ser desfeita. O arquivo será removido permanentemente do seu iCloud Drive. | — |
| `dialog.deleteArticle.confirm` | Destructive button | Delete | Supprimer | Excluir | — |
| `dialog.deleteArticle.cancel` | Cancel button | Cancel | Annuler | Cancelar | — |

### Add Article (In-App)

> Added during step 4 view-wiring pass — this entire in-app sheet (Home's "+" entry point) was missed in the original audit. Its duplicate-prompt state reuses `share.duplicate.*` from §8 per the existing note above; the rest of the screen (idle/saving/success/failure) needed new keys under the `addArticle.*` namespace. "Open in Safari" reuses `error.parsing.openInSafari` (identical wording, already-established generic CTA).

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `addArticle.navTitle` | Sheet nav bar title | Add Article | Ajouter un article | Adicionar artigo | — |
| `addArticle.close.accessibilityLabel` | Close (X) toolbar button | Close | Fermer | Fechar | — |
| `addArticle.close.accessibilityHint` | Close button VoiceOver hint | Dismiss add article sheet | Fermer la feuille d'ajout d'article | Fechar a tela de adicionar artigo | — |
| `addArticle.idle.instructions` | Idle state body copy | Paste a link to save an article to your library. | Colle un lien pour enregistrer un article dans ta bibliothèque. | Cole um link para salvar um artigo na sua biblioteca. | — |
| `addArticle.idle.placeholder` | URL text field placeholder | Paste a link… | Colle un lien… | Cole um link… | — |
| `addArticle.idle.save` | Primary button | Save | Enregistrer | Salvar | — |
| `addArticle.saving.message` | In-progress state | Saving article… | Enregistrement de l'article… | Salvando artigo… | — |
| `addArticle.success.headline` | Success state headline | Article saved! | Article enregistré | Artigo salvo! | — |
| `addArticle.success.subheadline` | Success state subheadline | It will appear in your library shortly. | Il apparaîtra bientôt dans ta bibliothèque. | Ele aparecerá em breve na sua biblioteca. | — |
| `addArticle.failure.headline` | Failure state headline | Could not save article | Impossible d'enregistrer l'article | Não foi possível salvar o artigo | — |
| `addArticle.failure.tryAgain` | Failure state primary button | Try Again | Réessayer | Tentar novamente | — |
| `addArticle.error.noLibraryFolder` | Error message when no folder is bookmarked yet | No library folder selected. | Aucun dossier de bibliothèque sélectionné. | Nenhuma pasta de biblioteca selecionada. | Edge case — folder bookmark missing mid-flow |

---

## 3. Reading View

### Split View Placeholder (iPad)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `reading.splitView.placeholder.headline` | Detail column, no article selected (regular-width iPad) | Select an article | Sélectionne un article | Selecione um artigo | Added during step 4 view-wiring pass — iPad split view postdates the original audit. |
| `reading.splitView.placeholder.accessibilityLabel` | Same placeholder, combined accessibility element | No article selected | Aucun article sélectionné | Nenhum artigo selecionado | — |

### Top Bar

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `reading.back.accessibilityLabel` | Back button | Back to reading list | Retour à la liste de lecture | Voltar para a lista de leitura | — |
| `reading.openExternal.accessibilityLabel` | Open-externally button | Open original article | Ouvrir l'article original | Abrir artigo original | — |

### Tags Editor

> Added during step 4 view-wiring pass — this sheet (opened from the reading view's tag icon) was missed in the original audit. Nav title reuses `home.tagFilter.title` (identical wording, "Tags"). `Obsidian` is a third-party product name and stays invariant.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `tagsEditor.instructions` | Body copy above the text field | Comma-separated tags. Stored in the article's YAML so they work with Obsidian. | Étiquettes séparées par des virgules. Stockées dans le YAML de l'article pour fonctionner avec Obsidian. | Etiquetas separadas por vírgula. Armazenadas no YAML do artigo para funcionar com o Obsidian. | `Obsidian` invariant |
| `tagsEditor.placeholder` | Text field placeholder | e.g. research, design | p. ex. recherche, design | ex.: pesquisa, design | — |
| `tagsEditor.cancel` | Toolbar button | Cancel | Annuler | Cancelar | — |
| `tagsEditor.save` | Toolbar button | Save | Enregistrer | Salvar | — |
| `tagsEditor.saveFailed.title` | Alert title | Couldn't save tags | Impossible d'enregistrer les étiquettes | Não foi possível salvar as etiquetas | — |
| `tagsEditor.saveFailed.message` | Alert message | Check folder access or disk space, then try again. | Vérifie l'accès au dossier ou l'espace disque, puis réessaie. | Verifique o acesso à pasta ou o espaço em disco e tente novamente. | — |
| `tagsEditor.saveFailed.ok` | Alert button | OK | OK | OK | Invariant — standard alert acknowledgement across all three locales |

### Immersive Hint

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `reading.immersiveHint` | Hint pill (first launch only) | Tap anywhere to reveal controls | Touche n'importe où pour afficher les commandes | Toque em qualquer lugar para mostrar os controles | Never shown when VoiceOver is active |

### Bottom Bar (Reading Controls)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `reading.controls.decreaseFontSize` | Icon button accessibility label | Decrease font size | Réduire la taille du texte | Diminuir tamanho da fonte | — |
| `reading.controls.increaseFontSize` | Icon button accessibility label | Increase font size | Augmenter la taille du texte | Aumentar tamanho da fonte | — |
| `reading.controls.lineSpacing` | Icon button accessibility label | Line spacing | Interligne | Espaçamento entre linhas | — |
| `reading.controls.lineSpacing.hint` | VoiceOver hint | Double tap to open spacing options | Appuie deux fois pour ouvrir les options d'interligne | Toque duas vezes para abrir as opções de espaçamento | — |
| `reading.controls.margins` | Icon button accessibility label | Margins | Marges | Margens | — |
| `reading.controls.margins.hint` | VoiceOver hint | Double tap to open margin options | Appuie deux fois pour ouvrir les options de marges | Toque duas vezes para abrir as opções de margem | — |
| `reading.controls.theme` | Icon button accessibility label | Theme | Thème | Tema | — |
| `reading.controls.theme.hint` | VoiceOver hint | Double tap to open theme options | Appuie deux fois pour ouvrir les options de thème | Toque duas vezes para abrir as opções de tema | — |
| `reading.controls.markAsRead` | Icon button accessibility label | Mark as read | Marquer comme lu | Marcar como lido | — |
| `reading.controls.markAsUnread` | Icon button accessibility label | Mark as unread | Marquer comme non lu | Marcar como não lido | — |
| `reading.controls.tts.play` | TTS button accessibility label | Play text-to-speech | Lire la synthèse vocale | Reproduzir texto em voz | — |
| `reading.controls.tts.pause` | TTS button accessibility label | Pause text-to-speech | Mettre en pause la synthèse vocale | Pausar texto em voz | — |

### Font/Theme Adjustment Sheet

> Added during step 4 view-wiring pass — `ReadingControls.swift` (the bottom sheet opened by the Font/Theme buttons in the bar above) was undocumented. Named `controlsSheet.*` rather than reusing `reading.controls.*` to avoid colliding with the bottom bar's icon-button labels above, which are a different component.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `reading.controlsSheet.closeAccessibilityHint` | Close (X) button VoiceOver hint | Dismiss controls | Fermer les commandes | Fechar os controles | Close (X) button itself reuses `addArticle.close.accessibilityLabel` ("Close") — identical wording/affordance across sheets. |
| `reading.controlsSheet.fontSizeLabel` | Font-size row label | Font size | Taille du texte | Tamanho da fonte | — |
| `reading.controlsSheet.lineSpacingLabel` | Line-spacing row label | Line spacing | Interligne | Espaçamento entre linhas | — |

### Text-to-Speech (Lock Screen / Now Playing)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `tts.nowPlaying.play` | Lock screen control | Play | Lire | Reproduzir | — |
| `tts.nowPlaying.pause` | Lock screen control | Pause | Pause | Pausar | — |
| `tts.nowPlaying.skipForward` | Lock screen control | Skip forward | Avancer | Avançar | — |

### Article Body

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `reading.body.loading` | Placeholder shown while the markdown file is being parsed | Loading… | Chargement… | Carregando… | Added during step 4 view-wiring pass — missed in the original audit. |
| `reading.body.image.accessibilityLabel` | Inline image with no caption/alt text | Image | Image | Imagem | Added during step 4 view-wiring pass — generic fallback when an article image has no alt text. |
| `reading.relatedArticles.sectionHeader` | Section header below article body | Related | Articles connexes | Relacionados | Added during step 4 view-wiring pass — missed in the original audit. |

### Article Header

> **Format note:** Display the saved date using a **locale-aware medium date style** — `DateFormatter.dateStyle = .medium` on iOS, `Intl.DateTimeFormat(locale, { dateStyle: 'medium' })` on Web. Do **not** hard-code `MMM d, yyyy`. Expected output by locale: `en` "Apr 28, 2025" · `fr-CA` "28 avr. 2025" · `pt-BR` "28 de abr. de 2025". No string key needed — formatting is code-level but must respect the active locale.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `reading.header.byline` | Author attribution line | By {author} | Par {author} | Por {author} | Added during step 4 view-wiring pass — missed in the original audit. `{author}` is the article's author name as-is (not translated); falls back to `publicationFallback` (source name, also not translated) when author is unavailable, with no "By"/"Par"/"Por" prefix in that case. |

---

## 4. Reader Settings (Bottom Sheet)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `readerSettings.title` | Sheet title | Reading settings | Réglages de lecture | Configurações de leitura | — |
| `readerSettings.fontSize.sectionLabel` | Section label | Text size | Taille du texte | Tamanho do texto | — |
| `readerSettings.fontSize.xs` | Step label | XS | TPS | PP | Abbreviations translated per locale (FR: Très Petit, PT: Super Pequeno). Accessibility label translates regardless: "Extra small, 14 points" → fr-CA "Très petit, 14 points" / pt-BR "Extrapequeno, 14 pontos" |
| `readerSettings.fontSize.s` | Step label | S | P | P | Accessibility label: "Small, 16 points" → fr-CA "Petit, 16 points" / pt-BR "Pequeno, 16 pontos" |
| `readerSettings.fontSize.m` | Step label | M | M | M | Accessibility label: "Medium, 18 points, default" → fr-CA "Moyen, 18 points, par défaut" / pt-BR "Médio, 18 pontos, padrão" |
| `readerSettings.fontSize.l` | Step label | L | G | G | Accessibility label: "Large, 20 points" → fr-CA "Grand, 20 points" / pt-BR "Grande, 20 pontos" |
| `readerSettings.fontSize.xl` | Step label | XL | TG | GG | Accessibility label: "Extra large, 22 points" → fr-CA "Très grand, 22 points" / pt-BR "Extragrande, 22 pontos" |
| `readerSettings.fontSize.xxl` | Step label | XXL | TTG | GGG | Accessibility label: "Extra extra large, 26 points" → fr-CA "Très très grand, 26 points" / pt-BR "Extra extragrande, 26 pontos" |
| `readerSettings.lineSpacing.sectionLabel` | Section label | Line spacing | Interligne | Espaçamento entre linhas | — |
| `readerSettings.lineSpacing.compact` | Option label | Compact | Compact | Compacto | — |
| `readerSettings.lineSpacing.normal` | Option label | Normal | Normal | Normal | — |
| `readerSettings.lineSpacing.relaxed` | Option label | Relaxed | Détendu | Relaxado | Default |
| `readerSettings.lineSpacing.airy` | Option label | Airy | Aéré | Espaçado | — |
| `readerSettings.theme.sectionLabel` | Section label | Theme | Thème | Tema | — |
| `readerSettings.theme.selected.hint` | VoiceOver hint | Currently selected | Actuellement sélectionné | Selecionado atualmente | — |
| `readerSettings.margins.sectionLabel` | Section label | Margins | Marges | Margens | — |

---

## 5. Settings (Modal)

> **Corrected during step 4 view-wiring pass:** the original rows below described an earlier Folder/Appearance/About structure that no longer matches the shipped `SettingsView` (which has Reading/Storage/About/Privacy sections). Rows are corrected to the actual shipped copy; net-new rows are flagged in Notes.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `settings.title` | Navigation title | Settings | Réglages | Configurações | — |
| `settings.section.reading` | Section header | Reading | Lecture | Leitura | Corrected — net-new section, didn't exist in original audit. |
| `settings.font.sectionLabel` | Section label above font list | Font | Police | Fonte | — |
| `settings.font.preview` | Sample sentence shown per font option | The quick brown fox jumps over the lazy dog | Portez ce vieux whisky au juge blond qui fume | Um pequeno jabuti xereta viu dez cegonhas felizes | Locale-appropriate pangram, not a literal translation — each locale uses its own classic pangram so every letterform is previewed. |
| `settings.fontSize.sectionLabel` | Section label, stepper row | Size | Taille | Tamanho | — |
| `settings.fontSize.valueLabel` | Stepper value label (appended after number) | {size}pt | {size}pt | {size}pt | "pt" is a standard typographic abbreviation, invariant across locales. |
| `settings.section.storage` | Section header | Storage | Stockage | Armazenamento | — |
| `settings.folder.rowLabel` | Row label | Articles folder | Dossier des articles | Pasta de artigos | Corrected from "Reading folder" to match shipped copy. |
| `settings.folder.emptyValue` | Row sub-label (no folder set) | Not set | Non défini | Não definida | Corrected from "Not configured" to match shipped copy. |
| `settings.import.rowLabel` | Row label | Import Articles | Importer des articles | Importar artigos | — |
| `settings.section.about` | Section header | About | À propos | Sobre | — |
| `settings.about.versionRowLabel` | Row label (links to About page) | Version {version} | Version {version} | Versão {version} | — |
| `settings.privacyPolicy.rowLabel` | Row label (links to Privacy Policy page) | Privacy Policy | Politique de confidentialité | Política de Privacidade | Distinct row/casing from `about.privacyPolicy.rowLabel` ("Privacy policy") — same destination, surfaced directly in Settings as well as inside the About sub-page; not deduplicated since they're different controls authored independently. |
| `settings.section.privacy` | Section header | Privacy | Confidentialité | Privacidade | — |
| `settings.analytics.rowLabel` | Row label, analytics toggle | Share anonymous data | Partager des données anonymes | Compartilhar dados anônimos | — |
| `settings.analytics.subtitle` | Row sub-label, analytics toggle | No personal info or article content, ever. | Aucune information personnelle ni contenu d'article, jamais. | Nenhuma informação pessoal ou conteúdo de artigo, nunca. | — |

### Language Picker (FAB-284)

> Added for FAB-284 (in-app language picker, iOS + Web). New **General** section sits above **Reading** in Settings. `fr-CA`/`pt-BR` translations below are a first draft — they have not been through the formal linguistic-review pass FAB-275 step 7 gave the rest of this file (see `docs/copy/UI_COPY_LINGUISTIC_REVIEW_fr-CA.md` / `_pt-BR.md`); worth a look before this ships.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `settings.section.general` | Section header | General | Général | Geral | New section, sits above `settings.section.reading`. |
| `settings.language.sectionLabel` | Section label above language list | Language | Langue | Idioma | — |
| `language.automatic` | Language option label | Automatic | Automatique | Automático | Reverts to auto-detecting the device/browser language rather than pinning one. |
| `language.en` | Language option label | English | English | English | Autonym, invariant — language names in a picker are shown in their own language regardless of active UI locale (matches Apple's own Language & Region picker), so a reader scanning in any language still recognizes their own. |
| `language.frCA` | Language option label | Français (Canada) | Français (Canada) | Français (Canada) | Autonym, invariant — see `language.en`. |
| `language.ptBR` | Language option label | Português (Brasil) | Português (Brasil) | Português (Brasil) | Autonym, invariant — see `language.en`. |
| `settings.language.restartTitle` | Alert title, shown after picking a different language | Restart Verso | Redémarrer Verso | Reiniciar o Verso | True in-app language switching without relaunch isn't supported — closing/reopening is required for the new language to take effect. |
| `settings.language.restartMessage` | Alert message | Close and reopen the app to apply your language change. | Ferme et rouvre l'appli pour appliquer ton changement de langue. | Feche e reabra o app para aplicar a mudança de idioma. | — |
| `settings.language.restartButton` | Alert dismiss button | OK | OK | OK | — |

### Privacy Policy Screen

> Added during step 4 view-wiring pass — the destination screen opened by `settings.privacyPolicy.rowLabel` / `about.privacyPolicyLinkLabel` had no key of its own for its nav bar title.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `privacyPolicy.navTitle` | Nav bar title | Privacy Policy | Politique de confidentialité | Política de Privacidade | Same text as `settings.privacyPolicy.rowLabel`, kept as a separate key since a nav title and a row label are different copy slots. |

### Change Folder Dialog

> **Corrected during step 4 view-wiring pass:** the shipped confirmation dialog splits the question (title) from the reassurance copy (message) differently than originally drafted, and uses different button wording. Rows below match the shipped copy.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `dialog.changeFolder.title` | Dialog title | Move your existing articles to the new folder? | Déplacer tes articles existants vers le nouveau dossier? | Mover seus artigos existentes para a nova pasta? | Corrected to match shipped copy. |
| `dialog.changeFolder.message` | Dialog message | Your old folder won't be touched if you choose No. | Ton ancien dossier ne sera pas touché si tu choisis Non. | Sua pasta antiga não será alterada se você escolher Não. | Corrected to match shipped copy. |
| `dialog.changeFolder.yes` | Confirm button | Move Articles | Déplacer les articles | Mover Artigos | Corrected to match shipped copy (Title Case). |
| `dialog.changeFolder.no` | Secondary button | Keep in Old Folder | Garder dans l'ancien dossier | Manter na pasta antiga | Corrected to match shipped copy. |
| `dialog.changeFolder.cancel` | Cancel button | Cancel | Annuler | Cancelar | — |

### Import (In-App)

> Added during step 4 view-wiring pass — `ImportView.swift`'s entire idle/parsing/writing/done/failed flow was missing from this doc; only the Settings row label (`settings.import.rowLabel`) that opens it had been documented.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `import.close.accessibilityHint` | Close (X) toolbar button VoiceOver hint | Dismiss import sheet | Fermer la feuille d'importation | Fechar a tela de importação | Close (X) button itself reuses `addArticle.close.accessibilityLabel` ("Close") — identical wording/affordance across sheets. |
| `import.idle.headline` | Idle state headline | Import Articles | Importer des articles | Importar artigos | Coincidentally matches `settings.import.rowLabel`'s wording today, but kept as a separate key — a settings row label and a screen headline are different copy slots that could diverge independently. |
| `import.idle.subtitle` | Idle state subtitle | Import your reading list from GoodLinks, Instapaper, Pocket, Readwise Reader, or Matter. | Importe ta liste de lecture depuis GoodLinks, Instapaper, Pocket, Readwise Reader ou Matter. | Importe sua lista de leitura do GoodLinks, Instapaper, Pocket, Readwise Reader ou Matter. | Third-party product names invariant. |
| `import.idle.noFolderWarning` | Idle state warning, shown only when no articles folder is set | Set your articles folder in Storage settings before importing. | Définis ton dossier d'articles dans les réglages Stockage avant d'importer. | Defina sua pasta de artigos nas configurações de Armazenamento antes de importar. | — |
| `import.idle.selectFileButton` | Idle state primary CTA | Select Export File | Sélectionner le fichier d'exportation | Selecionar arquivo de exportação | — |
| `import.parsing.message` | Parsing state message | Reading file… | Lecture du fichier… | Lendo arquivo… | — |
| `import.writing.message` | Writing state message | Importing articles… | Importation des articles… | Importando artigos… | — |
| `import.done.headline` | Done state headline | Import Complete | Importation terminée | Importação concluída | — |
| `import.done.summary` | Done state summary, imported count | {count} articles imported | {count} articles importés | {count} artigos importados | ⚠️ plural (this row shows the "other"/plural form; singular "one" form authored directly in codegen, same pattern as the other ⚠️-flagged keys). Shipped code composes this with an optional `import.done.skippedSuffix` clause, then a literal "." — both pieces need independent plural handling since "imported" and "skipped" each agree with their own count. |
| `import.done.skippedSuffix` | Done state, optional skipped clause appended after the summary (only when skipped > 0) | , {count} skipped | , {count} ignorés | , {count} ignorados | ⚠️ plural; see `import.done.summary`. |
| `import.done.doneButton` | Done state primary button | Done | OK | OK | — |
| `import.done.importAnotherButton` | Done state secondary button | Import Another File | Importer un autre fichier | Importar outro arquivo | — |
| `import.failed.headline` | Failed state headline | Import Failed | Importation échouée | Falha na importação | — |

---

## 6. About (Settings Sub-page)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `about.title` | Page title | About Verso | À propos de Verso | Sobre o Verso | — |
| `about.version.rowLabel` | Row label | Version | Version | Versão | Sub-label: `{version} ({build})` (digits/format unchanged across locales) |
| `about.acknowledgements.rowLabel` | Row label | Open-source acknowledgements | Remerciements open source | Agradecimentos de código aberto | — |
| `about.github.rowLabel` | Row label | View on GitHub | Voir sur GitHub | Ver no GitHub | `GitHub` invariant |
| `about.privacyPolicy.rowLabel` | Row label | Privacy policy | Politique de confidentialité | Política de privacidade | — |
| `about.footer` | Copyright footer | Verso {version} · Built with care | Verso {version} · Conçu avec soin | Verso {version} · Feito com cuidado | `Verso` invariant |

AboutView was rebuilt to match this spec (FAB-279). The interim keys (`about.navTitle`, `about.brandName`, `about.versionLabel`, `about.description`, `about.githubLinkLabel`, `about.privacyPolicyLinkLabel`) are retired — the view now uses the spec keys above.

---

## 7. Share Extension

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `share.title` | Sheet title | Save to Verso | Enregistrer dans Verso | Salvar no Verso | `Verso` invariant |
| `share.preview.loading.accessibilityLabel` | Loading shimmer | Loading article preview | Chargement de l'aperçu de l'article | Carregando pré-visualização do artigo | — |
| `share.save.default` | Save button | Save | Enregistrer | Salvar | — |
| `share.save.loading` | Save button (in progress) | Saving… | Enregistrement… | Salvando… | — |
| `share.save.success` | Save button (done) | Saved | Enregistré | Salvo | — |
| `share.save.error` | Save button (failed) | Try again | Réessayer | Tentar novamente | — |
| `share.cancel` | Cancel button | Cancel | Annuler | Cancelar | — |
| `share.error.noFolder.message` | No-folder-configured message | Folder not configured. | Dossier non configuré. | Pasta não configurada. | — |
| `share.error.noFolder.cta` | No-folder-configured link | Open Verso to finish setup | Ouvrir Verso pour terminer la configuration | Abrir o Verso para concluir a configuração | `Verso` invariant |

> **Note:** `share.error.couldNotParse` and `share.error.openInSafari` are superseded by `share.error.*` keys in §9 (Scenario 8).

---

## 8. Error & System Messages

Full UI treatments and component specs: see `docs/ERROR_STATES_SPEC.md`.

### Offline / Network (Scenario 1)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `error.offline.banner.headline` | Inline banner headline | You're offline. | Tu es hors ligne. | Você está off-line. | — |
| `error.offline.banner.subheadline` | Inline banner subheadline | Saved articles are still available. | Les articles enregistrés restent disponibles. | Os artigos salvos continuam disponíveis. | — |
| `error.offline.articleUnavailable` | Article row (unavailable article) | Not available offline. | Non disponible hors ligne. | Não disponível off-line. | Greyed-out row only |

### Parsing Failed (Scenario 2)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `error.parsing.headline` | Bottom sheet headline | Couldn't read this article. | Impossible de lire cet article. | Não foi possível ler este artigo. | — |
| `error.parsing.subheadline` | Bottom sheet subheadline | The page may be behind a paywall or require a login. | La page est peut-être derrière un mur payant ou exige une connexion. | A página pode estar atrás de um paywall ou exigir login. | — |
| `error.parsing.openInSafari` | Primary CTA | Open in Safari | Ouvrir dans Safari | Abrir no Safari | Accent fill; `Safari` invariant |
| `error.parsing.dismiss` | Secondary CTA | Dismiss | Fermer | Descartar | — |

### Folder Not Configured (Scenario 3)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `error.noFolder.headline` | Full-screen error headline | No folder selected. | Aucun dossier sélectionné. | Nenhuma pasta selecionada. | — |
| `error.noFolder.subheadline` | Full-screen error subheadline | Choose a folder in iCloud Drive to start saving articles. | Choisis un dossier dans iCloud Drive pour commencer à enregistrer des articles. | Escolha uma pasta no iCloud Drive para começar a salvar artigos. | — |
| `error.noFolder.cta` | CTA button | Choose folder | Choisir un dossier | Escolher pasta | — |

### Folder Not Found (Scenario 4)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `error.folderMissing.headline` | Full-screen error headline | Folder not found. | Dossier introuvable. | Pasta não encontrada. | — |
| `error.folderMissing.subheadline` | Full-screen error subheadline | The folder may have been moved or deleted. Choose a new one to continue. | Le dossier a peut-être été déplacé ou supprimé. Choisis-en un nouveau pour continuer. | A pasta pode ter sido movida ou excluída. Escolha uma nova para continuar. | — |
| `error.folderMissing.cta` | CTA button | Choose new folder | Choisir un nouveau dossier | Escolher nova pasta | — |

### iCloud Unavailable (Scenario 5)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `error.iCloudUnavailable.headline` | Inline banner headline | iCloud Drive is unavailable. | iCloud Drive est indisponible. | O iCloud Drive está indisponível. | `iCloud Drive` invariant |
| `error.iCloudUnavailable.subheadline` | Inline banner subheadline | Go to Settings → [Your Name] → iCloud to re-enable it. | Va dans Réglages → [Your Name] → iCloud pour le réactiver. | Vá em Configurações → [Your Name] → iCloud para reativá-lo. | `[Your Name]` is **intentional** in all locales — it matches Apple's on-screen label for the device-owner row in iOS Settings. Keep the placeholder; do not insert a real name. Translators should match Apple's localized Settings path wording for "Réglages"/"Configurações" once confirmed against an fr-CA/pt-BR device — flag for step 7 QA. |

### File Write Error (Scenario 6)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `error.fileWrite.message` | Toast message | Couldn't save article. | Impossible d'enregistrer l'article. | Não foi possível salvar o artigo. | 3s auto-dismiss |
| `error.fileWrite.subtext` | Toast subtext | Check that your folder is accessible and try again. | Vérifie que ton dossier est accessible et réessaie. | Verifique se sua pasta está acessível e tente novamente. | — |

### File Read Error (Scenario 7)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `error.fileRead.headline` | Inline reading view | This article couldn't be loaded. | Cet article n'a pas pu être chargé. | Não foi possível carregar este artigo. | — |
| `error.fileRead.cta` | Text button | Open original | Ouvrir l'original | Abrir original | Opens sourceURL in Safari |

### Share Extension — Parse Failure (Scenario 8)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `share.error.headline` | Share sheet error state | Couldn't save this article. | Impossible d'enregistrer cet article. | Não foi possível salvar este artigo. | Replaces §8 `share.error.couldNotParse` |
| `share.error.subheadline` | Share sheet error subheadline | The page couldn't be read. You can open it directly in Safari. | La page n'a pas pu être lue. Tu peux l'ouvrir directement dans Safari. | A página não pôde ser lida. Você pode abri-la diretamente no Safari. | `Safari` invariant |
| `share.error.openInSafari` | Primary CTA | Open in Safari | Ouvrir dans Safari | Abrir no Safari | Accent color |
| `share.error.dismiss` | Secondary CTA | Dismiss | Fermer | Descartar | — |

### Share Extension — Duplicate URL

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `share.duplicate.headline` | Share sheet duplicate state | Article already saved | Article déjà enregistré | Artigo já salvo | — |
| `share.duplicate.subheadline` | Body copy | This link is already in your library as "{existingTitle}". | Ce lien est déjà dans ta bibliothèque sous le nom « {existingTitle} ». | Este link já está na sua biblioteca como "{existingTitle}". | `{existingTitle}` from existing file frontmatter; fr-CA uses guillemets « » per Québec French convention |
| `share.duplicate.updateExisting` | Primary button | Update existing | Mettre à jour l'existant | Atualizar existente | — |
| `share.duplicate.saveCopy` | Secondary button | Save as copy | Enregistrer une copie | Salvar como cópia | Appends ` (Copy)` to title (or ` 2` after existing ` (Copy)`) — fr-CA/pt-BR suffix wording TBD in step 7 (e.g. ` (Copie)` / ` (Cópia)`) |
| `share.duplicate.cancel` | Text button | Cancel | Annuler | Cancelar | Completes extension without writing pending JSON |
| `share.duplicate.success.saved` | Success headline | Saved | Enregistré | Salvo | New file |
| `share.duplicate.success.updated` | Success headline | Updated | Mis à jour | Atualizado | Replaced existing file |

### Add Article — Duplicate URL

In-app **Add Article** uses the same headline, subheadline, and button labels as the share duplicate flow for consistency. Future `Localizable.strings` keys may use the `addArticle.duplicate.*` prefix.

### File Adopted (Manually-Added Note)

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `notice.fileAdopted.message` | One-time notice | Verso added reading metadata to this note and renamed it to match your library. | Verso a ajouté des métadonnées de lecture à cette note et l'a renommée pour qu'elle corresponde à ta bibliothèque. | O Verso adicionou metadados de leitura a esta nota e a renomeou para corresponder à sua biblioteca. | Shown once, the first time Verso adopts a manually-added/foreign `.md` file (FAB-290) — never silent. Exact placement (toast vs. one-time modal vs. row subtitle) is still an open question; current build shows it as a one-time alert. |
| `notice.fileAdopted.dismiss` | Alert button | OK | OK | OK | Invariant — standard alert acknowledgement across all three locales |

### Generic Fallback

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `error.generic` | Last-resort fallback | Something went wrong. Please try again. | Une erreur s'est produite. Réessaie. | Algo deu errado. Tente novamente. | — |

---

## 9. Accessibility-Only Labels (VoiceOver)

These strings are never visible on screen. They are set via `.accessibilityLabel` / `.accessibilityHint` in code.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `a11y.articleRow.hint` | Article list row hint | Double tap to open | Touche deux fois pour ouvrir | Toque duas vezes para abrir | — |
| `a11y.articleRow.label` | Article list row label | {title}, {source}, {estimatedReadTime} | {title}, {source}, {estimatedReadTime} | {title}, {source}, {estimatedReadTime} | Dynamic — composed from already-translated fragments, no literal text to translate |
| `a11y.filterChip.selected` | Selected filter chip hint | Currently selected | Actuellement sélectionné | Atualmente selecionado | — |
| `a11y.filterChip.unselected` | Unselected filter chip hint | Double tap to filter | Touche deux fois pour filtrer | Toque duas vezes para filtrar | — |
| `a11y.themeChip.selected` | Selected theme chip hint | Currently selected | Actuellement sélectionné | Atualmente selecionado | — |
| `a11y.themeChip.unselected` | Unselected theme chip hint | Double tap to select | Touche deux fois pour sélectionner | Toque duas vezes para selecionar | — |
| `a11y.fontOption.selected` | Selected font option announcement | {fontName}, selected | {fontName}, sélectionné | {fontName}, selecionado | — |
| `a11y.fontOption.unselected` | Unselected font option | {fontName} | {fontName} | {fontName} | Font names are invariant |
| `a11y.fontSize.label` | Font size step label | {label}, {points} points | {label}, {points} points | {label}, {points} pontos | e.g. "Medium, 18 points" → "Moyen, 18 points" → "Médio, 18 pontos". `{label}` is the full-word size name (Extra small/Small/Medium/…), not the XS/S/M abbreviation — see §4 Reader Settings open question |
| `a11y.fontSize.default` | Default size annotation | {label}, {points} points, default | {label}, {points} points, par défaut | {label}, {points} pontos, padrão | e.g. "Medium, 18 points, default" |
| `a11y.progress.label` | Scroll progress bar | Reading progress | Progression de lecture | Progresso de leitura | — |
| `a11y.progress.value` | Scroll progress bar value | {N} percent | {N} pour cent | {N} por cento | Corrected during step 4 view-wiring pass: doc previously specified "{N} minutes remaining" with full plural handling, but shipped code reads out scroll percentage, not estimated time remaining. "Percent" doesn't inflect by count in en/fr-CA/pt-BR, so no plural variant needed. Wiring ScrollProgress.swift to a real time-remaining announcement is a possible future enhancement — see docs/BACKLOG.md. |
| `a11y.skeletonLoading` | Skeleton list | Loading articles | Chargement des articles | Carregando artigos | — |
| `a11y.deleteAction` | Swipe-delete action | Delete article | Supprimer l'article | Excluir artigo | — |
| `a11y.archiveAction` | Swipe-archive action | Archive article | Archiver l'article | Arquivar artigo | — |
| `a11y.unarchiveAction` | Swipe-unarchive action | Unarchive article | Désarchiver l'article | Desarquivar artigo | — |

---

## 10. Launch Screen

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `launch.brandName` | Splash screen brand text (under app icon) | Verso | Verso | Verso | Invariant — brand name. Added during step 4 view-wiring pass — `LaunchView.swift` had no UI_COPY entry yet. |

---

## 11. Web-Only Strings

> Added during step 5 web-wiring pass. Verso Web has a handful of surfaces with no iOS
> counterpart at all (a desktop font-family picker, a "this browser isn't supported"
> screen, single-string error states on the reader page where iOS uses a structured
> headline/subheadline/cta error view instead). Per the step-5 plan, everywhere a real
> iOS equivalent existed, Web's copy was changed to match it instead of adding a new key
> here — these rows are only the genuinely Web-specific remainder. All fr-CA/pt-BR here
> are first-pass translations, needs_review.

| Key | Location | en | fr-CA | pt-BR | Notes |
|-----|----------|----|-------|-------|-------|
| `web.unsupportedBrowser.headline` | Full-screen notice when File System Access API is unavailable | Browser not supported | Navigateur non pris en charge | Navegador não compatível | — |
| `web.unsupportedBrowser.subheadline` | Same screen, body copy | Verso Web uses the File System Access API, which requires Chrome or Edge 86+. Please open this page in a supported browser. | Verso Web utilise l'API File System Access, qui nécessite Chrome ou Edge 86+. Ouvre cette page dans un navigateur pris en charge. | O Verso Web usa a File System Access API, que requer Chrome ou Edge 86+. Abra esta página em um navegador compatível. | `Verso Web`, `File System Access API`, `Chrome`, `Edge` invariant. |
| `web.changeFolder.label` | Link below the article list to re-pick the library folder | Change folder | Changer de dossier | Alterar pasta | — |
| `web.fontFamily.system` | Font-family option label | System | Système | Sistema | — |
| `web.fontFamily.mono` | Font-family option label | Mono | Mono | Mono | — |
| `web.fontFamily.georgia` | Font-family option label | Georgia | Georgia | Georgia | Invariant — font name. |
| `web.fontFamily.dyslexic` | Font-family option label | OpenDyslexic | OpenDyslexic | OpenDyslexic | Invariant — brand name (see `docs/LOCALIZATION.md` §4). Renamed from the shipped "Dyslexic" to the actual font name. |
| `web.reader.toggleControls.show` | Reader-screen "Aa" button tooltip when controls are hidden | Show controls | Afficher les commandes | Mostrar controles | — |
| `web.reader.toggleControls.hide` | Reader-screen "Aa" button tooltip when controls are visible | Hide controls | Masquer les commandes | Ocultar controles | — |
| `web.reader.backButton.label` | Reader-screen back link (visible text, the "←" glyph is decorative and not part of the translated string) | Library | Bibliothèque | Biblioteca | — |
| `web.reader.error.noFolder` | Reader-screen error when no folder is bookmarked | No folder selected. Go back and choose your library folder. | Aucun dossier sélectionné. Reviens en arrière et choisis ton dossier de bibliothèque. | Nenhuma pasta selecionada. Volte e escolha a pasta da sua biblioteca. | Distinct from `error.noFolder.*` (home-screen full error view, headline/subheadline/cta) — this is a single inline string on the reader page. |
| `web.reader.error.permissionDenied` | Reader-screen error when folder permission was revoked | Folder permission denied. Go back and re-select your library. | Autorisation du dossier refusée. Reviens en arrière et resélectionne ta bibliothèque. | Permissão da pasta negada. Volte e selecione novamente sua biblioteca. | — |
| `web.reader.error.articleNotFound` | Reader-screen error when the file isn't found in the folder | Article not found: {filename} | Article introuvable : {filename} | Artigo não encontrado: {filename} | `{filename}` not translated. |
| `web.reader.error.loadFailed` | Reader-screen generic load failure (caught exception, no specific message) | Failed to load article | Échec du chargement de l'article | Falha ao carregar o artigo | — |
| `web.reader.error.fallback` | Reader-screen fallback when article is missing with no specific error | Article not found. | Article introuvable. | Artigo não encontrado. | — |
| `web.reader.backToLibrary.label` | Link shown alongside the reader-screen error state (the "←" glyph is decorative) | Back to library | Retour à la bibliothèque | Voltar para a biblioteca | — |
