'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import type { Article } from '@/types/article';
import * as FS from '@/services/FileSystemService';

export interface ArticleLibrary {
  articles: Article[];
  isLoading: boolean;
  error: string | null;
  isSupported: boolean;
  hasFolder: boolean;
  openFolder: () => Promise<void>;
  reload: () => Promise<void>;
  saveArticle: (article: Article) => Promise<void>;
  createArticle: (params: {
    title: string;
    url?: string;
    body?: string;
    metadata?: Partial<Omit<Article, 'title' | 'url' | 'filename' | 'body' | 'added'>>;
  }) => Promise<Article>;
}

export function useArticleLibrary(): ArticleLibrary {
  const [articles, setArticles] = useState<Article[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [hasFolder, setHasFolder] = useState(false);
  const handleRef = useRef<FileSystemDirectoryHandle | null>(null);

  const isSupported = FS.isSupported();

  const loadFromHandle = useCallback(async (handle: FileSystemDirectoryHandle) => {
    setIsLoading(true);
    setError(null);
    try {
      const loaded = await FS.readArticles(handle);
      handleRef.current = handle;
      setArticles(loaded);
      setHasFolder(true);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to read articles');
    } finally {
      setIsLoading(false);
    }
  }, []);

  // On mount: try to restore saved folder handle
  useEffect(() => {
    if (!isSupported) return;
    FS.getSavedFolder().then((handle) => {
      if (handle) loadFromHandle(handle);
    });
  }, [isSupported, loadFromHandle]);

  const openFolder = useCallback(async () => {
    if (!isSupported) return;
    try {
      const handle = await FS.openFolder();
      await loadFromHandle(handle);
    } catch (e) {
      if (e instanceof Error && e.name !== 'AbortError') {
        setError(e.message);
      }
    }
  }, [isSupported, loadFromHandle]);

  const reload = useCallback(async () => {
    if (!handleRef.current) return;
    // Handle may need permission re-request after page reload
    const granted = await FS.requestFolderPermission(handleRef.current);
    if (granted) await loadFromHandle(handleRef.current);
  }, [loadFromHandle]);

  const saveArticle = useCallback(async (article: Article) => {
    if (!handleRef.current) throw new Error('No folder selected');
    await FS.writeArticle(handleRef.current, article);
    setArticles((prev) => prev.map((a) => (a.filename === article.filename ? article : a)));
  }, []);

  const createArticle = useCallback(
    async (params: Parameters<typeof FS.createArticle>[1]) => {
      if (!handleRef.current) throw new Error('No folder selected');
      const article = await FS.createArticle(handleRef.current, params);
      setArticles((prev) => [article, ...prev]);
      return article;
    },
    [],
  );

  return { articles, isLoading, error, isSupported, hasFolder, openFolder, reload, saveArticle, createArticle };
}
