#!/usr/bin/env python3
"""
==============================================================================
SonarQube AI Bridge: Autonomous Remediation Tool for AI Slop (2026)
==============================================================================
Extracts unresolved SonarQube issues (bugs, code smells, duplicates, security hotspots),
filters for the 'New Code' period, and formats structured prompts ready for LLMs
and AI coding subagents (Cursor, Claude, GPT-4o, Devin, etc.).

Zero external dependencies: Requires only standard Python 3.8+ library.
"""

import argparse
import base64
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, Dict, List, Optional


def create_auth_headers(token: str) -> Dict[str, str]:
    """Generates Basic Auth header required by SonarQube REST API."""
    # SonarQube uses token as username with empty password
    credentials = f"{token}:"
    encoded_token = base64.b64encode(credentials.encode("utf-8")).decode("utf-8")
    return {
        "Authorization": f"Basic {encoded_token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }


def query_sonarqube_api(
    base_url: str,
    token: str,
    endpoint: str,
    params: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    """Queries SonarQube Web API with proper timeouts and error handling."""
    clean_base = base_url.rstrip("/")
    query_string = urllib.parse.urlencode(params) if params else ""
    full_url = f"{clean_base}{endpoint}"
    if query_string:
        full_url = f"{full_url}?{query_string}"

    headers = create_auth_headers(token)
    req = urllib.request.Request(full_url, headers=headers, method="GET")

    try:
        with urllib.request.urlopen(req, timeout=15) as response:
            if response.status == 200:
                raw_data = response.read().decode("utf-8")
                return json.loads(raw_data)
            else:
                raise RuntimeError(f"SonarQube API returned status code {response.status}")
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8", errors="ignore")
        raise RuntimeError(f"HTTP Error {e.code}: {e.reason} - {error_body}") from e
    except urllib.error.URLError as e:
        raise RuntimeError(f"Network error connecting to {full_url}: {e.reason}") from e


def fetch_issues(
    base_url: str,
    token: str,
    project_key: str,
    severities: str = "BLOCKER,CRITICAL,MAJOR",
    new_code_only: bool = True,
    branch: Optional[str] = None,
) -> List[Dict[str, Any]]:
    """Fetches unresolved issues from SonarQube."""
    endpoint = "/api/issues/search"
    params = {
        "componentKeys": project_key,
        "resolved": "false",
        "severities": severities,
        "ps": 100,  # Page size
    }
    if new_code_only:
        params["inNewCodePeriod"] = "true"
    if branch:
        params["branch"] = branch

    data = query_sonarqube_api(base_url, token, endpoint, params)
    return data.get("issues", [])


def format_for_ai_prompt(
    issues: List[Dict[str, Any]],
    project_key: str,
    output_format: str = "prompt",
) -> str:
    """Formats the issues into an actionable prompt for AI subagents."""
    if not issues:
        return "✅ [SonarQube AI Bridge]: No unresolved issues found matching criteria. Quality Gate clean!"

    if output_format == "json":
        return json.dumps(issues, indent=2)

    if output_format == "markdown":
        lines = [
            f"# SonarQube Issue Report: `{project_key}`",
            f"**Total Issues Found**: {len(issues)}",
            "",
            "| Severidad | Tipo | Archivo | Línea | Regla | Mensaje |",
            "| :--- | :--- | :--- | :--- | :--- | :--- |",
        ]
        for issue in issues:
            comp = issue.get("component", "").split(":")[-1]
            line = issue.get("line", "N/A")
            rule = issue.get("rule", "")
            msg = issue.get("message", "").replace("|", "\\|")
            sev = issue.get("severity", "")
            itype = issue.get("type", "")
            lines.append(f"| {sev} | {itype} | `{comp}` | {line} | `{rule}` | {msg} |")
        return "\n".join(lines)

    # Default: "prompt" format for LLM Agents
    lines = [
        "## INSTRUCCIÓN PARA SUBAGENTE IA: REDUCCIÓN DE AI SLOP Y DEUDA TÉCNICA",
        "Actúa como un Ingeniero Principal de Software. Se han detectado los siguientes problemas",
        "de calidad, duplicación de código y seguridad estática mediante SonarQube en el código nuevo.",
        "",
        "### REGLAS DE REMEDIACIÓN OBLIGATORIAS:",
        "1. Aplica refactorizaciones limpias preservando el 100% de la funcionalidad esperada.",
        "2. Elimina bloques duplicados unificando funciones auxiliares o utilidades compartidas.",
        "3. Reduce la complejidad cognitiva dividiendo funciones excesivamente anidadas.",
        "4. No añadas tipos 'any' implícitos ni dejes variables huérfanas.",
        "5. Genera el código corregido con una breve explicación de la solución.",
        "",
        "### LISTADO DE INFRACCIONES DETECTADAS:",
    ]

    for idx, issue in enumerate(issues, 1):
        file_path = issue.get("component", "").split(":")[-1]
        line = issue.get("line", "N/A")
        rule = issue.get("rule", "")
        msg = issue.get("message", "")
        sev = issue.get("severity", "")
        itype = issue.get("type", "")
        effort = issue.get("effort", "5min")

        lines.extend([
            f"---",
            f"#### Infracción #{idx}: [{sev}] {itype}",
            f"- **Archivo**: `{file_path}`",
            f"- **Línea**: {line}",
            f"- **Regla**: `{rule}`",
            f"- **Diagnóstico**: {msg}",
            f"- **Esfuerzo Estimado**: {effort}",
        ])

    lines.extend([
        "---",
        "### ACCIÓN REQUERIDA:",
        "Por favor, analiza cada archivo mencionado y provee el fragmento corregido (diff)",
        "específico para resolver la regla violada sin introducir efectos secundarios.",
    ])

    return "\n".join(lines)


def get_mock_issues() -> List[Dict[str, Any]]:
    """Returns sample issues for testing the bridge without a live SonarQube server."""
    return [
        {
            "key": "AX_12345678",
            "rule": "javascript:S1871",
            "severity": "MAJOR",
            "component": "my-startup-project:scripts/sample_slop_code.js",
            "line": 28,
            "message": "Two branches in this conditional structure have the same implementation.",
            "type": "CODE_SMELL",
            "effort": "10min",
        },
        {
            "key": "AX_12345679",
            "rule": "javascript:S3776",
            "severity": "CRITICAL",
            "component": "my-startup-project:scripts/sample_slop_code.js",
            "line": 45,
            "message": "Refactor this function to reduce its Cognitive Complexity from 18 to the 15 allowed.",
            "type": "CODE_SMELL",
            "effort": "25min",
        },
        {
            "key": "AX_12345680",
            "rule": "secrets:S6693",
            "severity": "BLOCKER",
            "component": "my-startup-project:scripts/sample_slop_code.js",
            "line": 12,
            "message": "Hard-coded secret key detected. Move this value to an environment variable.",
            "type": "VULNERABILITY",
            "effort": "5min",
        },
    ]


def main():
    parser = argparse.ArgumentParser(
        description="SonarQube AI Bridge: Extract issues and prepare AI agent remediation prompts."
    )
    parser.add_argument(
        "--url",
        default=os.getenv("SONAR_HOST_URL", "http://localhost:9000"),
        help="SonarQube Server URL (or via env SONAR_HOST_URL)",
    )
    parser.add_argument(
        "--token",
        default=os.getenv("SONAR_TOKEN", ""),
        help="SonarQube API Token (or via env SONAR_TOKEN)",
    )
    parser.add_argument(
        "--project",
        default=os.getenv("SONAR_PROJECT_KEY", "my-startup-project"),
        help="Project Key in SonarQube",
    )
    parser.add_argument(
        "--branch",
        default=None,
        help="Target Git branch to inspect",
    )
    parser.add_argument(
        "--all-code",
        action="store_true",
        help="Inspect overall code instead of only 'New Code' period",
    )
    parser.add_argument(
        "--severities",
        default="BLOCKER,CRITICAL,MAJOR",
        help="Comma-separated severities (BLOCKER,CRITICAL,MAJOR,MINOR,INFO)",
    )
    parser.add_argument(
        "--format",
        choices=["prompt", "markdown", "json"],
        default="prompt",
        help="Output format (prompt for LLMs, markdown for tables, json for raw)",
    )
    parser.add_argument(
        "--output-file",
        default=None,
        help="Optional file path to write output",
    )
    parser.add_argument(
        "--mock-test",
        action="store_true",
        help="Run in mock mode with sample AI slop issues for testing",
    )

    args = parser.parse_args()

    if args.mock_test:
        print("[MOCK MODE ACTIVATED] Simulating SonarQube API response...", file=sys.stderr)
        issues = get_mock_issues()
    else:
        if not args.token:
            print(
                "[ERROR] No SONAR_TOKEN provided. Pass --token or set SONAR_TOKEN environment variable.\n"
                "Tip: You can use --mock-test to test prompt generation without a running server.",
                file=sys.stderr,
            )
            sys.exit(1)

        try:
            issues = fetch_issues(
                base_url=args.url,
                token=args.token,
                project_key=args.project,
                severities=args.severities,
                new_code_only=not args.all_code,
                branch=args.branch,
            )
        except Exception as e:
            print(f"[ERROR] Failed to query SonarQube API: {e}", file=sys.stderr)
            sys.exit(2)

    result = format_for_ai_prompt(issues, args.project, output_format=args.format)

    if args.output_file:
        with open(args.output_file, "w", encoding="utf-8") as f:
            f.write(result)
        print(f"Output successfully written to {args.output_file}", file=sys.stderr)
    else:
        print(result)


if __name__ == "__main__":
    main()
