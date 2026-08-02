# Verso — Revisão Linguística (pt-BR)

**Idioma:** `pt-BR` (Português Brasileiro)  
**Revisor:** Claude (revisão assistida por IA) — aguardando aprovação final do Fabio  
**Data:** 21 de junho de 2026  
**Status:** `Em revisão`

Obrigado por revisar as traduções do **Verso**, um leitor minimalista de artigos para iOS e Web. O aplicativo usa um vocabulário pequeno e consistente — cerca de 280 strings no total. Este documento guia você por cada seção.

**Instruções:**
- Leia cada string em inglês e sua tradução. Se a tradução estiver natural e correta, marque `[✓]`. Se algo estiver errado (palavra incorreta, formulação não natural, registro inadequado, acento faltando, problema de formatação), marque `[✗]` e escreva sua correção na margem ou no final da seção.
- Preste **atenção especial** às seções marcadas **⚠️ plurais** — o português brasileiro trata `0` como plural. O framework lida com isso automaticamente, mas o texto precisa funcionar em qualquer quantidade.
- Ao final, preencha a tabela **Resumo das Alterações** com todas as correções propostas.

---

## 1. Integração

### OB-1 · Boas-vindas

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `onboarding.welcome.headline` | Your articles. Your files. | *Seus artigos. Seus arquivos.* | Frase curta e direta — verificar concordância de gênero |
| ✓ | `onboarding.welcome.subheadline` | A quiet place to read. No accounts, no algorithms — just Markdown files in your iCloud Drive. | *Um lugar tranquilo para ler. Sem contas, sem algoritmos — apenas arquivos Markdown no seu iCloud Drive.* | `iCloud Drive` é invariante — não traduzir |
| ✓ | `onboarding.welcome.cta` | Get started | *Começar* | Verificar se funciona como botão CTA principal |

### OB-2 · Seletor de tema

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `onboarding.theme.headline` | Choose your reading theme | *Escolha seu tema de leitura* | Verificar consistência do registro `você` em todo o fluxo |
| ✗ | `onboarding.theme.subheadline` | You can change this any time from settings. | *Você pode alterar isso a qualquer momento nas configurações.* | Resolvido: aqui "configurações" é a tela interna do Verso (não o app da Apple, que se chama "Ajustes" — ver item 16). Correção de registro — ✗ ver correção nº 1 no Resumo. |
| ✓ | `onboarding.theme.continue` | Continue | *Continuar* | — |
| ✓ | `theme.paper` | Paper | *Papel* | — |
| ✓ | `theme.sepia` | Sepia | *Sépia* | Confirmado — é proparoxítona (sé-pi-a), acento obrigatório. |
| ✓ | `theme.night` | Night | *Noite* | — |
| ✓ | `theme.ink` | Ink | *Tinta* | — |

### OB-3 · Configuração da pasta

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✗ | `onboarding.folder.headline` | Where should Verso save your articles? | *Onde o Verso deve guardar seus artigos?* | `Verso` invariante. ✗ ver correção nº 2 no Resumo. |
| ✓ | `onboarding.folder.subheadline` | Pick a folder in iCloud Drive. Verso saves each article as a Markdown file you can open anywhere. | *Escolha uma pasta no iCloud Drive. O Verso salva cada artigo como um arquivo Markdown que você pode abrir em qualquer lugar.* | `iCloud Drive`, `Markdown` invariantes |
| ✓ | `onboarding.folder.chooseCta` | Choose folder… | *Escolher pasta…* | As reticências `…` devem ser três pontos `…`, não três pontos `...` |
| ✓ | `onboarding.folder.continueCta` | Continue | *Continuar* | — |
| ✗ | `onboarding.folder.privacyNote` | Verso never uploads your files. They live in your iCloud Drive. | *O Verso nunca envia seus arquivos para a nuvem. Eles ficam no seu iCloud Drive.* | A frase se contradiz (iCloud Drive também é nuvem). ✗ ver correção nº 3 no Resumo. |
| ✓ | `onboarding.folder.obsidianTip` | Using Obsidian? Point Verso to a folder inside your vault and articles will appear there automatically. | *Usa o Obsidian? Aponte o Verso para uma pasta dentro do seu vault e os artigos vão aparecer lá automaticamente.* | `Obsidian`, `Verso` invariantes. `vault` mantido em inglês — confirmado, é o termo usado sem tradução pela comunidade Obsidian brasileira. |

### OB-4 · Tour guiado

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `onboarding.tour.headline` | Here's how it works | *Veja como funciona* | — |
| ✗ | `onboarding.tour.step1` | Share any article from Safari or your browser to save it instantly. | *Compartilhe qualquer artigo do Safari ou do seu navegador para salvá-lo instantaneamente.* | `Safari` invariante. ✗ ver correção nº 4 no Resumo (registro mais coloquial). |
| ✓ | `onboarding.tour.step2` | Open Verso to read. Your list is always in sync with your files. | *Abra o Verso para ler. Sua lista está sempre sincronizada com seus arquivos.* | — |
| ✗ | `onboarding.tour.step3` | Mark articles as read when you're done. They stay in your folder forever. | *Marque os artigos como lidos quando terminar. Eles permanecem na sua pasta para sempre.* | ✗ ver correção nº 5 no Resumo (registro mais coloquial). |
| ✓ | `onboarding.tour.skip` | Skip | *Pular* | — |
| ✓ | `onboarding.tour.startReading` | Start reading | *Começar a ler* | — |

