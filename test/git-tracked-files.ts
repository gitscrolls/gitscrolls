import { execSync } from 'child_process';

/**
 * Get all git-tracked markdown files
 */
export function getGitTrackedMarkdownFiles(): string[] {
  try {
    const result = execSync('git ls-files "*.md"', { encoding: 'utf-8' });
    return result.trim().split('\n').filter(f => f.length > 0);
  } catch (error) {
    console.error('Failed to get git-tracked files:', error);
    return [];
  }
}

/**
 * Get git-tracked files in a specific directory
 */
export function getGitTrackedFilesInDir(dir: string): string[] {
  try {
    const pattern = `${dir}/*.md`;
    const result = execSync(`git ls-files "${pattern}"`, { encoding: 'utf-8' });
    return result.trim().split('\n')
      .filter(f => f.length > 0)
      .map(f => f.split('/').pop() || f);
  } catch (error) {
    console.error('Failed to get git-tracked files:', error);
    return [];
  }
}