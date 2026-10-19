# Arquitectura y Roles: ¿Quién Lee el Código? (CI/CD vs Servidor VPS / AWS)

Una de las dudas más frecuentes al implementar SonarQube en startups es: **¿Quién analiza el código fuente? ¿Es necesario que el servidor en la nube tenga acceso por SSH o tokens para clonar nuestros repositorios de GitHub?**

La respuesta técnica es **NO**. El servidor de SonarQube en la nube **nunca clona ni tiene acceso directo a tu repositorio de GitHub**.

---

## 1. La Separación Estricta de Responsabilidades

```
┌─────────────────────────────────────────────────────────────┐
│ 1. ENTORNO EFÍMERO: GitHub Actions Runner (El LECTOR)        │
│                                                             │
│ • Hace checkout del código de la rama activa / PR.          │
│ • Ejecuta `sonar-scanner` localmente.                       │
│ • Parsea el código, construye el Árbol de Sintaxis (AST).  │
│ • Calcula hashes de duplicación y lee reportes de tests.    │
│ • Empaqueta un archivo comprimido (.zip) con las métricas.  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               │ HTTPS POST con SONAR_TOKEN
                               │ (Reporte comprimido de métricas)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. ENTORNO PERMANENTE: Servidor VPS / AWS (El CEREBRO)      │
│                                                             │
│ • Expuesto tras Caddy con certificado SSL automático.       │
│ • El Compute Engine procesa la cola de análisis.            │
│ • Almacena métricas históricas en PostgreSQL.               │
│ • Evalúa la metodología Clean as You Code (Quality Gate).   │
│ • Expone la API REST y el Dashboard Web para el equipo.     │
│ • Devuelve el veredicto (PASS/FAIL) a GitHub.               │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Beneficios de esta Arquitectura

1. **Seguridad y Privacidad Máxima**:
   - Tu servidor VPS no necesita claves SSH ni tokens con permisos de lectura de código en GitHub.
   - Si tu servidor sufriera un compromiso de seguridad, ningún atacante podría descargar tu código fuente desde allí, ya que el servidor solo almacena métricas, ubicaciones de issues y fragmentos de líneas problemáticas.

2. **Rendimiento Acelerado en CI/CD**:
   - Anteriormente, intentar levantar contenedores de SonarQube + Elasticsearch en cada ejecución de GitHub Actions tomaba 15-20 minutos por el pesado arranque de la JVM.
   - Al tener el servidor permanentemente encendido en un VPS, en el CI **únicamente se corre el scanner CLI ligero**, lo que reduce el tiempo total a **60-90 segundos**.

3. **Caché Persistente**:
   - El runner de GitHub Actions aprovecha la acción `actions/cache` en `~/.sonar/cache` para no volver a descargar los analizadores de lenguaje en cada commit.

---

## 3. Protocolo de Comunicación de Red

1. **Tráfico Saliente desde GitHub Actions**:
   - El runner inicia una conexión HTTPS saliente hacia `https://sonar.tu-startup.com:443`.
   - Se autentica mediante la cabecera `Authorization: Basic <base64(SONAR_TOKEN:)>`.
2. **Puertos en el VPS**:
   - Solo se exponen los puertos **80 (HTTP)** y **443 (HTTPS)**.
   - Caddy redirige automáticamente cualquier petición HTTP a HTTPS con certificados gestionados por Let's Encrypt.
   - La base de datos PostgreSQL **no está expuesta a Internet**; reside en una red interna privada de Docker (`sonarnet`).