### OB-5 · Consentimento de análise

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `onboarding.analyticsConsent.headline` | Help make Verso better | *Ajude a melhorar o Verso* | — |
| ✓ | `onboarding.analyticsConsent.subheadline` | Share anonymous usage data — no personal info, no article content, ever. | *Compartilhe dados de uso anônimos — sem informações pessoais, sem conteúdo de artigos, nunca.* | — |
| ✓ | `onboarding.analyticsConsent.acceptCta` | Sure, why not | *Claro, por que não* | Confirmado — funciona bem; é a única CTA com tom propositalmente informal do app, então a regra de manter botões padronizados não se aplica aqui. |
| ✓ | `onboarding.analyticsConsent.declineCta` | No thanks | *Não, obrigado* | — |

---

## 2. Início · Lista de artigos

### Navegação e busca

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `home.navTitle` | Verso | *Verso* | **Invariante** — nome da marca |
| ✓ | `home.settings.accessibilityLabel` | Settings | *Configurações* | Rótulo de acessibilidade (VoiceOver) |
| ✓ | `home.search.placeholder` | Search titles, text, or site… | *Buscar títulos, texto ou site…* | Tradução correta. Risco de truncamento é uma questão de layout, não de idioma — verificar em dispositivo/Figma. |
| ✓ | `home.search.cancel` | Cancel | *Cancelar* | — |

### Filtro de data

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `home.dateFilter.label` | Added | *Adicionado* | — |
| ✓ | `home.dateFilter.any` | Any time | *Qualquer período* | — |
| ✓ | `home.dateFilter.week` | Past week | *Última semana* | — |
| ✓ | `home.dateFilter.month` | Past month | *Último mês* | — |
| ✓ | `home.dateFilter.year` | Past year | *Último ano* | — |

### Filtro de etiquetas

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `home.tagFilter.button.accessibilityLabel` | Filter by tags | *Filtrar por etiquetas* | — |
| ✓ | `home.tagFilter.title` | Tags | *Etiquetas* | — |
| ✓ | `home.tagFilter.searchPlaceholder` | Search tags… | *Buscar etiquetas…* | — |
| ✓ | `home.tagFilter.allTags` | All tags | *Todas as etiquetas* | — |
| ✓ | `home.tagFilter.noMatches` | No matching tags | *Nenhuma etiqueta correspondente* | — |

### Filtros (chips) ⚠️ MAIOR RISCO DE TRUNCAMENTO

Estes elementos aparecem como chips compactos. O português é ~15–30% mais longo que o inglês.

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `filter.all` | All | *Todos* | — |
| ✓ | `filter.unread` | Unread | *Não lidos* | Tradução correta e mais curta possível em pt-BR (evitei o padrão "a ler", que é português europeu). ~2× o comprimento em inglês — verificar se cabe no chip em dispositivo/Figma. |
| ✓ | `filter.reading` | Reading | *Lendo* | — |
| ✓ | `filter.read` | Read | *Lidos* | — |
| ✓ | `filter.archived` | Archived | *Arquivados* | — |

### ⚠️ Chaves plurais — verificar cada quantidade (0, 1, 2, 5)

**Regra crítica:** O português brasileiro trata `0` como plural. Exemplo esperado: « 0 artigos » / « 1 artigo » / « 5 artigos ».

| ✓ | Chave | Inglês (other) | Tradução (other) | Quantidade → resultado |
|---|-------|----------------|-------------------|------------------------|
| ✓ | `filter.unread.accessibilityLabel` | Unread, {count} articles | *Não lidos, {count} artigos* | 0 : *Não lidos, 0 artigos* · 1 : *Não lidos, 1 artigo* · 2 : *Não lidos, 2 artigos* · 5 : *Não lidos, 5 artigos* |
| ✓ | `filter.reading.accessibilityLabel` | Reading, {count} articles | *Lendo, {count} artigos* | 0 : *Lendo, 0 artigos* · 1 : *Lendo, 1 artigo* · 2 : *Lendo, 2 artigos* · 5 : *Lendo, 5 artigos* |
| ✓ | `filter.read.accessibilityLabel` | Read, {count} articles | *Lidos, {count} artigos* | 0 : *Lidos, 0 artigos* · 1 : *Lidos, 1 artigo* · 2 : *Lidos, 2 artigos* · 5 : *Lidos, 5 artigos* |
| ✓ | `filter.archived.accessibilityLabel` | Archived, {count} articles | *Arquivados, {count} artigos* | 0 : *Arquivados, 0 artigos* · 1 : *Arquivados, 1 artigo* · 2 : *Arquivados, 2 artigos* · 5 : *Arquivados, 5 artigos* |
| ✓ | `dialog.bulkDelete.title` | Delete {count} articles? | *Excluir {count} artigos?* | 0 : *Excluir 0 artigos?* · 1 : *Excluir 1 artigo?* · 2 : *Excluir 2 artigos?* · 5 : *Excluir 5 artigos?* |
| ✓ | `import.done.summary` | {count} articles imported | *{count} artigos importados* | 0 : *0 artigos importados* · 1 : *1 artigo importado* · 2 : *2 artigos importados* · 5 : *5 artigos importados* — ⚠️ confirmar que o framework flexiona também o participle ("importado/importados"), não só o substantivo |
| ✓ | `import.done.skippedSuffix` | , {count} skipped | *, {count} ignorados* | 0 : *, 0 ignorados* · 1 : *, 1 ignorado* · 2 : *, 2 ignorados* · 5 : *, 5 ignorados* — mesma ressalva do item acima |

