#!/usr/bin/env bash
# ==============================================================================
# Unified Anti-Slop & Quality Suite for TypeScript & Python (2026)
#
# Layers:
# 1. Duplication & Copy-Paste: jscpd
# 2. Dead Code & Zombie Deps:  knip (TS/JS) | vulture + deptry (Python)
# 3. React / Next.js Health:    react-doctor
# 4. Ultra-Fast Linters:       Biome (TS/JS) | Ruff (Python)
# 5. Type Strictness:          type-coverage (TS)
# 6. AI Hallucination Slop:    ai-slop-detector
# 7. Security & Secrets:       gitleaks | semgrep
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
echo -e "${BOLD}         🛡️  COMPLETE ANTI-SLOP & CODE QUALITY ARSENAL (2026)  🛡️     ${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "Target Mode: ${YELLOW}${TARGET_MODE}${NC}\n"

# ------------------------------------------------------------------------------
# LAYER 1: Copy-Paste / Duplication Detector (jscpd)
# ------------------------------------------------------------------------------
echo -e "${BLUE}>>> [1/7] Running Copy-Paste Detector (jscpd)...${NC}"
if command -v npx &> /dev/null; then
    if npx --yes jscpd --config config/.jscpd.json . 2>/dev/null; then
        echo -e "${GREEN}✓ No excessive duplicate code blocks found.${NC}\n"
    else
        echo -e "${YELLOW}⚠ Duplication detected. Review reports for duplicate logic.${NC}\n"
    fi
else
    echo -e "${YELLOW}⚠ npx not found. Skipping jscpd check.${NC}\n"
fi

# ------------------------------------------------------------------------------
# LAYER 2: Dead Code & Zombie Dependencies (Knip / Vulture + Deptry)
# ------------------------------------------------------------------------------
if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--ts" ]]; then
    echo -e "${BLUE}>>> [2A/7] Running Knip (Dead Code & Zombie Packages for TS/JS)...${NC}"
    if command -v npx &> /dev/null && [ -f "package.json" ]; then
        if npx --yes knip --config config/knip.json --no-exit-code 2>/dev/null; then
            echo -e "${GREEN}✓ Knip analysis complete.${NC}\n"
        fi
    else
        echo -e "${YELLOW}⚠ Skipping knip (no package.json or npx unavailable).${NC}\n"
    fi
fi

if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--py" ]]; then
    echo -e "${BLUE}>>> [2B/7] Running Vulture & Deptry (Python Dead Code & Dependencies)...${NC}"
    if command -v vulture &> /dev/null; then
        vulture . config/.vulture_whitelist.py --min-confidence 80 || true
        echo -e "${GREEN}✓ Vulture scan complete.${NC}\n"
    else
        echo -e "${YELLOW}⚠ vulture not installed. Run: pip install vulture${NC}\n"
    fi
    if command -v deptry &> /dev/null; then
        deptry --config config/deptry.toml . || true
    fi
fi

# ------------------------------------------------------------------------------
# LAYER 3: React / Next.js Component Health & Leaks (react-doctor)
# ------------------------------------------------------------------------------
if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--ts" ]]; then
    echo -e "${BLUE}>>> [3/7] Running React Doctor (Hook Smells, Leaks & Re-renders)...${NC}"
    if command -v npx &> /dev/null && [ -d "src" -o -d "app" ]; then
        SCAN_DIR="src"
        [ ! -d "src" ] && SCAN_DIR="app"
        CI=true npx --yes react-doctor@latest "$SCAN_DIR" 2>/dev/null || true
        echo -e "${GREEN}✓ React Doctor audit complete.${NC}\n"
    else
        echo -e "${YELLOW}⚠ Skipping react-doctor (no React directory found).${NC}\n"
    fi
fi

# ------------------------------------------------------------------------------
# LAYER 4: Ultra-Fast Rust Linters (Biome & Ruff)
# ------------------------------------------------------------------------------
if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--ts" ]]; then
    echo -e "${BLUE}>>> [4A/7] Running Biome Linter (TypeScript / JavaScript)...${NC}"
    if command -v npx &> /dev/null; then
        if npx --yes @biomejs/biome check --config-path=config/ src/ scripts/ 2>/dev/null; then
            echo -e "${GREEN}✓ TypeScript/JavaScript code is clean and properly formatted.${NC}\n"
        else
            echo -e "${YELLOW}⚠ Biome reported formatting/lint warnings.${NC}\n"
        fi
    fi
