#!/bin/bash

# Simple Hello World Test Script for Judge0
# Tests basic compilation and execution for all languages

set -e

echo "🌍 Hello World Language Tests"
echo "============================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test function
test_hello() {
    local name="$1"
    local cmd="$2"
    
    echo -e "${BLUE}Testing:${NC} $name"
    echo -e "Command: ${YELLOW}$cmd${NC}"
    
    if eval "$cmd" 2>/dev/null | grep -q "Hello World from $name"; then
        echo -e "${GREEN}✅ $name works${NC}"
        return 0
    else
        echo -e "${RED}❌ $name failed${NC}"
        return 1
    fi
}

# Test compilation and execution
test_compile_hello() {
    local name="$1"
    local compile_cmd="$2"
    local run_cmd="$3"
    local file="$4"
    
    echo -e "${BLUE}Testing:${NC} $name"
    echo -e "File: ${YELLOW}$file${NC}"
    echo -e "Compile: ${YELLOW}$compile_cmd${NC}"
    echo -e "Run: ${YELLOW}$run_cmd${NC}"
    
    if [ -f "$file" ]; then
        # Test compilation (if needed)
        if [ -n "$compile_cmd" ]; then
            if eval "$compile_cmd" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ $name compilation works${NC}"
            else
                echo -e "${RED}❌ $name compilation failed${NC}"
                return 1
            fi
        fi
        
        # Test execution
        if eval "$run_cmd" 2>/dev/null | grep -q "Hello World from $name"; then
            echo -e "${GREEN}✅ $name execution works${NC}"
            return 0
        else
            echo -e "${RED}❌ $name execution failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ File not found: $file${NC}"
        return 1
    fi
}

echo "📋 Testing Hello World Programs..."
echo ""

# Test 1: Node.js (interpreted)
test_hello "Node.js" "/usr/local/node-22.17.1/bin/node test-samples/hello.js"

# Test 2: TypeScript (compiled to JS)
test_compile_hello "TypeScript" "/usr/bin/tsc test-samples/hello.ts" "/usr/local/node-22.17.1/bin/node test-samples/hello.js" "test-samples/hello.ts"

# Test 3: Python (interpreted)
test_hello "Python" "/usr/local/python-3.12.7/bin/python3 test-samples/hello.py"

# Test 4: Go (compiled)
test_compile_hello "Go" "GOCACHE=/tmp/.cache/go-build /usr/local/go-1.24.5/bin/go build test-samples/hello.go" "./hello" "test-samples/hello.go"

# Test 5: Rust (compiled)
test_compile_hello "Rust" "/usr/local/rust-1.88.0/bin/rustc test-samples/hello.rs" "./hello" "test-samples/hello.rs"

# Test 6: C++ (compiled)
test_compile_hello "C++" "/usr/local/gcc-9.4.0/bin/g++ test-samples/hello.cpp" "LD_LIBRARY_PATH=/usr/local/gcc-9.4.0/lib64 ./a.out" "test-samples/hello.cpp"

# Test 7: Java (compiled)
test_compile_hello "Java" "/usr/local/openjdk21/bin/javac test-samples/Hello.java" "/usr/local/openjdk21/bin/java Hello" "test-samples/Hello.java"

echo ""
echo "============================================="
echo "🎯 Hello World Tests Completed!"
echo "============================================="
echo ""
echo "📋 Tested Languages:"
echo "  • Node.js (interpreted)"
echo "  • TypeScript (compiled to JS)"
echo "  • Python (interpreted)"
echo "  • Go (compiled)"
echo "  • Rust (compiled)"
echo "  • C++ (compiled)"
echo "  • Java (compiled)"
echo ""
echo "✅ All Hello World programs should work!"
echo ""
echo "🧹 Cleaning up..."
rm -f hello hello.js a.out Hello.class 2>/dev/null || true
echo "✅ Cleanup completed!" 