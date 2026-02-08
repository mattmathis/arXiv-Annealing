#!/bin/bash


BASE_NAME="$1"
SRC="${BASE_NAME}.wget"
TMP="${BASE_NAME}.tmp"
TEX="${BASE_NAME}.tex"

set -e
set -x

echo "Generating $TEX from $SRC, using $TMP"

# Don't force ascii, but beware of smart quotes
# iconv --verbose -c -t ASCII//TRANSLIT "${SRC}" | sed -e 's/\[[a-z]*]//g' -e '/%/a\\ ' > ${TMP}
cp "${SRC}"  "${TMP}"

# Trim the Google headers and trailers from the file
sed -i -n '/^DOCSTART/,/^DOCEND/p' "${TMP}"

# Remove Google comments
sed -i 's/\[[a-z]*]//g'  "${TMP}"

sed -i '/DOCSTART/c\
\\documentclass[ twocolumn,10pt ]{article}\
\
\\usepackage{graphicx}\
\\usepackage{hyperref}\
\
\\title{Detecting Anomalous Topology, Routing Policies, and Congested Interconnections at Internet Scale}\
\\author{Matt Mathis}\
\
\\begin{document}\
\\maketitle\
\
' "${TMP}"

# Show the buildtime
d=`date`
sed -i "s;BUILDTIME;Built: $d;" "$TMP"

# Citations, [One22Word]
sed -i 's;\[\([a-zA-Z0-9]*\)\];\\cite{\1};' "${TMP}"

# Sections
sed -i 's;^# \(.*\);\\section{\1};' "${TMP}"

sed -i '/DOCEND/c\
\\end{document}\
' "${TMP}"

echo "Updating $TEX from $TMP"
mv $TMP $TEX
