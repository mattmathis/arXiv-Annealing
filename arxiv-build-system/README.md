# arXiv Paper Build System

Automated workflow to convert Google Docs to LaTeX for arXiv submission.

## Directory Structure

```
paper/
├── Makefile              # Build automation
├── refs.bib              # BibTeX bibliography
├── scripts/
│   └── process-latex.sh  # Post-processing script
├── figures/
│   ├── fig1.png          # Your screenshot figures
│   ├── fig2.png
│   └── fig3.png
└── build/                # Generated files (git-ignored)
    ├── paper.docx        # Downloaded from Google Docs
    ├── paper.tex         # Converted LaTeX
    └── paper.pdf         # Final PDF
```

## Prerequisites

Install the required tools:

```bash
# On Ubuntu/Debian
sudo apt-get install pandoc texlive-full curl

# On macOS
brew install pandoc
brew install --cask mactex
# or for smaller install: brew install basictex

# On other systems, ensure you have:
# - pandoc (document conversion)
# - pdflatex (LaTeX compiler)
# - bibtex (bibliography processing)
# - curl (downloading from Google Docs)
```

## Setup

1. **Create the directory structure:**
   ```bash
   mkdir -p paper/scripts paper/figures paper/build
   cd paper
   ```

2. **Copy the files:**
   - `Makefile` to `paper/Makefile`
   - `scripts/process-latex.sh` to `paper/scripts/process-latex.sh`
   - `refs.bib` to `paper/refs.bib`

3. **Add your figures:**
   ```bash
   cp /path/to/your/screenshots/*.png figures/
   ```
   Make sure they're named `fig1.png`, `fig2.png`, `fig3.png` (or update the names in your document).

4. **Verify the document ID:**
   Open `Makefile` and confirm the `DOC_ID` matches your Google Doc URL:
   ```
   https://docs.google.com/document/d/YOUR_DOC_ID_HERE/edit
   ```

## Usage

### Full Build (Recommended)
```bash
make all
```
This will:
1. Download the latest version from Google Docs
2. Convert to LaTeX via Pandoc
3. Post-process the LaTeX
4. Build the PDF (with bibliography)

### Individual Steps

```bash
# Just download the document
make fetch

# Download and convert to LaTeX (no PDF)
make convert

# Build PDF from existing LaTeX
make rebuild

# Build and open the PDF
make view

# Clean all generated files
make clean
```

## Writing in Google Docs

### Citations
Reference your bibliography entries like this:
- `[@MLab14interconnection]` → formal citation
- `@Feamster2020challenges` → inline citation

The post-processing script will convert these to LaTeX `\cite{}` commands.

### Figures
The embedded images from your Google Doc will be automatically converted. If you want to add additional figures, reference them in your doc as:

```
[FIGURE: fig1]
```

This will be converted to a proper LaTeX figure environment.

### Sections
Use Google Docs heading styles:
- Heading 1 → `\section{}`
- Heading 2 → `\subsection{}`
- Heading 3 → `\subsubsection{}`

## Workflow

1. **Edit in Google Docs** - Keep writing naturally
2. **Run `make all`** - Build and check the PDF
3. **Iterate** - Make changes in Google Docs, rebuild
4. **For quick previews** - Use `make rebuild` (skips re-downloading)

## Customization

### Change LaTeX Template
Edit `scripts/process-latex.sh` to modify:
- Document class (line 29)
- Package list (lines 39-51)
- Title/author formatting (lines 54-60)

### Add CSL Style (Optional)
For specific citation formats, download a CSL file:
```bash
# Example: ACM style
curl -o acm-sig-proceedings.csl \
  https://raw.githubusercontent.com/citation-style-language/styles/master/acm-sig-proceedings.csl
```

Then Pandoc will automatically use it (see Makefile line 37).

### Adjust Figure Widths
Edit `scripts/process-latex.sh` line 75 to change default figure width:
```bash
sed -i 's/width=0.9/width=0.7/' ...  # Make figures smaller
```

## Troubleshooting

### "Document not found" error
- Verify the document is set to "Anyone with the link can view"
- Check the DOC_ID in the Makefile

### LaTeX compilation errors
1. Check `build/pdflatex.log` for details
2. Look at `build/paper.tex` directly
3. Common issues:
   - Missing figures: ensure PNGs are in `figures/`
   - Citation errors: verify keys in `refs.bib`
   - Special characters: may need escaping

### Figures not appearing
- Ensure filenames match exactly (case-sensitive)
- Verify figures copied to `build/` directory
- Check LaTeX log for "File not found" messages

### Bibliography not showing
- Verify citation keys match `refs.bib` entries
- Check `build/bibtex.log` for errors
- Ensure at least one citation in the text

## Advanced Usage

### Add More Bibliography Entries
Edit `refs.bib` and add entries in standard BibTeX format:

```bibtex
@article{Smith2025,
  author = {Smith, John and Doe, Jane},
  title = {Great Paper Title},
  journal = {ACM SIGCOMM},
  year = {2025},
  doi = {10.1145/example}
}
```

### Custom Post-Processing
Edit `scripts/process-latex.sh` to add your own transformations. The script uses `sed` for text processing.

### Watch Mode (Experimental)
For auto-rebuild on Google Doc changes, you could add a cron job:
```bash
# Rebuild every 10 minutes if document changed
*/10 * * * * cd /path/to/paper && make all
```

## Files Generated

- `build/paper.docx` - Downloaded Google Doc
- `build/paper.tex` - LaTeX source
- `build/paper.tex.backup` - Pre-processing backup
- `build/paper.pdf` - Final PDF
- `build/paper.aux`, `paper.log`, `paper.bbl`, etc. - LaTeX intermediates

## Contributing to Your Paper

Since you're working solo, you can maintain the "source of truth" in Google Docs and generate LaTeX only for arXiv submission. If you later add collaborators:

1. Keep Google Docs as the primary editing interface
2. They can comment/suggest as usual
3. You rebuild the PDF when ready

## arXiv Submission

When ready to submit:

1. `make clean && make all` - Fresh build
2. Review `build/paper.pdf`
3. Upload to arXiv:
   - Main file: `build/paper.tex`
   - Bibliography: `refs.bib` (or include in .tex if embedded)
   - Figures: `figures/*.png`
   - Or create a zip: `cd build && zip -r arxiv-submission.zip paper.tex *.png`

arXiv will recompile from your LaTeX source.

## Tips

- **Version control**: Add `build/` to `.gitignore`
- **Backup**: Google Docs auto-saves, but keep `refs.bib` in git
- **Test early**: Run builds frequently to catch issues
- **CSL styles**: Use ACM, IEEE, or arXiv-recommended formats

## Questions?

Check the Makefile comments or post-processing script for implementation details.
