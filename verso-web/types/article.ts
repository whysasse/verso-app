export type ArticleStatus = 'unread' | 'reading' | 'read' | 'archived';

export interface Article {
  // YAML frontmatter — must stay byte-compatible with iOS MarkdownWriter
  title: string;
  url?: string;
  author?: string;
  site_name?: string;
  status: ArticleStatus;
  scroll_position?: number; // 0–1, 4 decimal places
  tags?: string[];
  added: string; // yyyy-MM-dd

  // Runtime-only (not persisted to frontmatter)
  filename: string; // e.g. "2026-05-20 My Article.md"
  body: string; // Markdown body after frontmatter delimiter
}
