import { LinkGraphValidator } from '../../validators/link-graph-validator';
import { mkdtempSync, writeFileSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';
import { rmSync } from 'fs';

describe('LinkGraphValidator', () => {
  let tempDir: string;
  let validator: LinkGraphValidator;
  
  beforeEach(() => {
    tempDir = mkdtempSync(join(tmpdir(), 'gitscrolls-test-'));
    validator = new LinkGraphValidator(tempDir);
  });
  
  afterEach(() => {
    rmSync(tempDir, { recursive: true, force: true });
  });
  
  test('detects broken links', async () => {
    // Create a file with a broken link
    writeFileSync(
      join(tempDir, 'test.md'),
      `# Test Document\n\nThis is a [broken link](./nonexistent.md).`
    );
    
    const result = await validator.validate();
    
    expect(result.passed).toBe(false);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0].type).toBe('broken_link');
    expect(result.errors[0].description).toContain('non-existent file');
  });
  
  test('validates correct links', async () => {
    // Create two linked files
    writeFileSync(
      join(tempDir, 'README.md'),
      `# Main Document\n\nSee [other document](./other.md).`
    );
    
    writeFileSync(
      join(tempDir, 'other.md'),
      `# Other Document\n\nBack to [main](./README.md).`
    );
    
    const result = await validator.validate();
    
    expect(result.passed).toBe(true);
    expect(result.errors).toHaveLength(0);
  });
  
  test('detects orphaned documents', async () => {
    // Create README that links to one file but not another
    writeFileSync(
      join(tempDir, 'README.md'),
      `# Main\n\nSee [linked](./linked.md).`
    );
    
    writeFileSync(
      join(tempDir, 'linked.md'),
      `# Linked Document`
    );
    
    writeFileSync(
      join(tempDir, 'orphaned.md'),
      `# Orphaned Document`
    );
    
    const result = await validator.validate();
    
    expect(result.passed).toBe(false);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0].type).toBe('orphaned_document');
    expect(result.errors[0].file).toBe('orphaned.md');
  });
  
  test('handles nested directories', async () => {
    // Create nested structure
    const subdir = join(tempDir, 'docs');
    mkdirSync(subdir);
    
    writeFileSync(
      join(tempDir, 'README.md'),
      `# Main\n\nSee [docs](./docs/guide.md).`
    );
    
    writeFileSync(
      join(subdir, 'guide.md'),
      `# Guide\n\nBack to [main](../README.md).`
    );
    
    const result = await validator.validate();
    
    expect(result.passed).toBe(true);
    expect(result.errors).toHaveLength(0);
  });
  
  test('warns about potential title mismatches', async () => {
    writeFileSync(
      join(tempDir, 'README.md'),
      `# Main\n\nSee [GitScroll I: The Wrong Title](./scroll.md).`
    );
    
    writeFileSync(
      join(tempDir, 'scroll.md'),
      `# GitScroll I: The Correct Title`
    );
    
    const result = await validator.validate();
    
    expect(result.passed).toBe(false);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0].type).toBe('title_mismatch');
    expect(result.errors[0].severity).toBe('warning');
  });
  
  test('ignores external links', async () => {
    writeFileSync(
      join(tempDir, 'README.md'),
      `# Main\n\nSee [external](https://example.com).`
    );
    
    const result = await validator.validate();
    
    expect(result.passed).toBe(true);
    expect(result.errors).toHaveLength(0);
  });
  
  test('ignores anchor links', async () => {
    writeFileSync(
      join(tempDir, 'README.md'),
      `# Main\n\nSee [section](#section).`
    );
    
    const result = await validator.validate();
    
    expect(result.passed).toBe(true);
    expect(result.errors).toHaveLength(0);
  });
});