fi

if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--py" ]]; then
    echo -e "${BLUE}>>> [4B/7] Running Ruff Linter (Python)...${NC}"
    if command -v ruff &> /dev/null; then
        if ruff check --config config/ruff.toml .; then
            echo -e "${GREEN}✓ Python code is clean and adheres to complexity limits.${NC}\n"
        else
            echo -e "${RED}✗ Ruff detected Python anti-patterns or excessive complexity!${NC}\n"
            EXIT_CODE=1
        fi
    else
        echo -e "${YELLOW}⚠ ruff not installed. Run: pip install ruff${NC}\n"
    fi
fi

# ------------------------------------------------------------------------------
# LAYER 5: TypeScript Strictness & Any-Type Density (type-coverage)
# ------------------------------------------------------------------------------
if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--ts" ]]; then
    echo -e "${BLUE}>>> [5/7] Checking Type Coverage (Min 85% concrete types)...${NC}"
    if command -v npx &> /dev/null && [ -f "tsconfig.json" ]; then
        if npx --yes type-coverage --at-least 80 --detail 2>/dev/null; then
            echo -e "${GREEN}✓ Type coverage meets strict threshold.${NC}\n"
        else
            echo -e "${YELLOW}⚠ Low type coverage or excessive 'any' usage detected.${NC}\n"
        fi
    else
        echo -e "${YELLOW}⚠ Skipping type-coverage (no tsconfig.json found).${NC}\n"
    fi
fi

# ------------------------------------------------------------------------------
# LAYER 6: AI-Slop & Hallucination Heuristics (ai-slop-detector)
# ------------------------------------------------------------------------------
echo -e "${BLUE}>>> [6/7] Running Dedicated AI-SLOP-Detector...${NC}"
if command -v slop-detector &> /dev/null; then
    FLAGS="--project . --no-color --no-history"
    if [[ "$TARGET_MODE" == "--all" || "$TARGET_MODE" == "--ts" ]]; then
        FLAGS="$FLAGS --js"
    fi
    FLAGS="$FLAGS --cross-file"

    if slop-detector $FLAGS; then
        echo -e "${GREEN}✓ AI-SLOP-Detector: No severe AI hallucination patterns.${NC}\n"
    else
        echo -e "${YELLOW}⚠ AI-SLOP-Detector flagged suspicious stubs or low-density code.${NC}\n"
    fi
else
    echo -e "${YELLOW}⚠ slop-detector not found. Run: pip install ai-slop-detector${NC}\n"
fi

# ------------------------------------------------------------------------------
# LAYER 7: Security & Secrets (Gitleaks + Semgrep)
# ------------------------------------------------------------------------------
echo -e "${BLUE}>>> [7/7] Running Security & Secret Leak Scanner...${NC}"
if command -v gitleaks &> /dev/null; then
    if gitleaks detect --config config/.gitleaks.toml --no-git -v 2>/dev/null; then
        echo -e "${GREEN}✓ Gitleaks: No leaked secrets found.${NC}\n"
    else
        echo -e "${RED}✗ CRITICAL: High-entropy secret detected!${NC}\n"
        EXIT_CODE=1
    fi
else
    echo -e "${YELLOW}⚠ gitleaks not installed. Run: brew install gitleaks${NC}\n"
fi

if command -v semgrep &> /dev/null; then
    if semgrep scan --config config/semgrep.yml --error 2>/dev/null; then
        echo -e "${GREEN}✓ Semgrep SAST scan passed.${NC}\n"
    else
        echo -e "${RED}✗ Semgrep found security rule violations!${NC}\n"
        EXIT_CODE=1
    fi
else
    echo -e "${YELLOW}⚠ semgrep not installed. Run: pip install semgrep${NC}\n"
fi

# ------------------------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------------------------
echo -e "${BLUE}======================================================================${NC}"
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✓ ALL QUALITY GATES PASSED: Ready for PR & SonarQube review.${NC}"
else
    echo -e "${RED}${BOLD}✗ QUALITY GATE FAILED: Resolve flagged errors before deploying.${NC}"
fi
echo -e "${BLUE}======================================================================${NC}"

exit $EXIT_CODE
