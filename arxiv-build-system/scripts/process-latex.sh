#!/bin/bash
# Post-processing script for LaTeX conversion
# Usage: ./process-latex.sh <tex-file>

set -e

TEX_FILE="$1"

if [ ! -f "$TEX_FILE" ]; then
    echo "Error: File $TEX_FILE not found"
    exit 1
fi

echo "    Processing $TEX_FILE..."

# Backup original
cp "$TEX_FILE" "${TEX_FILE}.backup"

# Use a temporary file for modifications
TEMP_FILE="${TEX_FILE}.tmp"
cp "$TEX_FILE" "$TEMP_FILE"

# 1. Replace documentclass with article (arXiv prefers this)
sed -i '1,10s/\\documentclass\[.*\]{.*}/\\documentclass[11pt]{article}/' "$TEMP_FILE"

# 2. Add/update packages after documentclass
# First, remove any existing package declarations we want to control
sed -i '/\\usepackage{longtable}/d' "$TEMP_FILE"
sed -i '/\\usepackage{booktabs}/d' "$TEMP_FILE"
sed -i '/\\usepackage{calc}/d' "$TEMP_FILE"

# Insert our package set right after documentclass
sed -i '/\\documentclass/a\
% Packages\
\\usepackage[utf8]{inputenc}\
\\usepackage[T1]{fontenc}\
\\usepackage{graphicx}\
\\usepackage{hyperref}\
\\usepackage{amsmath}\
\\usepackage{amssymb}\
\\usepackage{booktabs}\
\\usepackage{longtable}\
\\usepackage{array}\
\\usepackage{float}\
\\usepackage{caption}\
\\usepackage{xcolor}\
\\usepackage{url}\
' "$TEMP_FILE"

# 3. Add title and author information if not present
if ! grep -q "\\\\maketitle" "$TEMP_FILE"; then
    sed -i '/\\begin{document}/a\
\\title{Detecting Anomalous Topology, Routing Policies, and Congested Interconnections at Internet Scale}\
\\author{Matt Mathis \\\\ Measurement Lab}\
\\date{\\today}\
\\maketitle\
' "$TEMP_FILE"
fi

# 4. Handle embedded images from Google Docs
# Pandoc converts these to \includegraphics - we'll keep them but ensure they work
# Replace any image paths to just use the filename (since we copy all figures to build dir)
sed -i 's|\\includegraphics\[.*\]{.*/\([^/]*\.png\)}|\\includegraphics[width=0.9\\textwidth]{\1}|g' "$TEMP_FILE"
sed -i 's|\\includegraphics\[.*\]{\([^/]*\.png\)}|\\includegraphics[width=0.9\\textwidth]{\1}|g' "$TEMP_FILE"

# 5. Handle figure placeholders like [FIGURE: fig1]
# Convert to proper figure environments
sed -i 's|\[FIGURE: \(fig[0-9]\)\]|\\begin{figure}[htbp]\\n\\centering\\n\\includegraphics[width=0.8\\textwidth]{\1.png}\\n\\caption{TODO: Add caption for \1}\\n\\label{fig:\1}\\n\\end{figure}|g' "$TEMP_FILE"

# 6. Clean up common Pandoc artifacts
# Remove excessive \tightlist commands
sed -i 's/\\tightlist//g' "$TEMP_FILE"

# 7. Handle citations - convert informal [NameYY] style to proper \cite{}
# This is a basic conversion - you may need to refine based on your exact format
# Example: [MLab14interconnection] -> \cite{MLab14interconnection}
sed -i 's/\[\([A-Za-z0-9]\+\)\]/\\cite{\1}/g' "$TEMP_FILE"

# But don't convert things in URLs or that look like years
sed -i 's/\\cite{http/[http/g' "$TEMP_FILE"
sed -i 's/\\cite{201[0-9]}/[201\1]/g' "$TEMP_FILE"
sed -i 's/\\cite{202[0-9]}/[202\1]/g' "$TEMP_FILE"

# 8. Remove Google Docs artifacts
# Remove any notes or reviewer comments in square brackets at the start
sed -i '/^\[Notes and instructions for readers/,/^\]/d' "$TEMP_FILE"
sed -i '/^\\\[Notes and instructions for readers/,/^\\\]/d' "$TEMP_FILE"

# 9. Clean up section headers to use proper LaTeX commands
# Pandoc should handle this, but ensure consistency
sed -i 's/^# \(.*\)$/\\section{\1}/g' "$TEMP_FILE"
sed -i 's/^## \(.*\)$/\\subsection{\1}/g' "$TEMP_FILE"
sed -i 's/^### \(.*\)$/\\subsubsection{\1}/g' "$TEMP_FILE"

# 10. Fix common LaTeX issues
# Escape special characters that might have been missed
# (Pandoc usually handles this, but double-check critical cases)

# Move the processed file back
mv "$TEMP_FILE" "$TEX_FILE"

echo "    Post-processing complete"
echo "    Backup saved as ${TEX_FILE}.backup"

exit 0
