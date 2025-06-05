export interface ValidationError {
  type: string;
  severity: 'error' | 'warning';
  file: string;
  line?: number;
  description: string;
  suggestion?: string;
  details?: Record<string, unknown>;
}

export interface ValidationResult {
  suite: string;
  passed: boolean;
  timestamp: string;
  summary: {
    total: number;
    passed: number;
    failed: number;
  };
  errors: ValidationError[];
}

export abstract class BaseValidator {
  abstract name: string;
  
  protected projectRoot: string;
  
  constructor(projectRoot: string = process.cwd()) {
    this.projectRoot = projectRoot;
  }
  
  abstract validate(): Promise<ValidationResult>;
  
  protected createResult(errors: ValidationError[], total: number): ValidationResult {
    return {
      suite: this.name,
      passed: errors.length === 0,
      timestamp: new Date().toISOString(),
      summary: {
        total,
        passed: total - errors.length,
        failed: errors.length
      },
      errors
    };
  }
}