# Complete Anti-Slop & Quality Architecture (2026)

This document describes the multi-layered defense system implemented in this starter template to keep modern TypeScript and Python codebases clean, maintainable, secure, and free of AI-generated junk ("slop").

---

## The 8 Quality Layers

```
Layer 1: Duplication & Clones (jscpd)
   └── Sub-second cross-file copy-paste detection

Layer 2: Dead Code & Zombie Packages (Knip & Vulture/Deptry)
   └── Pruning unused files, unexported functions, and abandoned npm/pip dependencies

Layer 3: Framework-Specific Health (React Doctor)
   └── React 19/Next.js memory leaks, state misuse, unhandled promise crashes

Layer 4: High-Speed Rust Linters (Biome & Ruff)
   └── Sub-30ms AST syntax, import sorting, and basic lint checks

Layer 5: Type Strictness (type-coverage)
   └── Eliminating "any-slop" and enforcing real type coverage (>85%)

Layer 6: AI-Slop & Hallucination Gate (ai-slop-detector)
   └── Catching empty stubs, fake returns, and low logic-to-LOC density

Layer 7: Secret Detection & SAST Security (Gitleaks & Semgrep)
   └── Blocking leaked Supabase service role keys and vulnerable dynamic calls

Layer 8: Central Quality Gate & Historical Trends (SonarQube)
   └── Inter-procedural dataflow analysis, Cognitive Complexity limits, PR decoration
```

---

## Tool Breakdown & Configuration Reference

| Tool | Ecosystem | Config Location | What It Detects |
| :--- | :--- | :--- | :--- |
| **`jscpd`** | Universal | [`config/.jscpd.json`](file:///config/.jscpd.json) | Code clones across files (>5 lines or >50 tokens). |
| **`knip`** | TS / JS / Next.js | [`config/knip.json`](file:///config/knip.json) | Unused files, unused exports, unused npm packages, missing dependencies. |
| **`vulture`** | Python | [`config/.vulture_whitelist.py`](file:///config/.vulture_whitelist.py) | Unreachable Python functions, unused classes and attributes. |
| **`deptry`** | Python | [`config/deptry.toml`](file:///config/deptry.toml) | Unused dependencies in `pyproject.toml` or `requirements.txt`. |
| **`react-doctor`** | React / Next.js | [`config/.react-doctorrc.json`](file:///config/.react-doctorrc.json) | Leaked `createObjectURL`, promises without `finally`, array index keys. |
| **`biome`** | TS / JS | [`config/biome.json`](file:///config/biome.json) | Formatting, import sorting, bad idioms. (Rust-speed: ~15ms). |
| **`ruff`** | Python | [`config/ruff.toml`](file:///config/ruff.toml) | Complexity limits, bug patterns, Flake8 + Black replacement. |
| **`type-coverage`**| TypeScript | [`config/type-coverage.json`](file:///config/type-coverage.json) | Implicit and explicit `any` usage; enforces typed codebase. |
| **`ai-slop-detector`** | TS / JS / Python | [`config/.slopconfig.yaml`](file:///config/.slopconfig.yaml) | Mock implementations, empty catch blocks, hallucinated imports. |
| **`gitleaks`** | Universal | [`config/.gitleaks.toml`](file:///config/.gitleaks.toml) | Leaked API keys, Supabase service roles, private tokens. |
| **`semgrep`** | Universal | [`config/semgrep.yml`](file:///config/semgrep.yml) | Client-side service role imports, unsafe dynamic eval, XSS. |
| **`SonarQube`** | Universal | [`config/sonar-project.properties`](file:///config/sonar-project.properties) | Cognitive complexity, dataflow bugs, Quality Gate blocker. |

---

## Quick Execution

### Run Everything Locally:
```bash
# Full scan (all layers)
bash scripts/detect_slop.sh --all

# TypeScript / Next.js only
bash scripts/detect_slop.sh --ts

# Python only
bash scripts/detect_slop.sh --py
```

### Running Individual Layer Checks:
```bash
# Check dead code & zombie packages
npx knip --config config/knip.json

# Check React / Next.js health
npx react-doctor src

# Check copy-paste duplication
npx jscpd --config config/.jscpd.json .

# Check secrets
gitleaks detect --config config/.gitleaks.toml

# Check SAST security patterns
semgrep scan --config config/semgrep.yml
```

---

## CI/CD Pipeline Order

In GitHub Actions, checks should be arranged from fastest to slowest:

1. **Pre-commit / Fast Check (<5s)**: `biome` / `ruff` + `jscpd` + `gitleaks`
2. **PR Gate (<30s)**: `knip` + `react-doctor` + `type-coverage` + `semgrep`
3. **Server Gate (~1m)**: `SonarScanner` -> Local/Remote `SonarQube`
