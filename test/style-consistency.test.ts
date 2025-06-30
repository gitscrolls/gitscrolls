const { readFileSync } = require('fs');
const { join } = require('path');
const { getGitTrackedFilesInDir } = require('./git-tracked-files');

interface StyleError {
  file: string;
  line: number;
  column: number;
  message: string;
  severity: 'error' | 'warning';
}


class StyleConsistencyChecker {
  private errors: StyleError[] = [];
  private fileName: string = '';
  
  constructor(fileName: string) {
    this.fileName = fileName;
  }

  check(content: string): StyleError[] {
    this.errors = [];
    const lines = content.split('\n');
    
    // Check various style elements line by line
    lines.forEach((line, index) => {
      const lineNum = index + 1;
      
      // Check main quote formatting (within first 30 lines)
      if (lineNum < 30 && line.startsWith('>')) {
        this.checkQuoteFormatting(line, lineNum);
      }
      
      // Check section headers
      if (line.startsWith('###')) {
        this.checkSectionHeaders(line, lineNum);
      }
      
      // Check character dialogue
      this.checkCharacterDialogue(line, lineNum);
      
      // Check navigation links
      this.checkNavigationLinks(line, lineNum);
    });
    
    // Check footer attribution
    this.checkFooterAttribution(content);
    
    return this.errors;
  }
  
  private checkQuoteFormatting(line: string, lineNum: number) {
    // Check for quotes using italics instead of bold
    if (line.match(/^>\s*\*".*"\*$/)) {
      this.addError(
        lineNum,
        1,
        'Main quotes should use bold (__"quote"__) not italics (*"quote"*)',
        'error'
      );
    }
    // Check if it's missing formatting entirely
    else if (line.match(/^>\s*".*"$/) && !line.match(/^>\s*__".*"__$/)) {
      this.addError(
        lineNum,
        1,
        'Main quotes should be formatted with bold: __"quote"__',
        'error'
      );
    }
  }
  
