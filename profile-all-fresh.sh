#!/bin/bash
# Profile all test files with fresh Raku process for each

TESTDIR="test-files/common"
TOTAL_TIME=0
PASSED=0
FAILED=0

echo "🧪 Grammar Test Suite - Fresh Process Profiling"
echo "=========================================="
echo ""

for test_file in $(ls "$TESTDIR"/*.xen | sort); do
    filename=$(basename "$test_file")
    
    result=$( { time raku -Ilib -e "
use Xenober16::Grammar;
my \$text = slurp '$test_file';
my \$r = Xenober16::Grammar.parse(\$text);
exit(\$r ?? 0 !! 1);
" 2>&1; } 2>&1)
    
    exit_code=$?
    
    # Extract timing from stderr
    timing=$(echo "$result" | grep "real" | awk '{print $2}')
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ $filename $timing"
        ((PASSED++))
    else
        echo "❌ $filename $timing"
        ((FAILED++))
    fi
done

echo ""
echo "=========================================="
echo "Results: ✅ $PASSED passed, ❌ $FAILED failed"
echo "Total: $((PASSED + FAILED)) tests"
