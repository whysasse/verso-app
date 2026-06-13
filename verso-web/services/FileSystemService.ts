import matter from 'gray-matter';
import { openDB } from 'idb';
import type { Article, ArticleStatus } from '@/types/article';

const DB_NAME = 'verso';
const DB_VERSION = 1;
const STORE_NAME = 'handles';
const HANDLE_KEY = 'root';

async function getDB() {
  return openDB(DB_NAME, DB_VERSION, {
    upgrade(db) {
      db.createObjectStore(STORE_NAME);
    },
  });
}

export function isSupported(): boolean {
  return typeof window !== 'undefined' && 'showDirectoryPicker' in window;
}

export async function openFolder(): Promise<FileSystemDirectoryHandle> {
  const handle = await window.showDirectoryPicker({ mode: 'readwrite' });
  const db = await getDB();
  await db.put(STORE_NAME, handle, HANDLE_KEY);
  return handle;
}

export async function getSavedFolder(): Promise<FileSystemDirectoryHandle | null> {
  try {
    const db = await getDB();
    const handle: FileSystemDirectoryHandle | undefined = await db.get(STORE_NAME, HANDLE_KEY);
    if (!handle) return null;
    const permission = await handle.queryPermission({ mode: 'readwrite' });
    return permission === 'granted' ? handle : null;
  } catch {
    return null;
  }
}

export async function requestFolderPermission(
  handle: FileSystemDirectoryHandle,
): Promise<boolean> {
  const permission = await handle.requestPermission({ mode: 'readwrite' });
  return permission === 'granted';
}

function parseArticle(filename: string, raw: string): Article | null {
  try {
    const { data, content } = matter(raw);
    const status = (['unread', 'reading', 'read', 'archived'] as const).includes(data.status)
      ? (data.status as ArticleStatus)
      : 'unread';

    return {
      filename,
      body: content.trimStart(),
      title: String(data.title ?? filename.replace(/\.md$/, '')),
      url: data.url ?? undefined,
      author: data.author ?? undefined,
      site_name: data.site_name ?? undefined,
      status,
      scroll_position:
        typeof data.scroll_position === 'number' ? data.scroll_position : undefined,
      tags: Array.isArray(data.tags) ? data.tags.map(String) : undefined,
      added: data.added ?? new Date().toISOString().slice(0, 10),
    };
  } catch {
    return null;
  }
}

export async function readArticles(handle: FileSystemDirectoryHandle): Promise<Article[]> {
  const articles: Article[] = [];

  for await (const [name, entry] of handle.entries()) {
    if (entry.kind !== 'file' || !name.endsWith('.md')) continue;
    const file = await (entry as FileSystemFileHandle).getFile();
    const text = await file.text();
    const parsed = parseArticle(name, text);
    if (parsed) articles.push(parsed);
  }

  return articles.sort((a, b) => {
    if (a.added < b.added) return 1;
    if (a.added > b.added) return -1;
    return a.title.localeCompare(b.title);
  });
}

function serialiseFrontmatter(article: Article): string {
  // Field order mirrors iOS MarkdownWriter.buildFrontmatter()
  const data: Record<string, unknown> = { title: article.title };
  if (article.url) data.url = article.url;
  if (article.author) data.author = article.author;
  if (article.site_name) data.site_name = article.site_name;
  data.status = article.status;
  if (article.scroll_position !== undefined)
    data.scroll_position = parseFloat(article.scroll_position.toFixed(4));
  data.tags = article.tags ?? [];
  data.added = article.added;

  return matter.stringify(article.body, data);
}

export async function writeArticle(
  handle: FileSystemDirectoryHandle,
  article: Article,
): Promise<void> {
  const fileHandle = await handle.getFileHandle(article.filename, { create: true });
  const writable = await fileHandle.createWritable();
  await writable.write(serialiseFrontmatter(article));
  await writable.close();
}

export async function readArticle(
  handle: FileSystemDirectoryHandle,
  filename: string,
): Promise<Article | null> {
  try {
    const fileHandle = await handle.getFileHandle(filename);
    const file = await fileHandle.getFile();
    const text = await file.text();
    return parseArticle(filename, text);
  } catch {
    return null;
  }
}

export async function createArticle(
  handle: FileSystemDirectoryHandle,
  params: {
    title: string;
    url?: string;
    body?: string;
    metadata?: Partial<Omit<Article, 'title' | 'url' | 'filename' | 'body' | 'added'>>;
  },
): Promise<Article> {
  const today = new Date().toISOString().slice(0, 10);
  const safeName = params.title.replace(/[/\\:*?"<>|]/g, '').trim();
  const filename = `${today} ${safeName}.md`;

  const article: Article = {
    filename,
    title: params.title,
    url: params.url,
    status: params.metadata?.status ?? 'unread',
    tags: params.metadata?.tags,
    author: params.metadata?.author,
    site_name: params.metadata?.site_name,
    added: today,
    body: params.body ?? '',
  };

  await writeArticle(handle, article);
  return article;
}
