# Makefile to build a simple arXiv paper from tex in Google docs

# Configuration
DOC_ID = 1Jqwh1STyQX80sZHqQmzUVKYRScOEZjc6anskZ-zaiho
DOC_URL = "https://docs.google.com/document/d/$(DOC_ID)/export?format=txt&tab=t.0"
BUILD_DIR = build
FIGURES_DIR = figures
BASE_NAME = $(BUILD_DIR)/paper

# Output files
RAW = $(BUILD_DIR)/paper.wget
TEX = $(BUILD_DIR)/paper.tex
PDF = $(BUILD_DIR)/paper.pdf
BIB = refs.bib
DRAFTS = "$(HOME)/Downloads/drafts/Anealing.pdf"

.PHONY: all fetch convert pdf clean

all: fetch pdf

fetch:
	@mkdir -p $(BUILD_DIR)
	@echo "==> Fetching document from Google Docs..."
	@wget -O$(RAW) $(DOC_URL)
	@echo "    Document saved to $(RAW)"

convert:
	@tools/mkLatex.sh $(BASE_NAME)
	@echo "Copying figures and refs.bib"
	@cp includes/* $(BUILD_DIR)

pdf: convert
	@echo "==> Building PDF (first pass)..."
	@cd $(BUILD_DIR) && pdflatex -interaction=nonstopmode paper.tex > pdflatex.log 2>&1 || \
		(echo "    LaTeX error - check $(BUILD_DIR)/pdflatex.log"; exit 1)
	@echo "==> Running BibTeX... See: build/bibtex.log"
	@cd $(BUILD_DIR) && bibtex paper > bibtex.log 2>&1 || true
	@cd $(BUILD_DIR) && echo "   Result "`egrep -i 'error|warning' bibtex.log`
	@echo "==> Building PDF (second pass)..."
	@cd $(BUILD_DIR) && pdflatex -interaction=nonstopmode paper.tex >> pdflatex.log 2>&1
	@echo "==> Building PDF (final pass)..."
	@cd $(BUILD_DIR) && pdflatex -interaction=nonstopmode paper.tex >> pdflatex.log 2>&1
	@echo ""
	@echo "==> PDF created successfully: $(PDF)"
	cp $(PDF) $(DRAFTS)
	@echo ""

clean:
	@rm -rf $(BUILD_DIR)/*
	@echo "Build directory cleaned"
