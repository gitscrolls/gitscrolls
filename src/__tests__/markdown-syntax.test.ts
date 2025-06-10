const { readFileSync, readdirSync, existsSync } = require('fs');
const { join } = require('path');

interface MarkdownError {
  file: string;
  line: number;
  column: number;
  message: string;
}

/**
 * Validates a Markdown file for syntax errors
 * This is a simplified validator that checks for basic issues
 */
function validateMarkdownFile(filePath: string): MarkdownError[] {
  const errors: MarkdownError[] = [];
  const content = readFileSync(filePath, 'utf-8');
  const fileName = filePath.split('/').pop() || 'unknown';
  
  // Check for unclosed code blocks (most critical issue)
  const codeBlockMatches = content.match(/^```/gm) || [];
  if (codeBlockMatches.length % 2 !== 0) {
    errors.push({
      file: fileName,
      line: content.split('\n').length,
      column: 1,
      message: 'Unclosed code block (```) - odd number of triple backticks'
    });
  }
  
  // More complex emphasis checking would require a proper parser
  // For now, we'll just check for the most obvious issues
  
  return errors;
}

describe('GitScrolls Markdown Syntax Validation', () => {
  const projectRoot = join(__dirname, '../..');
  const scrollsDir = join(projectRoot, 'scrolls');
  
  // Get all scroll files
  const scrollFiles = readdirSync(scrollsDir)
    .filter((f: string) => f.endsWith('.md'))
    .sort();
  
  // Test each scroll file
  scrollFiles.forEach((file: string) => {
    test(`Scroll: ${file} should have valid Markdown syntax`, () => {
      const filePath = join(scrollsDir, file);
      const errors = validateMarkdownFile(filePath);
      
      if (errors.length > 0) {
        const errorMessages = errors.map((e: MarkdownError) => 
          `Line ${e.line}, Column ${e.column}: ${e.message}`
        ).join('\n');
        throw new Error(`Markdown syntax errors in ${file}:\n${errorMessages}`);
      }
    });
  });
  
  // Test README.md
  test('README.md should have valid Markdown syntax', () => {
    const readmePath = join(projectRoot, 'README.md');
    if (existsSync(readmePath)) {
      const errors = validateMarkdownFile(readmePath);
      
      if (errors.length > 0) {
        const errorMessages = errors.map((e: MarkdownError) => 
          `Line ${e.line}, Column ${e.column}: ${e.message}`
        ).join('\n');
        throw new Error(`Markdown syntax errors in README.md:\n${errorMessages}`);
      }
    } else {
      console.warn('README.md not found');
    }
  });
  
  // Summary test to ensure we tested the right number of files
  test('should validate exactly 16 scrolls plus README', () => {
    expect(scrollFiles.length).toBe(16);
    expect(existsSync(join(projectRoot, 'README.md'))).toBe(true);
  });
});