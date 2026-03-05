"""
Excel Reader MCP Server

Exposes tools to read .xlsx files (sheet names, read as table, export CSV, schema info).
Paths are resolved against MCP_EXCEL_PROJECT_ROOT (project root); only paths under that directory are allowed.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

from fastmcp import FastMCP

# Optional: pandas/openpyxl imported inside tools to keep startup light if needed
# We need them for the tools
import pandas as pd

mcp = FastMCP("Excel Reader")


def _project_root() -> Path:
    root = os.environ.get("MCP_EXCEL_PROJECT_ROOT")
    if root:
        return Path(root).resolve()
    # Default: parent of mcp-servers/excel-reader = project root
    return Path(__file__).resolve().parent.parent.parent


def _resolve_path(path: str) -> Path:
    root = _project_root()
    p = Path(path)
    if not p.is_absolute():
        p = (root / path).resolve()
    else:
        p = p.resolve()
    if not str(p).startswith(str(root)):
        raise PermissionError(f"Path must be under project root: {root}")
    return p


@mcp.tool()
def sheet_names(file_path: str) -> str:
    """List all sheet names in an Excel (.xlsx) file.
    file_path: path relative to project root or absolute path under project (e.g. investment-backend/docs/korea-investment-api/OAuth인증.xlsx).
    Returns a JSON array of sheet name strings."""
    p = _resolve_path(file_path)
    if not p.exists():
        return f"Error: file not found: {p}"
    if p.suffix.lower() not in (".xlsx", ".xls"):
        return "Error: only .xlsx (or .xls) files are supported."
    try:
        xl = pd.ExcelFile(p, engine="openpyxl")
        names = xl.sheet_names
        import json
        return json.dumps(names, ensure_ascii=False)
    except Exception as e:
        return f"Error reading Excel: {e!r}"


@mcp.tool()
def read_excel(
    file_path: str,
    sheet_name: str | None = None,
    max_rows: int | None = None,
    as_markdown: bool = True,
) -> str:
    """Read a sheet from an Excel (.xlsx) file into a table.
    file_path: path relative to project root or absolute (e.g. investment-backend/docs/korea-investment-api/[국내주식] 기본시세.xlsx).
    sheet_name: exact sheet name; if omitted, first sheet is used.
    max_rows: if set, only first N rows are returned (default: all).
    as_markdown: if True (default), return a markdown table; otherwise return JSON array of rows.
    """
    p = _resolve_path(file_path)
    if not p.exists():
        return f"Error: file not found: {p}"
    if p.suffix.lower() not in (".xlsx", ".xls"):
        return "Error: only .xlsx (or .xls) files are supported."
    try:
        df = pd.read_excel(p, sheet_name=sheet_name or 0, engine="openpyxl")
        if max_rows is not None and max_rows > 0:
            df = df.head(max_rows)
        if as_markdown:
            # Build a simple markdown pipe table
            csv_buf = df.to_csv(index=False, sep="|")
            lines = csv_buf.strip().split("\n")
            if not lines:
                return "(empty)"
            header = "| " + " | ".join(lines[0].split("|")) + " |"
            sep = "|" + "|".join("---" for _ in lines[0].split("|")) + "|"
            rest = ["| " + " | ".join(L.split("|")) + " |" for L in lines[1:]]
            return "\n".join([header, sep] + rest)
        import json
        return json.dumps(df.fillna("").astype(str).to_dict(orient="records"), ensure_ascii=False, indent=2)
    except Exception as e:
        return f"Error reading Excel: {e!r}"


@mcp.tool()
def export_csv(
    file_path: str,
    sheet_name: str | None = None,
    output_path: str | None = None,
) -> str:
    """Export one sheet from an Excel file to CSV.
    file_path: path to .xlsx (relative to project root or absolute).
    sheet_name: sheet to export; if omitted, first sheet.
    output_path: path for the output .csv (under project root); if omitted, writes next to the xlsx with same base name + _<sheet>.csv.
    Returns the path of the written CSV or an error message."""
    p = _resolve_path(file_path)
    if not p.exists():
        return f"Error: file not found: {p}"
    if p.suffix.lower() not in (".xlsx", ".xls"):
        return "Error: only .xlsx (or .xls) files are supported."
    try:
        df = pd.read_excel(p, sheet_name=sheet_name or 0, engine="openpyxl")
        name = sheet_name or pd.ExcelFile(p, engine="openpyxl").sheet_names[0]
        safe_name = "".join(c if c.isalnum() or c in " -_" else "_" for c in name)
        if output_path:
            out = _resolve_path(output_path)
        else:
            out = p.parent / f"{p.stem}_{safe_name}.csv"
        df.to_csv(out, index=False, encoding="utf-8-sig")
        return f"Exported to: {out}"
    except Exception as e:
        return f"Error: {e!r}"


@mcp.tool()
def validate_schema(file_path: str, sheet_name: str | None = None) -> str:
    """Return column names and dtypes for a sheet (schema summary). Useful to verify structure before read_excel.
    file_path: path to .xlsx; sheet_name: optional sheet (default: first sheet).
    """
    p = _resolve_path(file_path)
    if not p.exists():
        return f"Error: file not found: {p}"
    if p.suffix.lower() not in (".xlsx", ".xls"):
        return "Error: only .xlsx (or .xls) files are supported."
    try:
        df = pd.read_excel(p, sheet_name=sheet_name or 0, engine="openpyxl", nrows=0)
        import json
        schema = [{"column": c, "dtype": str(d)} for c, d in zip(df.columns, df.dtypes)]
        return json.dumps({"columns": df.columns.tolist(), "schema": schema}, ensure_ascii=False, indent=2)
    except Exception as e:
        return f"Error: {e!r}"


if __name__ == "__main__":
    import traceback
    try:
        mcp.run(show_banner=False)  # stdio: banner would corrupt JSON-RPC on stdout
    except Exception as e:
        traceback.print_exc(file=sys.stderr)
        sys.stderr.flush()
        raise
