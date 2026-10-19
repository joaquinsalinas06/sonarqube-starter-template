#!/usr/bin/env bash
# ==============================================================================
# Unified Anti-Slop Suite for TypeScript & Python (2026)
# Combines: jscpd (Duplication) + Biome (TS/JS) + Ruff (Python) + AI-SLOP-Detector
# ==============================================================================

set -uo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

TARGET_MODE="${1:---all}"
EXIT_CODE=0

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BOLD}         🛡️  UNIFIED ANTI-SLOP DETECTION SUITE (2026)  🛡️           ${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "Target Mode: ${YELLOW}${TARGET_MODE}${NC}\n"

# ------------------------------------------------------------------------------
# STEP 1: Copy-Paste / Duplication Detector (jscpd)
# ------------------------------------------------------------------------------
echo -e "${BLUE}>>> [1/3] Running Copy-Paste Detector (jscpd)...${NC}"
if command -v npx &> /dev/null; then
    if npx --yes jscpd --config config/.jscpd.json .; then
        echo -e "${GREEN}✓ No excessive duplicate code blocks found.${NC}\n"
    else
        echo -e "${RED}✗ Excessive duplication detected! Refactor copy-pasted blocks.${NC}\n"
        EXIT_CODE=1
    fi
else
    echo -e "${YELLOW}⚠ npx not found. Skipping jscpd check.${NC}\n"
fi

# ------------------------------------------------------------------------------
# STEP 2: Modern Rust Linters (Biome for TS/JS & Ruff for Python)
# ------------------------------------------------------------------------------
if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--ts" ]]; then
    echo -e "${BLUE}>>> [2A/3] Running Biome Linter for TypeScript / JavaScript...${NC}"
    if command -v npx &> /dev/null; then
        if npx --yes @biomejs/biome check --config-path=config/ src/ scripts/ 2>/dev/null; then
            echo -e "${GREEN}✓ TypeScript/JavaScript code is clean and properly formatted.${NC}\n"
        else
            echo -e "${YELLOW}⚠ Biome reported formatting/lint warnings in TS/JS.${NC}\n"
        fi
    fi
fi

if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--py" ]]; then
    echo -e "${BLUE}>>> [2B/3] Running Ruff Linter for Python...${NC}"
    if command -v ruff &> /dev/null; then
        if ruff check --config config/ruff.toml .; then
            echo -e "${GREEN}✓ Python code is clean and adheres to complexity limits.${NC}\n"
        else
            echo -e "${RED}✗ Ruff detected Python anti-patterns or excessive complexity!${NC}\n"
            EXIT_CODE=1
        fi
    else
        echo -e "${YELLOW}⚠ ruff not installed in PATH. Install with: pip install ruff${NC}\n"
    fi
fi

# ------------------------------------------------------------------------------
# STEP 3: Dedicated AI-SLOP-Detector
# ------------------------------------------------------------------------------
echo -e "${BLUE}>>> [3/3] Running Dedicated AI-SLOP-Detector...${NC}"
if command -v slop-detector &> /dev/null; then
    FLAGS="--project . --no-color --no-history"
    if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--ts" ]]; then
        FLAGS="$FLAGS --js"
    fi
    FLAGS="$FLAGS --cross-file --gate"

    if slop-detector $FLAGS; then
        echo -e "${GREEN}✓ AI-SLOP-Detector Gate: PASSED${NC}\n"
    else
        echo -e "${RED}✗ AI-SLOP-Detector Gate: HALTED! AI slop or type bypass detected.${NC}\n"
        EXIT_CODE=1
    fi
else
    echo -e "${YELLOW}⚠ slop-detector not found. Install with: pip install ai-slop-detector${NC}\n"
fi

# ------------------------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------------------------
echo -e "${BLUE}======================================================================${NC}"
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✓ ALL ANTI-SLOP CHECKS PASSED: Codebase is clean and maintainable.${NC}"
else
    echo -e "${RED}${BOLD}✗ ANTI-SLOP CHECKS FAILED: Resolve the flagged issues before merging.${NC}"
fi
echo -e "${BLUE}======================================================================${NC}"

exit $EXIT_CODE
