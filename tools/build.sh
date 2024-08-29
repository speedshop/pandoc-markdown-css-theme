#!/usr/bin/env bash

#
# Author: Jake Zimmerman <jake@zimmerman.io>
#
# A simple script to build an HTML file using Pandoc
#

set -euo pipefail

usage() {
  echo "usage: $0 <source.md> <dest.html>"
}

# ----- args and setup -----

src="${1:-}"
dest="${2:-}"
if [ "$src" = "" ] || [ "$dest" = "" ]; then
  2>&1 usage
  exit 1
fi

case "$src" in
  -h|--help)
    usage
    exit
    ;;
esac

# ----- main -----

for file in "public/css/theme.css" "public/css/skylighting-solarized-theme.css"; do
  if ! [ -f "$file" ]; then
    2>&1 echo "$0: warning: CSS theme file is missing: $file (will 404 when serving)"
  fi
done

dest_dir="$(dirname "$dest")"
mkdir -p "$dest_dir"

pandoc \
  --katex \
  --from markdown+tex_math_single_backslash \
  --filter pandoc-sidenote \
  --to html5+smart \
  --template=template \
  --css="public/css/theme.css" \
  --css="public/css/skylighting-solarized-theme.css" \
  --css="public/css/tufte.css" \
  --toc \
  --embed-resources \
  --standalone \
  --wrap=none \
  --verbose \
  --output "$dest" \
  "$src" 

cat $src | wkhtmltopdf -s B5 --footer-center "[page]" --footer-font-name Palatino -L 20mm -R 20mm -T 15mm -B 15mm - _release/$(VERSION)/$(NAME).pdf