  private checkSectionHeaders(line: string, lineNum: number) {
    // Check for Act vs Scene
    if (line.match(/^###\s+Act\s+[IVX0-9]+:/i)) {
      // Exception for Scroll 8 which uses "Circle" appropriately
      if (!line.includes('Circle')) {
        this.addError(
          lineNum,
          1,
          'Use "Scene" instead of "Act" for section headers',
          'error'
        );
      }
    }
    
    // Check for Arabic numerals in Scene headers
    if (line.match(/^###\s+Scene\s+[0-9]+:/i)) {
      this.addError(
        lineNum,
        1,
        'Use Roman numerals (I, II, III) instead of Arabic numerals for Scene headers',
        'error'
      );
    }
  }
  
  private checkCharacterDialogue(line: string, lineNum: number) {
    // Check for bold character names instead of underline
    // But exclude common patterns that aren't character dialogue
    if (line.match(/^\*\*[A-Z][a-zA-Z\s]+:\*\*/)) {
      // Exclude patterns like "The Something:", "Path of", etc.
      const excludePatterns = [
        /^\*\*The [A-Z]/,
        /^\*\*Path of/,
        /^\*\*But the/,
        /^\*\*Note:/,
        /^\*\*Warning:/,
        /^\*\*Important:/,
        /^\*\*Tip:/,
        /^\*\*Example:/
      ];
      
      const isExcluded = excludePatterns.some(pattern => line.match(pattern));
      
      if (!isExcluded) {
        this.addError(
          lineNum,
          1,
          'Character names should use underline (__Name:__) not bold (**Name:**)',
          'warning'
        );
      }
    }
  }
  
  private checkNavigationLinks(line: string, lineNum: number) {
    // Check for navigation links using underline instead of bold
    if (line.match(/^__Next:\s+/)) {
      this.addError(
        lineNum,
        1,
        'Navigation links should use bold (**Next:**) not underline (__Next:__)',
        'warning'
      );
    }
  }
  
  private checkFooterAttribution(content: string) {
    const hasAttribution = content.includes('GitScrolls: The Epic of Tuxicles') && 
                          content.includes('© 2025 J. Kirby Ross');
    const scrollNumber = this.fileName.match(/\d+/)?.[0];
    
    if (!hasAttribution && scrollNumber) {
      const lines = content.split('\n');
      this.addError(
        lines.length,
        1,
        'Missing footer attribution block',
        'error'
      );
    }
  }
  
  private addError(line: number, column: number, message: string, severity: 'error' | 'warning') {
    this.errors.push({
      file: this.fileName,
      line,
      column,
      message,
      severity
    });
  }
}

describe('GitScrolls Style Consistency', () => {
  const projectRoot = join(__dirname, '..');
  const scrollsDir = join(projectRoot, 'scrolls');
  
  // Get all scroll files
  const scrollFiles = getGitTrackedFilesInDir('scrolls').sort();
  
  // Test each scroll file
  scrollFiles.forEach((file: string) => {
    test(`Scroll: ${file} should follow consistent style guidelines`, () => {
      const filePath = join(scrollsDir, file);
      const content = readFileSync(filePath, 'utf-8');
      
      const checker = new StyleConsistencyChecker(file);
      const errors = checker.check(content);
      
      // Treat all errors and warnings as failures
      if (errors.length > 0) {
        const errorMessages = errors.map((e: StyleError) => 
          `Line ${e.line}, Column ${e.column}: ${e.message} [${e.severity}]`
        ).join('\n');
        throw new Error(`Style consistency issues in ${file}:\n${errorMessages}`);
      }
    });
  });
  
  // Test for common issues across all files
  test('All scrolls should have consistent footer attribution', () => {
    const missingAttribution: string[] = [];
    
    scrollFiles.forEach((file: string) => {
      const filePath = join(scrollsDir, file);
      const content = readFileSync(filePath, 'utf-8');
      
      if (!content.includes('GitScrolls: The Epic of Tuxicles') || 
          !content.includes('© 2025 J. Kirby Ross')) {
        missingAttribution.push(file);
      }
    });
    
    // We expect all scrolls to have attribution now
    expect(missingAttribution.length).toBe(0);
    
    if (missingAttribution.length > 0) {
      throw new Error(`Missing footer attribution in: ${missingAttribution.join(', ')}`);
    }
  });
  
  // Test teaching number consistency
  test('Teaching numbers should match scroll numbers', () => {
    const inconsistencies: string[] = [];
    
    scrollFiles.forEach((file: string) => {
      const scrollNumber = file.match(/(\d+)/)?.[1];
      if (!scrollNumber) return;
      
      const filePath = join(scrollsDir, file);
      const content = readFileSync(filePath, 'utf-8');
      
      // Convert number to ordinal
      const ordinals: { [key: string]: string } = {
        '01': 'First', '02': 'Second', '03': 'Third', '04': 'Fourth',
        '05': 'Fifth', '06': 'Sixth', '07': 'Seventh', '08': 'Eighth',
        '09': 'Ninth', '10': 'Tenth', '11': 'Eleventh', '12': 'Twelfth',
        '13': 'Thirteenth', '14': 'Fourteenth', '15': 'Fifteenth', '16': 'Sixteenth'
      };
      
      const expectedOrdinal = ordinals[scrollNumber];
      const teachingMatch = content.match(/##\s+The\s+(\w+)\s+Teaching:/);
      
      if (teachingMatch && teachingMatch[1] !== expectedOrdinal) {
        inconsistencies.push(`${file}: Expected "${expectedOrdinal} Teaching" but found "${teachingMatch[1]} Teaching"`);
      }
    });
    
    if (inconsistencies.length > 0) {
      throw new Error(`Teaching number inconsistencies:\n${inconsistencies.join('\n')}`);
    }
  });
  
  // Test for emotional beat consistency
  test('Emotional beats should use consistent format', () => {
    const inconsistentBeats: string[] = [];
    
    scrollFiles.forEach((file: string) => {
      const filePath = join(scrollsDir, file);
      const content = readFileSync(filePath, 'utf-8');
      const lines = content.split('\n');
      
      lines.forEach((line: string, index: number) => {
        // Check for emotional beats
        if (line.includes('Emotional Beat:') || line.includes('Emotional Beat Evolution:')) {
          if (!line.startsWith('**Emotional Beat')) {
            inconsistentBeats.push(`${file}:${index + 1} - Emotional beat not formatted with bold markers`);
          }
        }
      });
    });
    
    if (inconsistentBeats.length > 0) {
      console.warn('Emotional beat formatting issues:\n' + inconsistentBeats.join('\n'));
    }
  });
  
  // Test that all @TempleSentinel messages are in code blocks
  test('All @TempleSentinel messages should be in code blocks', () => {
    const errors: string[] = [];
    
    scrollFiles.forEach((file: string) => {
      // Skip @TempleSentinel check for scroll 16 (contains narrative references)
      if (file === '16-Where-Heroes-Go-to-Die.md') {
        return;
      }
      
      const filePath = join(scrollsDir, file);
      const content = readFileSync(filePath, 'utf-8');
      const lines = content.split('\n');
      
      let inCodeBlock = false;
      let codeBlockStart = -1;
      
      lines.forEach((line: string, index: number) => {
        // Track code block state - handle both ``` and ```language
        if (line.trim().startsWith('```')) {
          if (!inCodeBlock) {
            inCodeBlock = true;
            codeBlockStart = index;
          } else {
            inCodeBlock = false;
            codeBlockStart = -1;
          }
        }
        
        // Check for @TempleSentinel outside of code blocks
        if (line.includes('@TempleSentinel') && !inCodeBlock) {
          // Check if it's a formatted message that should be in a code block
          if (line.match(/@TempleSentinel:\s*["'"]/)) {
            // This looks like a TempleSentinel message/quote with colon
            errors.push(`${file}:${index + 1} - @TempleSentinel message should be in a code block`);
          }
          // Check for markdown formatted TempleSentinel
          else if (line.match(/^(\*\*@TempleSentinel:\*\*|__@TempleSentinel:__)/)) {
            errors.push(`${file}:${index + 1} - @TempleSentinel should not have markdown formatting and should be in a code block`);
          }
        }
      });
      
      // Check for unclosed code block at end of file
      if (inCodeBlock) {
        errors.push(`${file}:${codeBlockStart + 1} - Unclosed code block started here`);
      }
    });
    
    if (errors.length > 0) {
      throw new Error(`@TempleSentinel formatting errors:\n${errors.join('\n')}`);
    }
  });
});