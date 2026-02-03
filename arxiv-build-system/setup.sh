#!/bin/bash
# Setup script for arXiv paper build system
# Run this once to initialize the directory structure

set -e

echo "Setting up arXiv paper build system..."
echo ""

# Create directories
echo "Creating directories..."
mkdir -p scripts
mkdir -p figures
mkdir -p build

# Check for prerequisites
echo ""
echo "Checking prerequisites..."

check_command() {
    if command -v "$1" > /dev/null 2>&1; then
        echo "  ✓ $1 found"
        return 0
    else
        echo "  ✗ $1 NOT found"
        return 1
    fi
}

MISSING=0
check_command pandoc || MISSING=1
check_command pdflatex || MISSING=1
check_command bibtex || MISSING=1
check_command curl || MISSING=1

if [ $MISSING -eq 1 ]; then
    echo ""
    echo "⚠️  Missing prerequisites. Install them with:"
    echo ""
    echo "Ubuntu/Debian:"
    echo "  sudo apt-get install pandoc texlive-full curl"
    echo ""
    echo "macOS:"
    echo "  brew install pandoc curl"
    echo "  brew install --cask mactex"
    echo ""
else
    echo ""
    echo "✓ All prerequisites found!"
fi

# Make scripts executable
if [ -f "scripts/process-latex.sh" ]; then
    chmod +x scripts/process-latex.sh
    echo ""
    echo "✓ Made process-latex.sh executable"
fi

# Check for figures
echo ""
if [ -z "$(ls -A figures 2>/dev/null)" ]; then
    echo "⚠️  No figures found in figures/ directory"
    echo "   Add your PNG screenshots there"
else
    echo "✓ Found figures in figures/ directory:"
    ls -1 figures/
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setup complete! Next steps:"
echo ""
echo "1. Copy your figure screenshots to figures/"
echo "   cp /path/to/screenshots/*.png figures/"
echo ""
echo "2. Verify the document ID in Makefile"
echo "   (should be: 1Jqwh1STyQX80sZHqQmzUVKYRScOEZjc6anskZ-zaiho)"
echo ""
echo "3. Build your paper:"
echo "   make all"
echo ""
echo "4. View the PDF:"
echo "   make view"
echo ""
echo "See README.md for full documentation."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