### Cartão de artigo

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `articleCard.estimatedReadTime` | {N} min read | *{N} min de leitura* | Confirmado — não precisa de variantes plurais; "min" é abreviatura invariável em qualquer quantidade. |
| ✓ | `articleCard.accessibilityHint` | Double tap to open | *Toque duas vezes para abrir* | — |

### Estados vazios

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `home.empty.noArticles.headline` | No articles yet | *Nenhum artigo ainda* | — |
| ✓ | `home.empty.noArticles.subheadline` | Share an article from Safari to get started. | *Compartilhe um artigo do Safari para começar.* | Nota: o Web também mostra isso, mas não tem extensão de compartilhamento — problema conhecido, fora do escopo desta revisão |
| ✓ | `home.empty.noResults.headline` | No results | *Nenhum resultado* | — |
| ✓ | `home.empty.noResults.subheadline` | Try a different search term. | *Tente outro termo de busca.* | — |
| ✓ | `home.empty.archive.headline` | Nothing archived | *Nada arquivado* | — |
| ✓ | `home.empty.archive.subheadline` | Articles you archive will appear here. | *Os artigos que você arquivar vão aparecer aqui.* | — |
| ✗ | `home.empty.noUnread.headline` *(Web)* | Nothing unread | *Nenhum artigo não lido* | ✗ ver correção nº 6 no Resumo (inconsistente com os irmãos "Nada em andamento"/"Nada lido ainda"). |
| ✓ | `home.empty.noReading.headline` *(Web)* | Nothing in progress | *Nada em andamento* | Revisado — ok. |
| ✓ | `home.empty.noRead.headline` *(Web)* | Nothing read yet | *Nada lido ainda* | Revisado — ok. |

### Ações por deslize

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `swipe.delete` | Delete | *Excluir* | Ação destrutiva — confirmar que a gravidade está clara |
| ✓ | `swipe.archive` | Archive | *Arquivar* | — |
| ✓ | `swipe.unarchive` | Unarchive | *Desarquivar* | — |
| ✓ | `swipe.markRead` | Mark Read | *Marcar como lido* | — |
| ✓ | `swipe.markUnread` | Mark Unread | *Marcar como não lido* | — |

### Menu de contexto

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `contextMenu.open` | Open | *Abrir* | — |
| ✓ | `contextMenu.archive` | Archive | *Arquivar* | — |
| ✓ | `contextMenu.markAsRead` | Mark as read | *Marcar como lido* | — |
| ✓ | `contextMenu.markAsUnread` | Mark as unread | *Marcar como não lido* | — |
| ✓ | `contextMenu.delete` | Delete | *Excluir* | Destrutivo |

### Diálogo de confirmação de exclusão

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `dialog.deleteArticle.title` | Delete article? | *Excluir artigo?* | — |
| ✓ | `dialog.deleteArticle.message` | This cannot be undone. The file will be permanently removed from your iCloud Drive. | *Esta ação não pode ser desfeita. O arquivo será removido permanentemente do seu iCloud Drive.* | `iCloud Drive` invariante |
| ✓ | `dialog.deleteArticle.confirm` | Delete | *Excluir* | — |
| ✓ | `dialog.deleteArticle.cancel` | Cancel | *Cancelar* | — |

### Adicionar artigo (no aplicativo)

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `addArticle.navTitle` | Add Article | *Adicionar artigo* | — |
| ✓ | `addArticle.idle.instructions` | Paste a link to save an article to your library. | *Cole um link para salvar um artigo na sua biblioteca.* | — |
| ✓ | `addArticle.idle.placeholder` | Paste a link… | *Cole um link…* | — |
| ✓ | `addArticle.saving.message` | Saving article… | *Salvando artigo…* | — |
| ✓ | `addArticle.success.headline` | Article saved! | *Artigo salvo!* | A maioria das strings está em caixa baixa sem `!` — verificar consistência estilística |
| ✓ | `addArticle.failure.headline` | Could not save article | *Não foi possível salvar o artigo* | — |
| ✓ | `addArticle.failure.tryAgain` | Try Again | *Tentar novamente* | — |
| ✓ | `addArticle.error.noLibraryFolder` | No library folder selected. | *Nenhuma pasta de biblioteca selecionada.* | — |

---

## 3. Visualização de leitura

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `reading.splitView.placeholder.headline` | Select an article | *Selecione um artigo* | Visualização dividida no iPad |
| ✓ | `reading.back.accessibilityLabel` | Back to reading list | *Voltar para a lista de leitura* | — |
| ✓ | `reading.openExternal.accessibilityLabel` | Open original article | *Abrir artigo original* | — |
| ✓ | `reading.immersiveHint` | Tap anywhere to reveal controls | *Toque em qualquer lugar para mostrar os controles* | Mesmo registro da integração? |
| ✓ | `reading.body.loading` | Loading… | *Carregando…* | — |
| ✓ | `reading.body.image.accessibilityLabel` | Image | *Imagem* | Texto alternativo genérico para imagens sem texto alternativo |
| ✓ | `reading.relatedArticles.sectionHeader` | Related | *Relacionados* | — |
| ✓ | `reading.header.byline` | By {author} | *Por {author}* | Confirmar que a preposição é natural quando `{author}` é um nome |

