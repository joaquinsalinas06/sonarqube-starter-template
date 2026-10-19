# 🛡️ SonarQube Base Repository for Startups (2026)
### Plataforma Integral de Calidad de Código, Linters en Rust y Reducción Autónoma de "AI Slop"

Este repositorio es una plantilla ("batteries-included") diseñada específicamente para **startups y equipos de ingeniería en 2026**. Proporciona una arquitectura robusta, escalable y económica para analizar código estático, prevenir deuda técnica y permitir que agentes de IA corrijan fallos automáticamente.

---

## ⚡ ¿Qué Problemas Resuelve este Setup?

1. **Elimina los escaneos de 20 minutos en CI/CD**:
   - Desacopla el servidor (que vive permanentemente en un VPS económico) del scanner ligero de GitHub Actions.
   - Aplica caché de analizadores (`~/.sonar/cache`) y exclusiones estrictas de dependencias (`node_modules`, `dist`, `.next`, etc.).
   - **Resultado**: Los escaneos en Pull Requests y ramas tardan **entre 60 y 90 segundos**.

2. **Evita pagos inesperados por líneas de código (LOC)**:
   - Utiliza **SonarQube Server 10.x Community** preconfigurado con el plugin de comunidad `sonarqube-community-branch-plugin`.
   - Soporte ilimitado para múltiples ramas (`main`, `dev`, `feature/*`) y Pull Request Decoration con **cero coste de licencia y sin límites de líneas de código**.

3. **Cero fricción en infraestructura y mantenimiento**:
   - Incluye **Caddy** como proxy inverso: emite y renueva certificados SSL Let's Encrypt para `sonar.tu-startup.com` de forma 100% automática (sin Certbot ni tareas cron).
   - Incluye script de bootstrap (`scripts/setup_vps.sh`) que configura los límites obligatorios del kernel (`vm.max_map_count=524288`) e instala Docker en 1 solo comando.
   - Corre con fluidez en un VPS económico de **~4€ a 7€/mes** (Hetzner Cloud, Hostinger VPS o AWS).

4. **Combate el "AI Slop" con Subagentes de IA**:
   - Incluye la herramienta `scripts/sonar_ai_bridge.py`: se conecta a la API de SonarQube, filtra los problemas del código nuevo (*Clean as You Code*) y genera un prompt estructurado para que asistentes o agentes de IA (Cursor, Claude, Copilot) arreglen automáticamente los duplicados y fallos.

---

## 🧱 Estructura del Repositorio

```
.
├── .github/
│   └── workflows/
│       ├── sonar-scan.yml           # Pipeline CI ultra-rápido (<90s) con caché y Quality Gate
│       └── ai-slop-remediation.yml   # Workflow para preparar prompts de remediación con IA
├── docker/
│   ├── docker-compose.yml           # SonarQube 10.x + Postgres 15 + Caddy SSL + Branch Plugin
│   ├── .env.example                 # Variables de entorno preconfiguradas
│   └── Caddyfile                    # Proxy inverso HTTPS automático (Let's Encrypt)
├── config/
│   ├── sonar-project.properties     # Exclusiones estrictas para evitar lentitud en CI
│   └── biome.json                   # Configuración del linter en Rust para JS/TS (<0.05s)
├── scripts/
│   ├── setup_vps.sh                 # Bootstrap del VPS en 1 solo comando (Kernel, Docker, UFW)
│   ├── backup_db.sh                 # Script de backup de PostgreSQL diario en 1 línea
│   ├── sonar_ai_bridge.py           # CLI puente entre SonarQube REST API y agentes de IA
│   └── sample_slop_code.js          # Código de prueba con fallos y duplicados intencionales
├── docs/
│   ├── ARCHITECTURE_AND_ROLES.md    # Quién lee el código: CI/CD vs VPS
│   ├── VPS_DEPLOYMENT_GUIDE.md      # Guía paso a paso para desplegar en Hetzner / Hostinger / AWS
│   ├── CLEAN_AS_YOU_CODE.md         # Manual de la metodología Clean as You Code
│   ├── MODERN_LINTERS_2026.md       # Guía de Biome y Ruff en local e IDE
│   └── AI_AGENT_INTEGRATION.md      # Cómo conectar agentes de IA para corregir código
└── README.md                        # Esta guía principal
```

---

## 🚀 Puesta en Marcha Rápida (Quickstart)

### Paso 1: Levantar el Servidor en tu VPS (~5 minutos)
En tu servidor VPS (ej: Hetzner CX22 o Hostinger KVM 2):
```bash
# 1. Configurar límites de kernel y Docker automáticamente
chmod +x scripts/setup_vps.sh
sudo ./scripts/setup_vps.sh

# 2. Configurar tus variables de entorno
cd docker
cp .env.example .env
nano .env   # Ajusta SONAR_DOMAIN (ej: sonar.tu-startup.com) y tu contraseña

# 3. Iniciar servicios
docker compose up -d
```
Caddy generará tu certificado SSL HTTPS de inmediato. Accede a `https://sonar.tu-startup.com`.

### Paso 2: Configurar tu Repositorio de GitHub
1. Entra a tu SonarQube (`admin` / `admin`), crea el proyecto `my-startup-project` y genera un Token de Análisis.
2. En tu repositorio de GitHub, añade dos secretos en **Settings** -> **Secrets and variables** -> **Actions**:
   - `SONAR_HOST_URL`: `https://sonar.tu-startup.com`
   - `SONAR_TOKEN`: Tu token de análisis generado en SonarQube.
3. ¡Listo! Cualquier push a `main`, `dev` o Pull Request correrá el escaneo de calidad en ~60-90 segundos.

### Paso 3: Probar el Puente con Subagentes de IA
Puedes simular cómo se extraen problemas de calidad y se genera el prompt de corrección para un LLM:
```bash
python3 scripts/sonar_ai_bridge.py --mock-test --format=prompt
```

---

## 📚 Documentación Técnica Detallada

- [¿Quién lee el código? (CI/CD vs VPS)](docs/ARCHITECTURE_AND_ROLES.md)
- [Guía de Despliegue en VPS (Hetzner, Hostinger, AWS)](docs/VPS_DEPLOYMENT_GUIDE.md)
- [Metodología Clean as You Code para Startups](docs/CLEAN_AS_YOU_CODE.md)
- [Linters Modernos en Rust (Biome y Ruff)](docs/MODERN_LINTERS_2026.md)
- [Integración con Subagentes IA para Reducir AI Slop](docs/AI_AGENT_INTEGRATION.md)

---

## 📄 Licencia

Este repositorio se distribuye bajo la licencia MIT. Eres libre de adaptarlo y usarlo como base en cualquier startup o proyecto comercial.
