import { LinkGraphValidator } from './validators/link-graph-validator';
import { ValidationResult } from './core/base-validator';

export async function runAllValidators(projectRoot: string = process.cwd()): Promise<ValidationResult[]> {
  const validators = [
    new LinkGraphValidator(projectRoot),
    // Add more validators here as they're implemented
  ];
  
  const results: ValidationResult[] = [];
  
  for (const validator of validators) {
    console.log(`Running ${validator.name}...`);
    const result = await validator.validate();
    results.push(result);
    
    // Print summary
    console.log(`  Total checks: ${result.summary.total}`);
    console.log(`  Passed: ${result.summary.passed}`);
    console.log(`  Failed: ${result.summary.failed}`);
    
    if (result.errors.length > 0) {
      console.log(`  Errors:`);
      for (const error of result.errors) {
        console.log(`    - [${error.severity}] ${error.file}:${error.line || 0} - ${error.description}`);
      }
    }
    
    console.log('');
  }
  
  return results;
}

// CLI entry point
if (require.main === module) {
  runAllValidators()
    .then(results => {
      const allPassed = results.every(r => r.passed);
      process.exit(allPassed ? 0 : 1);
    })
    .catch(error => {
      console.error('Validation failed:', error);
      process.exit(1);
    });
}