### Editor de etiquetas

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `tagsEditor.instructions` | Comma-separated tags. Stored in the article's YAML so they work with Obsidian. | *Etiquetas separadas por vírgula. Armazenadas no YAML do artigo para funcionar com o Obsidian.* | `Obsidian`, `YAML` invariantes |
| ✓ | `tagsEditor.placeholder` | e.g. research, design | *ex.: pesquisa, design* | — |
| ✓ | `tagsEditor.saveFailed.title` | Couldn't save tags | *Não foi possível salvar as etiquetas* | — |
| ✓ | `tagsEditor.saveFailed.message` | Check folder access or disk space, then try again. | *Verifique o acesso à pasta ou o espaço em disco e tente novamente.* | — |

### Barra de leitura (controles inferiores)

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `reading.controls.decreaseFontSize` | Decrease font size | *Diminuir tamanho da fonte* | — |
| ✓ | `reading.controls.increaseFontSize` | Increase font size | *Aumentar tamanho da fonte* | — |
| ✓ | `reading.controls.lineSpacing` | Line spacing | *Espaçamento entre linhas* | — |
| ✓ | `reading.controls.margins` | Margins | *Margens* | — |
| ✓ | `reading.controls.theme` | Theme | *Tema* | — |
| ✓ | `reading.controls.markAsRead` | Mark as read | *Marcar como lido* | — |
| ✗ | `reading.controls.tts.play` | Play text-to-speech | *Reproduzir texto em voz* | ✗ ver correção nº 7 no Resumo ("texto em voz" não é construção natural). |
| ✗ | `reading.controls.tts.pause` | Pause text-to-speech | *Pausar texto em voz* | ✗ ver correção nº 8 no Resumo (mesmo motivo do item acima). |

### Painel de ajuste de fonte/tema

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `reading.controlsSheet.fontSizeLabel` | Font size | *Tamanho da fonte* | — |
| ✓ | `reading.controlsSheet.lineSpacingLabel` | Line spacing | *Espaçamento entre linhas* | — |

---

## 4. Configurações de leitura (painel inferior)

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `readerSettings.title` | Reading settings | *Configurações de leitura* | — |
| ✓ | `readerSettings.fontSize.sectionLabel` | Text size | *Tamanho do texto* | — |
| ✓ | `readerSettings.fontSize.xs` | XS (abreviação) | *PP* | Esta abreviação faz sentido? Rótulo de acessibilidade: « Extrapequeno, 14 pontos » |
| ✓ | `readerSettings.fontSize.s` | S | *P* | « Pequeno, 16 pontos » |
| ✓ | `readerSettings.fontSize.m` | M | *M* | « Médio, 18 pontos, padrão » |
| ✓ | `readerSettings.fontSize.l` | L | *G* | « Grande, 20 pontos » |
| ✓ | `readerSettings.fontSize.xl` | XL | *GG* | « Extragrande, 22 pontos » |
| ✗ | `readerSettings.fontSize.xxl` | XXL | *EEG* | « Extra extragrande, 26 pontos » (rótulo de acessibilidade — esse mantém-se igual). ✗ ver correção nº 9 no Resumo (abreviação visual colide com a sigla médica de eletroencefalograma). |
| ✓ | `readerSettings.lineSpacing.sectionLabel` | Line spacing | *Espaçamento entre linhas* | — |
| ✓ | `readerSettings.lineSpacing.compact` | Compact | *Compacto* | — |
| ✓ | `readerSettings.lineSpacing.normal` | Normal | *Normal* | — |
| ✓ | `readerSettings.lineSpacing.relaxed` | Relaxed | *Relaxado* | — |
| ✓ | `readerSettings.lineSpacing.airy` | Airy | *Espaçado* | — |
| ✓ | `readerSettings.theme.sectionLabel` | Theme | *Tema* | — |
| ✓ | `readerSettings.margins.sectionLabel` | Margins | *Margens* | — |

---

## 5. Configurações (modal)

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `settings.title` | Settings | *Configurações* | — |
| ✓ | `settings.section.reading` | Reading | *Leitura* | — |
| ✓ | `settings.font.sectionLabel` | Font | *Fonte* | — |
| ✓ | `settings.font.preview` | The quick brown fox jumps over the lazy dog | *Um pequeno jabuti xereta viu dez cegonhas felizes* | Pangrama apropriado para o português — verificar se cada letra aparece |
| ✓ | `settings.fontSize.sectionLabel` | Size | *Tamanho* | — |
| ✗ | `settings.fontSize.valueLabel` | {size}pt | *{size}pt* | **Invariante** — « pt » é uma abreviatura tipográfica padrão. ✗ ver correção nº 17 no Resumo (faltava a coluna "Tradução", desalinhando a linha). |
| ✓ | `settings.section.storage` | Storage | *Armazenamento* | — |
| ✓ | `settings.folder.rowLabel` | Articles folder | *Pasta de artigos* | — |
| ✓ | `settings.folder.emptyValue` | Not set | *Não definida* | — |
| ✓ | `settings.import.rowLabel` | Import Articles | *Importar artigos* | — |
| ✓ | `settings.section.about` | About | *Sobre* | — |
| ✓ | `settings.about.versionRowLabel` | Version {version} | *Versão {version}* | — |
| ✗ | `settings.privacyPolicy.rowLabel` | Privacy Policy | *Política de Privacidade* | ✗ ver correção nº 10 no Resumo (Title Case não é convenção em português). |
| ✓ | `settings.section.privacy` | Privacy | *Privacidade* | — |
| ✓ | `settings.analytics.rowLabel` | Share anonymous data | *Compartilhar dados anônimos* | — |
| ✓ | `settings.analytics.subtitle` | No personal info or article content, ever. | *Nenhuma informação pessoal ou conteúdo de artigo, nunca.* | — |
| ✗ | `privacyPolicy.navTitle` | Privacy Policy | *Política de Privacidade* | ✗ ver correção nº 11 no Resumo (mesma inconsistência de capitalização). |

