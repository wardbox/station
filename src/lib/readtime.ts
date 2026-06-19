import { type Post } from './content';

const WORDS_PER_MINUTE = 225;

const wordCount = (text: string) => text.trim().split(/\s+/).filter(Boolean).length;

export function estimateReadTime(text: string): string {
  const words = wordCount(text);
  const minutes = Math.max(1, Math.ceil(words / WORDS_PER_MINUTE));
  return `${minutes} min`;
}

export function postReadTime(post: Post): string {
  return post.entry.data.readtime ?? estimateReadTime(post.entry.body);
}
