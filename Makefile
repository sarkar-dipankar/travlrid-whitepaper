# Makefile for Travlr ID Whitepaper
# Compiles main.tex to PDF with proper bibliography handling

# Variables
LATEX = pdflatex
BIBTEX = bibtex
MAIN = main
OUTPUT = $(MAIN).pdf
TEXFILE = $(MAIN).tex

# LaTeX compilation flags
LATEX_FLAGS = -interaction=nonstopmode -halt-on-error

# Auxiliary files generated during compilation
AUX_FILES = *.aux *.log *.out *.toc *.bbl *.blg *.synctex.gz

# Default target
.PHONY: all
all: $(OUTPUT)

# Build the PDF
$(OUTPUT): $(TEXFILE) sample.bib
	@echo "==> First LaTeX pass..."
	$(LATEX) $(LATEX_FLAGS) $(TEXFILE)
	@echo "==> Running BibTeX (if citations exist)..."
	-$(BIBTEX) $(MAIN) 2>/dev/null || echo "No citations found, skipping BibTeX"
	@echo "==> Second LaTeX pass..."
	$(LATEX) $(LATEX_FLAGS) $(TEXFILE)
	@echo "==> Third LaTeX pass (final)..."
	$(LATEX) $(LATEX_FLAGS) $(TEXFILE)
	@echo "==> PDF generated successfully: $(OUTPUT)"

# Quick build (single pass, useful for draft viewing)
.PHONY: quick
quick:
	@echo "==> Quick build (single pass)..."
	$(LATEX) $(LATEX_FLAGS) $(TEXFILE)
	@echo "==> Draft PDF generated: $(OUTPUT)"

# Clean auxiliary files but keep PDF
.PHONY: clean
clean:
	@echo "==> Cleaning auxiliary files..."
	rm -f $(AUX_FILES)
	@echo "==> Clean complete"

# Clean everything including PDF
.PHONY: cleanall
cleanall:
	@echo "==> Cleaning all generated files..."
	rm -f $(AUX_FILES) $(OUTPUT)
	@echo "==> All files cleaned"

# View the PDF (platform-specific)
.PHONY: view
view: $(OUTPUT)
	@echo "==> Opening PDF..."
	@if [ -f $(OUTPUT) ]; then \
		if command -v xdg-open > /dev/null; then \
			xdg-open $(OUTPUT); \
		elif command -v open > /dev/null; then \
			open $(OUTPUT); \
		else \
			echo "No PDF viewer command found. Please open $(OUTPUT) manually."; \
		fi \
	else \
		echo "Error: $(OUTPUT) not found. Run 'make' first."; \
	fi

# Check for required tools
.PHONY: check
check:
	@echo "==> Checking for required tools..."
	@command -v $(LATEX) >/dev/null 2>&1 || { echo "Error: pdflatex not found. Please install a LaTeX distribution."; exit 1; }
	@command -v $(BIBTEX) >/dev/null 2>&1 || { echo "Error: bibtex not found. Please install a LaTeX distribution."; exit 1; }
	@echo "==> All required tools are installed"

# Watch mode - rebuild on file changes (requires inotify-tools on Linux or fswatch on macOS)
.PHONY: watch
watch:
	@echo "==> Watching for changes..."
	@if command -v inotifywait > /dev/null; then \
		while true; do \
			inotifywait -e modify $(TEXFILE) sample.bib *.png && make quick; \
		done \
	elif command -v fswatch > /dev/null; then \
		fswatch -o $(TEXFILE) sample.bib *.png | xargs -n1 -I{} make quick; \
	else \
		echo "Error: Neither inotifywait nor fswatch found."; \
		echo "Install inotify-tools (Linux) or fswatch (macOS) for watch mode."; \
		exit 1; \
	fi

# Display help
.PHONY: help
help:
	@echo "Travlr ID Whitepaper - Makefile Commands"
	@echo "========================================"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build the PDF with full bibliography support (default)"
	@echo "  quick     - Quick single-pass build for draft viewing"
	@echo "  clean     - Remove auxiliary files (keep PDF)"
	@echo "  cleanall  - Remove all generated files including PDF"
	@echo "  view      - Open the generated PDF"
	@echo "  check     - Verify required tools are installed"
	@echo "  watch     - Auto-rebuild on file changes (requires inotify-tools/fswatch)"
	@echo "  help      - Display this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make              # Build the PDF"
	@echo "  make clean        # Clean auxiliary files"
	@echo "  make view         # Build and open PDF"
	@echo "  make watch        # Auto-rebuild on changes"