### Diálogo de alteração de pasta

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `dialog.changeFolder.title` | Move your existing articles to the new folder? | *Mover seus artigos existentes para a nova pasta?* | — |
| ✓ | `dialog.changeFolder.message` | Your old folder won't be touched if you choose No. | *Sua pasta antiga não será alterada se você escolher Não.* | — |
| ✗ | `dialog.changeFolder.yes` | Move Articles | *Mover Artigos* | ✗ ver correção nº 12 no Resumo (Title Case inconsistente — compare com a linha abaixo, que já está correta). |
| ✓ | `dialog.changeFolder.no` | Keep in Old Folder | *Manter na pasta antiga* | — |
| ✓ | `dialog.changeFolder.cancel` | Cancel | *Cancelar* | — |

### Importação

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `import.idle.headline` | Import Articles | *Importar artigos* | — |
| ✓ | `import.idle.subtitle` | Import your reading list from GoodLinks, Instapaper, Pocket, Readwise Reader, or Matter. | *Importe sua lista de leitura do GoodLinks, Instapaper, Pocket, Readwise Reader ou Matter.* | **Nomes de produtos de terceiros são invariantes** |
| ✓ | `import.idle.selectFileButton` | Select Export File | *Selecionar arquivo de exportação* | — |
| ✓ | `import.parsing.message` | Reading file… | *Lendo arquivo…* | — |
| ✓ | `import.writing.message` | Importing articles… | *Importando artigos…* | — |
| ✓ | `import.done.headline` | Import Complete | *Importação concluída* | — |

---

## 6. Sobre

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `about.title` | About Verso | *Sobre o Verso* | — |
| ✓ | `about.version.rowLabel` | Version | *Versão* | Sub-rótulo: `{version} ({build})` — apenas dígitos, sem tradução |
| ✓ | `about.acknowledgements.rowLabel` | Open-source acknowledgements | *Agradecimentos de código aberto* | Confirmado — sem hífen é a convenção padrão em pt-BR ("projeto de código aberto", "comunidade de código aberto"). |
| ✓ | `about.github.rowLabel` | View on GitHub | *Ver no GitHub* | `GitHub` invariante |
| ✓ | `about.privacyPolicy.rowLabel` | Privacy policy | *Política de privacidade* | — |
| ✓ | `about.footer` | Verso {version} · Built with care | *Verso {version} · Feito com cuidado* | `Verso` invariante. Ponto médio `·` correto. Tom já está bem calibrado (caloroso, sem forçar). |

---

## 7. Extensão de compartilhamento

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `share.title` | Save to Verso | *Salvar no Verso* | `Verso` invariante |
| ✓ | `share.save.default` | Save | *Salvar* | — |
| ✓ | `share.save.loading` | Saving… | *Salvando…* | — |
| ✓ | `share.save.success` | Saved | *Salvo* | — |
| ✓ | `share.save.error` | Try again | *Tentar novamente* | — |
| ✓ | `share.cancel` | Cancel | *Cancelar* | — |
| ✓ | `share.error.noFolder.message` | Folder not configured. | *Pasta não configurada.* | — |
| ✓ | `share.error.noFolder.cta` | Open Verso to finish setup | *Abrir o Verso para concluir a configuração* | — |

### Extensão de compartilhamento — Falha na análise

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `share.error.headline` | Couldn't save this article. | *Não foi possível salvar este artigo.* | — |
| ✓ | `share.error.subheadline` | The page couldn't be read. You can open it directly in Safari. | *A página não pôde ser lida. Você pode abri-la diretamente no Safari.* | `Safari` invariante |
| ✓ | `share.error.openInSafari` | Open in Safari | *Abrir no Safari* | — |
| ✓ | `share.error.dismiss` | Dismiss | *Descartar* | — |

### Extensão de compartilhamento — URL duplicada

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `share.duplicate.headline` | Article already saved | *Artigo já salvo* | — |
| ✓ | `share.duplicate.subheadline` | This link is already in your library as "{existingTitle}". | *Este link já está na sua biblioteca como "{existingTitle}".* | Confirmado — aspas curvas `""` são o padrão correto em pt-BR digital (diferente do fr-CA, que usa « »). |
| ✓ | `share.duplicate.updateExisting` | Update existing | *Atualizar existente* | — |
| ✓ | `share.duplicate.saveCopy` | Save as copy | *Salvar como cópia* | Confirmado — `(Cópia)` é a tradução correta do sufixo `(Copy)`. |
| ✓ | `share.duplicate.cancel` | Cancel | *Cancelar* | — |
| ✓ | `share.duplicate.success.saved` | Saved | *Salvo* | — |
| ✓ | `share.duplicate.success.updated` | Updated | *Atualizado* | — |

---

