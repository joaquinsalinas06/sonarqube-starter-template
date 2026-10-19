# Guía de Despliegue en VPS para Startups (Hetzner, Hostinger, AWS)

Esta guía detalla el paso a paso para levantar tu propia instancia permanente de **SonarQube Server 10.x** con HTTPS automático y soporte ilimitado de ramas y PRs por menos de 7€ al mes.

---

## 1. Elección y Contratación del Servidor VPS

Recomendamos cualquiera de las siguientes opciones (mínimo 4 GB RAM y discos SSD/NVMe):

1. **Hetzner Cloud (Opción Recomendada)**:
   - Plan **CX22** (2 vCPU, 4 GB RAM, 40 GB NVMe) ~3.79€/mes o **CX32** (4 vCPU, 8 GB RAM, 80 GB NVMe) ~7.50€/mes.
   - Ubicación: Nuremberg, Falkenstein o Ashburn (EE.UU.).
   - Sistema Operativo: **Ubuntu 24.04 LTS**.
2. **Hostinger VPS**:
   - Plan **KVM 2** (2 vCPU, 8 GB RAM, 100 GB NVMe) ~6€ a 8€/mes.
3. **AWS (EC2)**:
   - Instancia `t3.medium` (2 vCPU, 4 GB RAM) con volumen EBS gp3 de 40 GB.

---

## 2. Configuración del Dominio DNS

Antes de iniciar los contenedores, añade un registro DNS tipo **A** en tu proveedor de dominio (Cloudflare, Namecheap, AWS Route 53, etc.):

- **Tipo**: `A`
- **Nombre**: `sonar` (o `sonarqube`)
- **Valor**: `IP_PUBLICA_DE_TU_VPS`
- **TTL**: Automático (o 300 segundos)

*Ejemplo: `sonar.tu-startup.com` -> `195.201.x.x`*

---

## 3. Aprovisionamiento Automático del VPS (1 Comando)

Conéctate por SSH a tu servidor:
```bash
ssh root@IP_PUBLICA_DE_TU_VPS
```

Clona este repositorio o copia el script de bootstrap y ejecútalo:
```bash
# Dar permisos de ejecución y correr bootstrap
chmod +x scripts/setup_vps.sh
./scripts/setup_vps.sh
```

El script configurará automáticamente:
1. `vm.max_map_count=524288` y descriptores de archivo para Elasticsearch.
2. Instalación oficial de Docker Engine y Docker Compose plugin.
3. Firewall UFW con puertos 22 (SSH), 80 (HTTP) y 443 (HTTPS) permitidos.

---

## 4. Despliegue de los Contenedores con Caddy (SSL Automático)

Navega al directorio `docker/`:
```bash
cd docker
cp .env.example .env
nano .env
```

Modifica las siguientes variables con tus datos reales:
```env
# Tu subdominio configurado en el paso 2
SONAR_DOMAIN=sonar.tu-startup.com

# Tu correo para Let's Encrypt (avisos de renovación)
CADDY_LETSENCRYPT_EMAIL=devops@tu-startup.com

# Contraseña segura para PostgreSQL
POSTGRES_PASSWORD=TuContrasenaSuperSegura2026!
```

Inicia los servicios en segundo plano:
```bash
docker compose up -d
```

Puedes seguir el arranque con:
```bash
docker compose logs -f sonarqube
```
*(En el primer arranque, SonarQube tarda aproximadamente 60-90 segundos en crear el esquema de base de datos e inicializar Elasticsearch).*

---

## 5. Configuración Inicial en SonarQube y Generación de Token

1. Abre tu navegador e ingresa a `https://sonar.tu-startup.com`.
2. Observarás que **la conexión es HTTPS segura con candado verde** emitida automáticamente por Caddy.
3. Inicia sesión con las credenciales por defecto:
   - **Usuario**: `admin`
   - **Contraseña**: `admin`
4. El sistema te pedirá cambiar la contraseña inmediatamente.
5. **Crear el Proyecto**:
   - Pulsa en **Create Project** -> **Manually**.
   - **Project display name**: `My Startup Core Service`
   - **Project key**: `my-startup-project` (debe coincidir con `config/sonar-project.properties`).
   - Define la rama principal como `main`.
6. **Generar el Token de Análisis**:
   - En la configuración del proyecto, ve a **Analysis Method** -> **With GitHub Actions**.
   - O ve a tu perfil (arriba a la derecha) -> **My Account** -> **Security** -> **Generate Token**.
   - Tipo de Token: **Project Analysis Token** (o Global Analysis Token).
   - Copia el token generado (ej: `sqp_9876543210abcdef...`).

---

## 6. Configurar Secretos en GitHub

En tu repositorio de GitHub, ve a **Settings** -> **Secrets and variables** -> **Actions** y añade:

| Nombre del Secreto | Valor |
| :--- | :--- |
| `SONAR_HOST_URL` | `https://sonar.tu-startup.com` |
| `SONAR_TOKEN` | El token generado en el paso anterior (`sqp_...`) |

¡Listo! A partir de este momento, cada `push` o Pull Request disparará el workflow de GitHub Actions que escaneará el código en menos de 90 segundos.
