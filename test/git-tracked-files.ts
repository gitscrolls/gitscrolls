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
    const result = execSync(`git ls-files "${dir}"`, { encoding: 'utf-8' });
    return result
      .trim()
      .split('\n')
      .filter(f => f.length > 0 && f.endsWith('.md'))
      .filter(f => f.startsWith(`${dir}/`))
      .map(f => f.replace(new RegExp(`^${dir}\\/`), ''));
  } catch (error) {
    console.error('Failed to get git-tracked files:', error);
    return [];
  }
}