## 8. Erros e mensagens do sistema

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✗ | `error.offline.banner.headline` | You're offline. | *Você está off-line.* | ✗ ver correção nº 13 no Resumo (evita o anglicismo "off-line"). |
| ✓ | `error.offline.banner.subheadline` | Saved articles are still available. | *Os artigos salvos continuam disponíveis.* | Bom exemplo de registro natural ("continuam" em vez de "permanecem") — usei como referência nas correções 5, 13 e 14. |
| ✗ | `error.offline.articleUnavailable` | Not available offline. | *Não disponível off-line.* | ✗ ver correção nº 14 no Resumo (mesmo anglicismo do item acima). |
| ✓ | `error.parsing.headline` | Couldn't read this article. | *Não foi possível ler este artigo.* | — |
| ✗ | `error.parsing.subheadline` | The page may be behind a paywall or require a login. | *A página pode estar atrás de um paywall ou exigir login.* | ✗ ver correção nº 15 no Resumo (evita o anglicismo "paywall"). |
| ✓ | `error.parsing.openInSafari` | Open in Safari | *Abrir no Safari* | `Safari` invariante |
| ✓ | `error.parsing.dismiss` | Dismiss | *Descartar* | — |
| ✓ | `error.noFolder.headline` | No folder selected. | *Nenhuma pasta selecionada.* | — |
| ✓ | `error.noFolder.subheadline` | Choose a folder in iCloud Drive to start saving articles. | *Escolha uma pasta no iCloud Drive para começar a salvar artigos.* | `iCloud Drive` invariante |
| ✓ | `error.noFolder.cta` | Choose folder | *Escolher pasta* | — |
| ✓ | `error.folderMissing.headline` | Folder not found. | *Pasta não encontrada.* | — |
| ✓ | `error.folderMissing.subheadline` | The folder may have been moved or deleted. Choose a new one to continue. | *A pasta pode ter sido movida ou excluída. Escolha uma nova para continuar.* | — |
| ✓ | `error.folderMissing.cta` | Choose new folder | *Escolher nova pasta* | — |
| ✓ | `error.iCloudUnavailable.headline` | iCloud Drive is unavailable. | *O iCloud Drive está indisponível.* | `iCloud Drive` invariante |
| ✗ | `error.iCloudUnavailable.subheadline` | Go to Settings → [Your Name] → iCloud to re-enable it. | *Vá em Configurações → [Your Name] → iCloud para reativá-lo.* | **⚠️ CRÍTICO, resolvido por pesquisa:** o app de sistema da Apple em pt-BR chama-se "Ajustes", não "Configurações" (esse nome é reservado para a tela interna do Verso). ✗ ver correção nº 16 no Resumo. Recomendo confirmar numa tela real antes do envio, mas a fonte é a documentação da própria Apple. |
| ✓ | `error.fileWrite.message` | Couldn't save article. | *Não foi possível salvar o artigo.* | — |
| ✓ | `error.fileWrite.subtext` | Check that your folder is accessible and try again. | *Verifique se sua pasta está acessível e tente novamente.* | — |
| ✓ | `error.fileRead.headline` | This article couldn't be loaded. | *Não foi possível carregar este artigo.* | — |
| ✓ | `error.fileRead.cta` | Open original | *Abrir original* | — |
| ✓ | `error.generic` | Something went wrong. Please try again. | *Algo deu errado. Tente novamente.* | Mensagem de último recurso |

---

## 9. Rótulos somente de acessibilidade (VoiceOver)

Estas strings nunca ficam visíveis na tela. Elas devem soar naturais quando lidas em voz alta por um leitor de tela.

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `a11y.articleRow.hint` | Double tap to open | *Toque duas vezes para abrir* | — |
| ✓ | `a11y.filterChip.selected` | Currently selected | *Atualmente selecionado* | — |
| ✓ | `a11y.filterChip.unselected` | Double tap to filter | *Toque duas vezes para filtrar* | — |
| ✓ | `a11y.themeChip.selected` | Currently selected | *Atualmente selecionado* | — |
| ✓ | `a11y.themeChip.unselected` | Double tap to select | *Toque duas vezes para selecionar* | — |
| ✓ | `a11y.fontOption.selected` | {fontName}, selected | *{fontName}, selecionado* | — |
| ✓ | `a11y.fontSize.label` | {label}, {points} points | *{label}, {points} pontos* | — |
| ✓ | `a11y.fontSize.default` | {label}, {points} points, default | *{label}, {points} pontos, padrão* | — |
| ✓ | `a11y.progress.label` | Reading progress | *Progresso de leitura* | — |
| ✓ | `a11y.progress.value` | {N} percent | *{N} por cento* | Não há formas plurais — « por cento » não varia |
| ✓ | `a11y.skeletonLoading` | Loading articles | *Carregando artigos* | — |
| ✓ | `a11y.deleteAction` | Delete article | *Excluir artigo* | — |
| ✓ | `a11y.archiveAction` | Archive article | *Arquivar artigo* | — |
| ✓ | `a11y.unarchiveAction` | Unarchive article | *Desarquivar artigo* | — |

---

## 10. Tela de inicialização

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `launch.brandName` | Verso | **Invariante** — nome da marca. Não traduzir. |

---

## 11. Strings exclusivas da Web

Sem equivalente no iOS. Marcadas como `needs_review` na fonte — revisar com atenção extra.

