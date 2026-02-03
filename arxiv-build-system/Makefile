# Makefile for arXiv Paper Build
# Fetches Google Doc, converts to LaTeX, and builds PDF

# Configuration
DOC_ID = 1Jqwh1STyQX80sZHqQmzUVKYRScOEZjc6anskZ-zaiho
DOC_URL = https://docs.google.com/document/d/$(DOC_ID)/export?format=docx
BUILD_DIR = build
FIGURES_DIR = figures
SCRIPTS_DIR = scripts

# Output files
DOCX = $(BUILD_DIR)/paper.docx
TEX = $(BUILD_DIR)/paper.tex
PDF = $(BUILD_DIR)/paper.pdf
BIB = refs.bib

.PHONY: all clean fetch convert pdf rebuild view

all: pdf

# Fetch the Google Doc (no credentials needed for public doc)
fetch:
	@mkdir -p $(BUILD_DIR)
	@echo "==> Fetching document from Google Docs..."
	@curl -L "$(DOC_URL)" -o $(DOCX)
	@echo "    Document saved to $(DOCX)"

# Convert DOCX to LaTeX
convert: fetch
	@echo "==> Converting to LaTeX with Pandoc..."
	@pandoc $(DOCX) \
		--from=docx \
		--to=latex \
		--output=$(TEX) \
		--standalone \
		--bibliography=$(BIB) \
		--csl=acm-sig-proceedings.csl 2>/dev/null || \
	pandoc $(DOCX) \
		--from=docx \
		--to=latex \
		--output=$(TEX) \
		--standalone \
		--bibliography=$(BIB)
	@echo "    LaTeX file created: $(TEX)"
	@echo "==> Post-processing LaTeX..."
	@bash $(SCRIPTS_DIR)/process-latex.sh $(TEX)
	@echo "==> Copying figures to build directory..."
	@cp $(FIGURES_DIR)/*.png $(BUILD_DIR)/ 2>/dev/null || true
	@echo "    Conversion complete"

# Build PDF
pdf: convert
	@echo "==> Building PDF (first pass)..."
	@cd $(BUILD_DIR) && pdflatex -interaction=nonstopmode paper.tex > pdflatex.log 2>&1 || \
		(echo "    LaTeX error - check $(BUILD_DIR)/pdflatex.log"; exit 1)
	@echo "==> Running BibTeX..."
	@cd $(BUILD_DIR) && bibtex paper > bibtex.log 2>&1 || true
	@echo "==> Building PDF (second pass)..."
	@cd $(BUILD_DIR) && pdflatex -interaction=nonstopmode paper.tex >> pdflatex.log 2>&1
	@echo "==> Building PDF (final pass)..."
	@cd $(BUILD_DIR) && pdflatex -interaction=nonstopmode paper.tex >> pdflatex.log 2>&1
	@echo ""
	@echo "==> PDF created successfully: $(PDF)"
	@echo ""

# Quick rebuild without re-fetching
rebuild:
	@echo "==> Rebuilding PDF without fetching..."
	@cd $(BUILD_DIR) && pdflatex -interaction=nonstopmode paper.tex
	@cd $(BUILD_DIR) && pdflatex -interaction=nonstopmode paper.tex
	@echo "==> PDF rebuilt: $(PDF)"

# View the PDF (if on a system with a PDF viewer)
view: pdf
	@if command -v xdg-open > /dev/null; then \
		xdg-open $(PDF); \
	elif command -v open > /dev/null; then \
		open $(PDF); \
	else \
		echo "No PDF viewer found. PDF is at: $(PDF)"; \
	fi

# Clean build directory
clean:
	@rm -rf $(BUILD_DIR)/*
	@echo "Build directory cleaned"

# Show help
help:
	@echo "Available targets:"
	@echo "  make all     - Full build from scratch (fetch + convert + PDF)"
	@echo "  make fetch   - Download Google Doc only"
	@echo "  make convert - Fetch and convert to LaTeX"
	@echo "  make pdf     - Full PDF build (default)"
	@echo "  make rebuild - Quick rebuild without re-fetching"
	@echo "  make view    - Build and open PDF"
	@echo "  make clean   - Remove all build files"
	@echo ""
	@echo "Configuration:"
	@echo "  Document ID: $(DOC_ID)"
	@echo "  Build dir:   $(BUILD_DIR)"
	@echo "  Figures dir: $(FIGURES_DIR)"
