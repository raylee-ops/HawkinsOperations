#!/usr/bin/env python3
"""Normalize Sigma rule title formatting using only Python standard library."""

from __future__ import annotations

import argparse
from pathlib import Path


def normalize_title(value: str) -> str:
    cleaned = " ".join(value.strip().split())
    if not cleaned:
        return cleaned
    return cleaned[0].upper() + cleaned[1:].lower()


def normalize_sigma_text(text: str) -> str:
    normalized_lines: list[str] = []
    for line in text.splitlines():
        stripped = line.lstrip()
        indent = line[: len(line) - len(stripped)]
        if stripped.lower().startswith("title:"):
            _, raw = stripped.split(":", 1)
            title = normalize_title(raw)
            normalized_lines.append(f"{indent}title: {title}")
        else:
            normalized_lines.append(line)
    return "\n".join(normalized_lines) + ("\n" if text.endswith("\n") else "")


def main() -> None:
    parser = argparse.ArgumentParser(description="Normalize title lines in Sigma YAML files.")
    parser.add_argument("--in", dest="infile", required=True, help="Input YAML file path")
    parser.add_argument("--out", dest="outfile", required=True, help="Output YAML file path")
    args = parser.parse_args()

    src = Path(args.infile)
    dst = Path(args.outfile)

    raw = src.read_text(encoding="utf-8")
    normalized = normalize_sigma_text(raw)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(normalized, encoding="utf-8")


if __name__ == "__main__":
    main()