| ✓ | Chave | Inglês | Tradução | Notas |
|---|-------|--------|----------|-------|
| ✓ | `web.unsupportedBrowser.headline` | Browser not supported | *Navegador não compatível* | Revisado — ok. |
| ✓ | `web.unsupportedBrowser.subheadline` | Verso Web uses the File System Access API, which requires Chrome or Edge 86+. Please open this page in a supported browser. | *O Verso Web usa a File System Access API, que requer Chrome ou Edge 86+. Abra esta página em um navegador compatível.* | `Verso Web`, `File System Access API`, `Chrome`, `Edge` invariantes. Revisado — ok. |
| ✓ | `web.changeFolder.label` | Change folder | *Alterar pasta* | Revisado — ok. |
| ✓ | `web.fontFamily.system` | System | *Sistema* | Revisado — ok. |
| ✓ | `web.fontFamily.mono` | Mono | *Mono* | Revisado — ok, rótulo de categoria de fonte mantido igual a outros seletores. |
| ✓ | `web.fontFamily.georgia` | Georgia | **Invariante** — nome da fonte |
| ✓ | `web.fontFamily.dyslexic` | OpenDyslexic | **Invariante** — nome da fonte / marca |
| ✓ | `web.reader.toggleControls.show` | Show controls | *Mostrar controles* | Revisado — ok. |
| ✓ | `web.reader.toggleControls.hide` | Hide controls | *Ocultar controles* | Revisado — ok. |
| ✓ | `web.reader.backButton.label` | Library | *Biblioteca* | Revisado — ok. |
| ✓ | `web.reader.error.noFolder` | No folder selected. Go back and choose your library folder. | *Nenhuma pasta selecionada. Volte e escolha a pasta da sua biblioteca.* | Revisado — ok. |
| ✓ | `web.reader.error.permissionDenied` | Folder permission denied. Go back and re-select your library. | *Permissão da pasta negada. Volte e selecione novamente sua biblioteca.* | Revisado — ok; registro mais técnico/direto é apropriado para mensagem de erro de permissão. |
| ✓ | `web.reader.error.articleNotFound` | Article not found: {filename} | *Artigo não encontrado: {filename}* | `{filename}` é o nome literal do arquivo — não traduzir. Revisado — ok. |
| ✓ | `web.reader.error.loadFailed` | Failed to load article | *Falha ao carregar o artigo* | Revisado — ok. |
| ✓ | `web.reader.error.fallback` | Article not found. | *Artigo não encontrado.* | Revisado — ok. |
| ✓ | `web.reader.backToLibrary.label` | Back to library | *Voltar para a biblioteca* | Revisado — ok. |

---

## Verificação de renderização de diacríticos

Abra o aplicativo neste idioma e verifique se cada caractere é renderizado corretamente nos 6 tamanhos de leitura (XS a XXL). Marque `✓` ou `✗` para cada um.

> **Nota da revisão:** esta tabela não pode ser preenchida numa revisão de texto — exige inspeção visual do app rodando em dispositivo, nas duas fontes, nos 6 tamanhos. Os 24 quadrados abaixo seguem em branco (`☐`) de propósito; é o único item desta revisão que ainda depende de QA visual no Fabio.

| Glifo | OpenDyslexic | Fonte do sistema | Notas |
|-------|-------------|------------------|-------|
| `ç` | ☐ | ☐ | Cedilha |
| `ã` | ☐ | ☐ | Til + a |
| `õ` | ☐ | ☐ | Til + o |
| `â` | ☐ | ☐ | Circunflexo + a |
| `ê` | ☐ | ☐ | Circunflexo + e |
| `é` | ☐ | ☐ | Agudo + e |
| `à` | ☐ | ☐ | Grave + a |
| `ü` | ☐ | ☐ | Trema + u |
| `ô` | ☐ | ☐ | Circunflexo + o |
| `î` | ☐ | ☐ | Circunflexo + i |
| `û` | ☐ | ☐ | Circunflexo + u |
| `ë` | ☐ | ☐ | Trema + e |

---

## Resumo das alterações

Por favor, liste todas as correções propostas abaixo.

