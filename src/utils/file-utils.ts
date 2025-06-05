import { existsSync, readdirSync, statSync } from 'fs';
import { join, resolve, dirname } from 'path';

export function resolveRelativePath(fromFile: string, relativePath: string): string {
  const dir = dirname(fromFile);
  return resolve(dir, relativePath);
}

export function fileExists(filepath: string): boolean {
  return existsSync(filepath);
}

export function findMarkdownFiles(directory: string): string[] {
  const files: string[] = [];
  
  function traverse(dir: string): void {
    const entries = readdirSync(dir);
    
    for (const entry of entries) {
      const fullPath = join(dir, entry);
      const stat = statSync(fullPath);
      
      if (stat.isDirectory() && !entry.startsWith('.') && entry !== 'node_modules') {
        traverse(fullPath);
      } else if (stat.isFile() && entry.endsWith('.md')) {
        files.push(fullPath);
      }
    }
  }
  
  traverse(directory);
  return files;
}