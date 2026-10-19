# Integración de Subagentes de IA: Reducción Autónoma de "AI Slop"

Con la adopción masiva de asistentes de código (Cursor, Claude Code, GitHub Copilot, Devin), los equipos de ingeniería producen funcionalidades a una velocidad sin precedentes.

Sin embargo, esto ha generado un nuevo desafío en 2026: **el "AI Slop" (código redundante, duplicaciones de lógica sutiles, funciones hiper-anidadas con complejidad cognitiva excesiva y ausencia de tipado estricto)**.

SonarQube actúa como el **juez determinista de calidad**, y la herramienta `sonar_ai_bridge.py` permite cerrar el bucle permitiendo que los agentes de IA se auto-corrijan antes del merge.

---

## 1. El Bucle de Autocorrección

```
      [ Asistente IA / Desarrollador ]
                     │
                     ▼ (Push a PR)
      [ Sonar-Scanner en CI/CD (<90s) ]
                     │
                     ▼ (Evalúa Quality Gate)
        [ ¿Quality Gate FAILED? ]
               /           \
           (Sí)             (No) ──> [ Merge Aprobado ✅ ]
             │
             ▼
      [ sonar_ai_bridge.py ]
      (Filtra issues en New Code)
             │
             ▼
      [ Prompt Estructurado para Agente ]
             │
             ▼
      [ Subagente IA (Claude / Cursor) ]
      (Aplica parche Git y re-testea)
             │
             ▼
      [ Nuevo Commit / Fix PR ]
```

---

## 2. Uso de la Herramienta `sonar_ai_bridge.py`

La herramienta no requiere librerías externas (solo Python 3.8+).

### Probar en Modo Simulación (Mock):
Puedes ver cómo genera los prompts de remediación sin necesidad de tener el servidor levantado todavía:
```bash
python3 scripts/sonar_ai_bridge.py --mock-test --format=prompt
```

### Consultar tu Servidor SonarQube Real:
```bash
python3 scripts/sonar_ai_bridge.py \
  --url="https://sonar.tu-startup.com" \
  --token="sqp_tu_token_aqui" \
  --project="my-startup-project" \
  --branch="dev" \
  --format="prompt" \
  --output-file="prompt_para_agente.txt"
```

### Opciones Disponibles:
- `--all-code`: Por defecto, la herramienta solo extrae issues del **código nuevo** (`inNewCodePeriod=true`). Con este flag inspecciona todo el proyecto histórico.
- `--severities`: Filtra qué nivel de severidad extraer (ej: `BLOCKER,CRITICAL,MAJOR`).
- `--format`:
  - `prompt`: Optimizado para ser copiado directamente a Claude, Cursor Composer o un LLM.
  - `markdown`: Tabla legible para humanos o para pegar en la descripción de un PR.
  - `json`: Para herramientas que consumen JSON programáticamente.

---

## 3. Integración con Cursor / Claude Code / Agentes Autónomos

### Flujo en Cursor (Composer / Agent Mode):
1. En tu pipeline de CI o localmente, ejecuta el script para generar `prompt_para_agente.txt`.
2. En Cursor, abre el **Composer** en modo **Agent**.
3. Arrastra o pega el contenido de `prompt_para_agente.txt`.
4. El agente leerá las líneas exactas señaladas por SonarQube, refactorizará la duplicación o complejidad y aplicará los cambios archivo por archivo.

### Flujo Autónomo en GitHub Actions:
El archivo `.github/workflows/ai-slop-remediation.yml` ya viene preconfigurado.
- Puedes dispararlo manualmente desde la pestaña **Actions** seleccionando la rama a remediar.
- El workflow generará como artefacto de descarga el reporte y el prompt listo para ser inyectado a tu bot de IA.