| # | Seção | Chave | Tradução atual | Tradução corrigida | Motivo |
|---|-------|-------|----------------|--------------------|--------|
| 1 | OB-2 · Seletor de tema | `onboarding.theme.subheadline` | Você pode alterar isso a qualquer momento nas configurações. | Você pode mudar isso quando quiser, nas configurações. | Registro mais coloquial (calibração aprovada): "alterar"→"mudar", "a qualquer momento"→"quando quiser". |
| 2 | OB-3 · Configuração da pasta | `onboarding.folder.headline` | Onde o Verso deve guardar seus artigos? | Onde o Verso vai guardar seus artigos? | Remove o modal "deve", que soa formal/burocrático em português; "vai guardar" é mais direto e natural. |
| 3 | OB-3 · Configuração da pasta | `onboarding.folder.privacyNote` | O Verso nunca envia seus arquivos para a nuvem. Eles ficam no seu iCloud Drive. | O Verso não tem servidores: seus arquivos nunca saem do seu iCloud Drive. | Correção lógica — o iCloud Drive também é nuvem, então a frase original se contradiz. A intenção do texto original em inglês ("never uploads") é "sem servidores próprios do Verso", não "sem nuvem". |
| 4 | OB-4 · Tour guiado | `onboarding.tour.step1` | Compartilhe qualquer artigo do Safari ou do seu navegador para salvá-lo instantaneamente. | Compartilhe qualquer artigo do Safari ou do navegador para salvar na hora. | Registro mais coloquial: "instantaneamente" é de registro escrito/formal; "na hora" é como se fala no dia a dia. |
| 5 | OB-4 · Tour guiado | `onboarding.tour.step3` | Marque os artigos como lidos quando terminar. Eles permanecem na sua pasta para sempre. | Marque os artigos como lidos quando terminar. Eles ficam na sua pasta para sempre. | "permanecem" é registro literário/formal; "ficam" é o verbo do dia a dia — compare com `error.offline.banner.subheadline`, que já usa "continuam" em vez de "permanecem". |
| 6 | 2. Início · Estados vazios (Web) | `home.empty.noUnread.headline` | Nenhum artigo não lido | Nada não lido | Consistência com os estados vazios irmãos da Web ("Nada em andamento", "Nada lido ainda"), que seguem o padrão "Nada + adjetivo" em vez de "Nenhum artigo + adjetivo". |
| 7 | 3. Visualização de leitura | `reading.controls.tts.play` | Reproduzir texto em voz | Ler em voz alta | "Texto em voz" não é uma construção natural em português (o termo técnico usa "fala", não "voz" desse jeito); "ler em voz alta" é natural e funciona bem como rótulo de botão. |
| 8 | 3. Visualização de leitura | `reading.controls.tts.pause` | Pausar texto em voz | Pausar leitura em voz alta | Mesmo motivo do item 7. |
| 9 | 4. Configurações de leitura | `readerSettings.fontSize.xxl` | EEG | XG | "EEG" colide com a sigla médica de eletroencefalograma, o que é um problema real de UX; o padrão real de tamanhos no Brasil é PP, P, M, G, GG, XG (não "EEG"). |
| 10 | 5. Configurações (modal) | `settings.privacyPolicy.rowLabel` | Política de Privacidade | Política de privacidade | Title Case (maiúscula em cada palavra) não é convenção em português; corrige para combinar com `about.privacyPolicy.rowLabel`, que já usa a capitalização correta. |
| 11 | 6. Sobre | `privacyPolicy.navTitle` | Política de Privacidade | Política de privacidade | Mesma correção de capitalização do item 10 — falta de consistência entre as três ocorrências da mesma frase no app. |
| 12 | 5. Configurações (modal) | `dialog.changeFolder.yes` | Mover Artigos | Mover artigos | Mesma inconsistência de Title Case; o botão `dialog.changeFolder.no`, na mesma tela, já usa a capitalização correta. |
| 13 | 8. Erros e mensagens do sistema | `error.offline.banner.headline` | Você está off-line. | Você está sem conexão. | Evita o anglicismo "off-line" (pedido explícito do Fabio); "sem conexão" é o termo nativo já usado em apps e navegadores brasileiros. |
| 14 | 8. Erros e mensagens do sistema | `error.offline.articleUnavailable` | Não disponível off-line. | Não disponível sem conexão. | Mesmo motivo do item 13 — mantém consistência interna entre as duas strings sobre o mesmo estado de "sem internet". |
| 15 | 8. Erros e mensagens do sistema | `error.parsing.subheadline` | A página pode estar atrás de um paywall ou exigir login. | A página pode exigir assinatura ou login. | Evita o anglicismo "paywall"; a reformulação é mais direta, mais natural e mais curta — sem perder o sentido. |
| 16 | 8. Erros e mensagens do sistema | `error.iCloudUnavailable.subheadline` | Vá em Configurações → [Your Name] → iCloud para reativá-lo. | Vá em Ajustes → [Seu Nome] → iCloud para reativá-lo. | **Resolve o item CRÍTICO do documento original.** Confirmei (documentação da Apple) que o app de sistema da Apple em pt-BR se chama "Ajustes", não "Configurações" — esse último nome é reservado, neste documento, para a tela interna do Verso. Também traduzi o placeholder "[Your Name]" → "[Seu Nome]", já que é texto instrucional (não uma variável de código como `{count}` ou `{author}`). Recomendo uma confirmação rápida em um aparelho real antes de publicar, mas a fonte é confiável. |
| 17 | 5. Configurações (modal) | `settings.fontSize.valueLabel` | *(coluna "Tradução" ausente na tabela original)* | *{size}pt* | Problema de formatação: a linha original tinha uma coluna faltando (4 em vez de 5), desalinhando a tabela com as demais. |

*(Lista fechada — nenhuma outra correção encontrada nas ~274 chaves revisadas)*

---

## Aprovação

- **Total de chaves revisadas:** ~274 de ~274 (todas as linhas de texto; a tabela de diacríticos exige QA visual separada — ver nota acima)
- **Alterações propostas:** 17 (ver tabela acima)
- **Problemas críticos (plural / diacríticos / truncamento):**
  - Plural: regra 0/1/2/5 aplicada corretamente em todas as 7 chaves; 2 delas (`import.done.summary`, `import.done.skippedSuffix`) têm uma ressalva técnica sobre concordância do participle — ver notas nas próprias linhas.
  - Diacríticos: pendente — requer inspeção visual em dispositivo (não verificável numa revisão de texto).
  - Truncamento: 2 itens abertos para checar em dispositivo/Figma — `home.search.placeholder` e o chip `filter.unread`.
  - 1 problema crítico do documento original (`error.iCloudUnavailable.subheadline`, nome do app de sistema da Apple) foi resolvido nesta revisão — ver correção nº 16.

**Assinatura do revisor:** Claude (revisão assistida por IA) — correções acima propostas para aprovação do Fabio

**Data:** 21 de junho de 2026

**Próxima etapa:** Devolva este documento ao Fabio. As correções serão aplicadas em `docs/copy/UI_COPY.md`, e então `generate.py` será executado novamente para propagar as alterações para `Localizable.xcstrings`, `L10n.swift` e todos os arquivos Web `messages/*.json`.
