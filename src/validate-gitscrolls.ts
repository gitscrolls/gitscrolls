#!/usr/bin/env node

import { runAllValidators } from './index';
import { resolve } from 'path';

async function main() {
  console.log('GitScrolls Narrative Validation\n');
  console.log('================================\n');
  
  const projectRoot = resolve(__dirname, '..');
  const results = await runAllValidators(projectRoot);
  
  // Print summary
  console.log('\nValidation Summary');
  console.log('==================\n');
  
  let totalErrors = 0;
  let totalWarnings = 0;
  
  for (const result of results) {
    const errors = result.errors.filter(e => e.severity === 'error').length;
    const warnings = result.errors.filter(e => e.severity === 'warning').length;
    
    totalErrors += errors;
    totalWarnings += warnings;
    
    console.log(`${result.suite}:`);
    console.log(`  Status: ${result.passed ? '✅ PASSED' : '❌ FAILED'}`);
    console.log(`  Errors: ${errors}`);
    console.log(`  Warnings: ${warnings}`);
    console.log('');
  }
  
  console.log('Overall Results:');
  console.log(`  Total Errors: ${totalErrors}`);
  console.log(`  Total Warnings: ${totalWarnings}`);
  
  // Exit with appropriate code
  process.exit(totalErrors > 0 ? 1 : 0);
}

main().catch(error => {
  console.error('Validation error:', error);
  process.exit(1);
});