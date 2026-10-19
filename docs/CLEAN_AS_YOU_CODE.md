# Metodología "Clean as You Code" (CaYC) para Startups

La mayor causa de abandono de herramientas de análisis estático en startups es la **parálisis por deuda técnica heredada**.

Al conectar un proyecto que lleva meses o años en desarrollo, es habitual que SonarQube reporte cientos de advertencias y decenas de bugs antiguos. Intentar detener el desarrollo del producto para corregir todo eso es inviable para una startup.

La solución oficial y estándar de la industria es la metodología **"Clean as You Code" (CaYC)**.

---

## 1. El Principio Fundamental: Enfoque en el Código Nuevo

> **"No te preocupes por limpiar todo el pasado de golpe; asegúrate de que NINGÚN cambio nuevo introduzca problemas."**

Bajo esta metodología:
1. El pasado se congela como línea base (*Baseline*).
2. El **Quality Gate** evalúa **exclusivamente las líneas de código agregadas o modificadas** en la rama de trabajo o Pull Request respecto a la rama principal (`main`).
3. Si un archivo antiguo contiene 20 code smells pero en tu PR solo modificaste 5 líneas para añadir un parámetro, SonarQube **solo analizará esas 5 líneas**.

---

## 2. Condiciones del Quality Gate en "New Code"

El Quality Gate predeterminado para código nuevo exige:

| Métrica | Umbral en Código Nuevo | Objetivo |
| :--- | :--- | :--- |
| **Nuevos Bugs** | **0** | Prevenir regresiones y fallos en producción antes de fusionar. |
| **Nuevas Vulnerabilidades** | **0** | Evitar brechas de seguridad (OWASP Top 10, inyecciones, tokens quemados). |
| **Duplicación en Código Nuevo** | **< 3%** | Frenar la proliferación de lógica copiada y pegada (común en código generado por IA). |
| **Hotspots de Seguridad Revisados** | **100%** | Garantizar que cualquier punto sensible fue validado conscientemente. |
| **Deuda Técnica Nueva** | **< 5%** | Evitar acumulación descontrolada de code smells. |

---

## 3. ¿Cómo se Limpia la Deuda Antigua? (La Regla del Boy Scout)

> *"Deja el campamento más limpio de lo que lo encontraste."*

A medida que el equipo desarrolla nuevas funcionalidades:
1. Los desarrolladores tocan archivos antiguos.
2. Al modificar una función antigua, limpian pequeñas duplicaciones o declaran tipos correctos en esa sección.
3. Con el paso de los sprints, **la base de código se sanea orgánicamente sin haber dedicado un solo sprint exclusivo a refactorización**.

---

## 4. Configuración en este Repositorio

En `config/sonar-project.properties`:
```properties
# Define que el código nuevo en cualquier rama o PR se compara contra 'main'
sonar.newCode.referenceBranch=main
```

En la interfaz de SonarQube:
- Ve a **Project Settings** -> **New Code**.
- Selecciona **Reference Branch** y elige `main` (o `dev` según tu estrategia).
- Guarda los cambios. A partir de ese momento, tu equipo disfrutará de Quality Gates rápidos y justos.
