import { BaseValidator, ValidationError, ValidationResult } from '../core/base-validator';
import { parseMarkdownFile, MarkdownLink } from '../utils/markdown-parser';
import { findMarkdownFiles, resolveRelativePath, fileExists } from '../utils/file-utils';
import { relative } from 'path';

interface LinkNode {
  filepath: string;
  title: string;
  outgoingLinks: LinkValidation[];
  incomingLinks: LinkValidation[];
}

interface LinkValidation {
  source: string;
  target: string;
  link: MarkdownLink;
  valid: boolean;
  error?: string;
}

export class LinkGraphValidator extends BaseValidator {
  name = 'link-graph-validator';
  
  private graph: Map<string, LinkNode> = new Map();
  
  async validate(): Promise<ValidationResult> {
    const errors: ValidationError[] = [];
    const markdownFiles = findMarkdownFiles(this.projectRoot);
    
    // Build graph
    await this.buildGraph(markdownFiles);
    
    // Validate links
    const linkErrors = this.validateLinks();
    errors.push(...linkErrors);
    
    // Detect orphans
    const orphanErrors = this.detectOrphans();
    errors.push(...orphanErrors);
    
    // Check title consistency
    const titleErrors = this.checkTitleConsistency();
    errors.push(...titleErrors);
    
    const totalChecks = this.countTotalChecks();
    return this.createResult(errors, totalChecks);
  }
  
  private async buildGraph(files: string[]): Promise<void> {
    // First pass: create nodes
    for (const file of files) {
      const parsed = await parseMarkdownFile(file);
      const relPath = relative(this.projectRoot, file);
      
      this.graph.set(file, {
        filepath: file,
        title: parsed.title || 'Untitled',
        outgoingLinks: [],
        incomingLinks: []
      });
    }
    
    // Second pass: process links
    for (const file of files) {
      const node = this.graph.get(file)!;
      const parsed = await parseMarkdownFile(file);
      
      for (const link of parsed.links) {
        // Skip external links
        if (link.url.startsWith('http://') || link.url.startsWith('https://')) {
          continue;
        }
        
        // Skip anchor links
        if (link.url.startsWith('#')) {
          continue;
        }
        
        const targetPath = resolveRelativePath(file, link.url);
        const validation: LinkValidation = {
          source: file,
          target: targetPath,
          link,
          valid: fileExists(targetPath),
          error: fileExists(targetPath) ? undefined : 'Target file does not exist'
        };
        
        node.outgoingLinks.push(validation);
        
        // Add to target's incoming links if it exists
        const targetNode = this.graph.get(targetPath);
        if (targetNode) {
          targetNode.incomingLinks.push(validation);
        }
      }
    }
  }
  
  private validateLinks(): ValidationError[] {
    const errors: ValidationError[] = [];
    
    for (const [filepath, node] of this.graph) {
      for (const validation of node.outgoingLinks) {
        if (!validation.valid) {
          errors.push({
            type: 'broken_link',
            severity: 'error',
            file: relative(this.projectRoot, filepath),
            line: validation.link.line,
            description: `Broken link: "${validation.link.text}" points to non-existent file`,
            suggestion: `Check if the file "${relative(this.projectRoot, validation.target)}" exists or fix the link URL`,
            details: {
              link_text: validation.link.text,
              link_url: validation.link.url,
              target_path: relative(this.projectRoot, validation.target)
            }
          });
        }
      }
    }
    
    return errors;
  }
  
  private detectOrphans(): ValidationError[] {
    const errors: ValidationError[] = [];
    const reachable = new Set<string>();
    
    // Find entry points (README.md files)
    const entryPoints = Array.from(this.graph.keys()).filter(
      file => file.endsWith('README.md')
    );
    
    // BFS from entry points
    const queue = [...entryPoints];
    reachable.add(...entryPoints);
    
    while (queue.length > 0) {
      const current = queue.shift()!;
      const node = this.graph.get(current)!;
      
      for (const link of node.outgoingLinks) {
        if (link.valid && !reachable.has(link.target)) {
          reachable.add(link.target);
          queue.push(link.target);
        }
      }
    }
    
    // Find orphans
    for (const [filepath, _] of this.graph) {
      if (!reachable.has(filepath) && !filepath.endsWith('README.md')) {
        errors.push({
          type: 'orphaned_document',
          severity: 'warning',
          file: relative(this.projectRoot, filepath),
          description: 'Document is not reachable from any README.md file',
          suggestion: 'Add a link to this document from another document in the project'
        });
      }
    }
    
    return errors;
  }
  
  private checkTitleConsistency(): ValidationError[] {
    const errors: ValidationError[] = [];
    
    for (const [filepath, node] of this.graph) {
      for (const validation of node.outgoingLinks) {
        if (validation.valid) {
          const targetNode = this.graph.get(validation.target);
          if (targetNode && validation.link.text && targetNode.title) {
            // Check if link text reasonably matches the target title
            const linkText = validation.link.text.toLowerCase().trim();
            const targetTitle = targetNode.title.toLowerCase().trim();
            
            // Simple check: if link text contains "scroll" or "gitscroll",
            // it should match the target title more closely
            if ((linkText.includes('scroll') || linkText.includes('gitscroll')) &&
                linkText !== targetTitle &&
                !targetTitle.includes(linkText) &&
                !linkText.includes(targetTitle)) {
              errors.push({
                type: 'title_mismatch',
                severity: 'warning',
                file: relative(this.projectRoot, filepath),
                line: validation.link.line,
                description: `Link text "${validation.link.text}" may not match target document title "${targetNode.title}"`,
                suggestion: `Consider updating the link text to match the target document's title`,
                details: {
                  link_text: validation.link.text,
                  expected_title: targetNode.title,
                  target_file: relative(this.projectRoot, validation.target)
                }
              });
            }
          }
        }
      }
    }
    
    return errors;
  }
  
  private countTotalChecks(): number {
    let total = 0;
    
    // Count all links checked
    for (const [_, node] of this.graph) {
      total += node.outgoingLinks.length;
    }
    
    // Count orphan checks (one per file)
    total += this.graph.size;
    
    return total;
  }
}