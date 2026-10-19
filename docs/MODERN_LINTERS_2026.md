# Linters Modernos en 2026: Biome, Ruff y su Sinergia con SonarQube

Durante años, el ecosistema de análisis estático dependió de herramientas lentas basadas en Node.js o Python (ESLint, Prettier, Flake8, Black).

En 2026, la industria ha migrado a **motores nativos escritos en Rust**, que ofrecen velocidades entre **10x y 100x superiores**, reduciendo el feedback a meros milisegundos.

---

## 1. Las Dos Herramientas Estrella en Rust

### 1.1. Biome (JavaScript / TypeScript / JSX / JSON)
- **Qué reemplaza**: Unifica **ESLint** y **Prettier** en un único ejecutable.
- **Velocidad**: Formatea y analiza 100.000 líneas de código en menos de **0.1 segundos**.
- **Configuración única**: Archivo `config/biome.json`.
- **Comandos habituales**:
  ```bash
  # Verificar errores de formato y sintaxis
  npx @biomejs/biome check src/

  # Corregir automáticamente problemas de formato e imports
  npx @biomejs/biome check --write src/
  ```

### 1.2. Ruff (Python)
- **Qué reemplaza**: Flake8, Black, isort, pyupgrade y autoflake.
- **Velocidad**: Más de 100 veces más rápido que Flake8 tradicional.
- **Comandos habituales**:
  ```bash
  # Linter
  ruff check .

  # Formateador automático
  ruff format .
  ```

---

## 2. División de Roles: Linters en Rust vs SonarQube

| Dimensión | Linter en Rust (Biome / Ruff) | SonarQube Server 10.x |
| :--- | :--- | :--- |
| **Tiempo de respuesta** | **0.01 - 0.05 segundos** | **30 - 60 segundos** |
| **Punto de ejecución** | Local en tu editor al guardar (`Ctrl+S`) y pre-commit | En GitHub Actions durante Pull Requests y merges |
| **Alcance** | Archivo individual (AST local) | **Proyecto Completo (Global e Inter-procedural)** |
| **Capacidades únicas** | Formato de código, indentación, orden de imports, variables muertas locales. | **Taint Analysis** (rastreo de datos no confiables de un API a la BD), **detección de duplicados entre diferentes carpetas (CPD)**, complejidad cognitiva, cobertura de pruebas y Quality Gates formales. |

---

## 3. Configuración en VS Code y Cursor

Para disfrutar de retroalimentación inmediata mientras escribes código:

1. **Instalar Extensiones Recomendadas**:
   - Para TypeScript/JS: Extensión **Biome** (`biomejs.biome`).
   - Para Python: Extensión **Ruff** (`charliermarsh.ruff`).
   - Para SonarQube: Extensión **SonarQube for IDE** (antes SonarLint) (`SonarSource.sonarlint-vscode`).

2. **Configuración en `.vscode/settings.json`**:
   ```json
   {
     "editor.defaultFormatter": "biomejs.biome",
     "editor.formatOnSave": true,
     "editor.codeActionsOnSave": {
       "quickfix.biome": "explicit",
       "source.organizeImports.biome": "explicit"
     },
     "[python]": {
       "editor.defaultFormatter": "charliermarsh.ruff",
       "editor.formatOnSave": true
     }
   }
   ```

3. **Conectar SonarLint con tu VPS (Connected Mode)**:
   - En VS Code, abre la paleta de comandos (`Ctrl+Shift+P` o `Cmd+Shift+P`).
   - Selecciona **SonarLint: Connect to a SonarQube Server**.
   - URL: `https://sonar.tu-startup.com`
   - Ingresa tu `SONAR_TOKEN`.
   - Ahora, las reglas de tu servidor SonarQube se sincronizarán directamente en el editor de cada desarrollador.
