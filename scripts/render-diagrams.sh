#!/bin/bash
set -euo pipefail

# Render all D2 diagrams in the repository (light + dark themes)
# Requires: d2 (https://d2lang.com) with TALA layout

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIAGRAMS_DIR="${REPO_ROOT}/docs"
OUTPUT_FORMAT="${1:-svg}"

command -v d2 >/dev/null 2>&1 || { echo "Error: d2 is not installed. See https://d2lang.com/tour/install"; exit 1; }

echo "Rendering D2 diagrams..."
echo "Format: ${OUTPUT_FORMAT}"
echo "Layout: TALA"
echo ""

DIAGRAM_COUNT=0
ERROR_COUNT=0

while IFS= read -r -d '' d2_file; do
  # Skip shared classes file
  if [[ "${d2_file}" == *"_shared"* ]]; then
    continue
  fi

  dir="$(dirname "${d2_file}")"
  base="$(basename "${d2_file}" .d2)"

  # Render light theme (theme 0)
  echo "  [light] ${d2_file}"
  if d2 --layout tala --theme 0 "${d2_file}" "${dir}/${base}-light.${OUTPUT_FORMAT}" 2>/dev/null; then
    ((DIAGRAM_COUNT++))
  else
    echo "    ERROR rendering light theme"
    ((ERROR_COUNT++))
  fi

  # Render dark theme (theme 200)
  echo "  [dark]  ${d2_file}"
  if d2 --layout tala --theme 200 "${d2_file}" "${dir}/${base}-dark.${OUTPUT_FORMAT}" 2>/dev/null; then
    ((DIAGRAM_COUNT++))
  else
    echo "    ERROR rendering dark theme"
    ((ERROR_COUNT++))
  fi

done < <(find "${DIAGRAMS_DIR}" -name "*.d2" -not -path "*/_shared/*" -print0)

echo ""
echo "Done: ${DIAGRAM_COUNT} renders, ${ERROR_COUNT} errors"
