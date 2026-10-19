# Guía Definitiva de Prevención y Detección de "AI Slop" (TypeScript & Python)

En 2026, los asistentes de código generativo (Cursor, Claude Code, GitHub Copilot, Devin) aumentan la velocidad de desarrollo 5x, pero introducen una nueva categoría de deuda técnica conocida como **"AI Slop"**:
- **Duplicaciones desmedidas**: La IA prefiere reescribir funciones auxiliares una y otra vez en vez de reutilizar abstracciones existentes.
- **Evasión de tipos**: Elusión sistemática del tipado estricto mediante `any` o casts genéricos forzados.
- **Stubs y código "falso-terminado"**: Funciones vacías (`pass` o `// TODO: implement later`) que parecen completas pero no ejecutan lógica.
- **Captura ciega de excepciones**: Bloques `except Exception: pass` o `catch(e) {}` que enmascaran errores críticos en producción.
- **Complejidad cognitiva inflada**: Bloques `if/else` y ternarios hiper-anidados con complejidad > 15.

Esta suite unifica las herramientas más avanzadas de la industria para erradicar el AI Slop tanto en **TypeScript/JavaScript** como en **Python**.

---

## 1. El Arsenal de Herramientas Anti-Slop Integrado

| Herramienta | Lenguaje | Propósito Principal | Detección Clave |
| :--- | :--- | :--- | :--- |
| **`jscpd`** | TS, JS, Python | Detector de Duplicación (CPD) en milisegundos. | Encuentra clones exactos o casi-idénticos entre diferentes archivos. |
| **`biome`** | TS, JS, JSX | Linter y formateador ultrarrápido en Rust (0.03s). | Atrapa `noExplicitAny`, complejidad cognitiva y formato roto. |
| **`ruff`** | Python | Linter y formateador ultrarrápido en Rust (0.02s). | Atrapa excepciones tragadas, complejidad McCabe > 15 e imports fantasma. |
| **`ai-slop-detector`** | TS, JS, Python | Analizador heurístico de código de IA. | Stubs vacíos, Logic Density Ratio (LDR) baja, dependencias desconectadas. |
| **SonarQube Server** | 30+ Lenguajes | Gobernanza centralizada y Quality Gate. | Taint Analysis (OWASP), bugs semánticos y reglas "Clean as You Code". |

---

## 2. Ejecución Local de la Suite

Puedes correr toda la suite con un solo comando:

```bash
# Analizar todo el repositorio (TypeScript + Python)
./scripts/detect_slop.sh

# Analizar solo TypeScript / JavaScript
./scripts/detect_slop.sh --ts

# Analizar solo Python
./scripts/detect_slop.sh --py
```

---

## 3. Integración en Pull Requests (CI/CD)

El archivo `templates/workflows/anti-slop-ci.yml` viene listo para ser usado en GitHub Actions:
1. En cada Pull Request a `main` o `dev`, se dispara automáticamente el chequeo.
2. Si un PR introduce duplicación > 3%, excepciones tragadas o stubs vacíos, el job alerta y bloquea el merge.
3. Permite que el equipo mantenga la base de código limpia de forma totalmente automatizada.

---

## 4. Archivos de Configuración Incluidos

- [`config/ruff.toml`](../config/ruff.toml): Reglas de complejidad McCabe y buenas prácticas para Python.
- [`config/biome.json`](../config/biome.json): Reglas de tipado estricto y complejidad para TypeScript.
- [`config/.jscpd.json`](../config/.jscpd.json): Umbral del 3% de duplicación para TS y Python.
- [`config/.slopconfig.yaml`](../config/.slopconfig.yaml): Umbrales de densidad lógica y exclusiones para el detector de slop.
