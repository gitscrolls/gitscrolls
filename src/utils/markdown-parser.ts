import { readFileSync } from 'fs';
import { join } from 'path';
import matter from 'gray-matter';
import { unified } from 'unified';
import remarkParse from 'remark-parse';
import { visit } from 'unist-util-visit';

export interface MarkdownLink {
  text: string;
  url: string;
  line: number;
  column: number;
}

export interface ParsedMarkdown {
  content: string;
  frontmatter: Record<string, unknown>;
  title?: string;
  links: MarkdownLink[];
}

export async function parseMarkdownFile(filepath: string): Promise<ParsedMarkdown> {
  const content = readFileSync(filepath, 'utf-8');
  const { data: frontmatter, content: markdownContent } = matter(content);
  
  const links: MarkdownLink[] = [];
  
  const processor = unified()
    .use(remarkParse)
    .use(() => (tree: any) => {
      visit(tree, 'link', (node: any) => {
        links.push({
          text: node.children?.[0]?.value || '',
          url: node.url,
          line: node.position?.start?.line || 0,
          column: node.position?.start?.column || 0
        });
      });
    });
  
  await processor.process(markdownContent);
  
  // Extract title from frontmatter or first heading
  let title = frontmatter.title as string | undefined;
  
  if (!title) {
    const titleMatch = markdownContent.match(/^#\s+(.+)$/m);
    if (titleMatch) {
      title = titleMatch[1];
    }
  }
  
  return {
    content: markdownContent,
    frontmatter,
    title,
    links
  };
}