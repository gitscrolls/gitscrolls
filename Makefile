SHELL := /bin/sh

SCROLL_DIR := scrolls
TEX_DIR := $(SCROLL_DIR)/tex
CHAPTER_DIR := $(TEX_DIR)/chapters
TXT_DIR := $(SCROLL_DIR)/text
BUILD_DIR := $(SCROLL_DIR)/build

SCROLL_FILES := $(shell \
  ls $(SCROLL_DIR)/[0-9][0-9]-*.md 2>/dev/null | sort -V | \
  awk -F/ '{ \
    stem=$$NF; \
    sub(/\.md$$/, "", stem); \
    key=substr(stem,1,2); \
    if (!(key in chosen) || stem ~ /-2$$/) { chosen[key] = $$0; } \
  } END { \
    for (k in chosen) { print k " " chosen[k]; } \
  }' | \
  sort -k1,1V | awk '{print $$2}')
CHAPTER_TEX := $(patsubst $(SCROLL_DIR)/%.md,$(CHAPTER_DIR)/%.tex,$(SCROLL_FILES))
CHAPTER_TXT := $(patsubst $(SCROLL_DIR)/%.md,$(TXT_DIR)/%.txt,$(SCROLL_FILES))
CHAPTER_STEMS := $(notdir $(basename $(SCROLL_FILES)))

COLLECTION_TEX := $(TEX_DIR)/collection.tex
CHAPTER_LIST := $(TEX_DIR)/chapter-list.tex
CHAPTER_ONLY_TEX := $(TEX_DIR)/chapter-only.tex
BOOK_PDF := $(BUILD_DIR)/chronicle-book.pdf
BOOK_TXT := $(BUILD_DIR)/chronicle.txt

PANDOC := pandoc
PDFLATEX := xelatex
PANDOC_FLAGS := --from=gfm --to=latex --wrap=none --syntax-highlighting=none
PDFLATEX_FLAGS := -interaction=nonstopmode -halt-on-error -file-line-error

.PHONY: all pdf txt scrolls single clean

all: pdf txt scrolls

pdf: $(BOOK_PDF)
pdfs: pdf

txt: $(BOOK_TXT)
txts: txt

scrolls: $(CHAPTER_TEX) $(CHAPTER_LIST)

$(CHAPTER_LIST): $(CHAPTER_TEX)
$(CHAPTER_LIST): Makefile
	@mkdir -p $(TEX_DIR)
	@printf '' > "$@"
	@for chapter in $(CHAPTER_STEMS); do \
		printf "\\input{chapters/%s}\n" "$$chapter" >> "$@"; \
	done

$(BOOK_PDF): $(COLLECTION_TEX) $(CHAPTER_LIST) $(CHAPTER_TEX)
	@mkdir -p $(BUILD_DIR)
	@cd $(TEX_DIR) && \
		$(PDFLATEX) $(PDFLATEX_FLAGS) -output-directory=../build collection.tex >/dev/null && \
		$(PDFLATEX) $(PDFLATEX_FLAGS) -output-directory=../build collection.tex >/dev/null

$(CHAPTER_TEX): $(CHAPTER_DIR)/%.tex: $(SCROLL_DIR)/%.md $(TEX_DIR)/press-shared.tex Makefile | $(CHAPTER_DIR)
	@mkdir -p $(CHAPTER_DIR)
	@chapter_title=$$(awk 'NR == 1 {sub(/^# +/, "", $$0); print $$0; exit}' "$<"); \
	if [ -z "$$chapter_title" ]; then \
		chapter_title="$*"; \
	fi; \
	printf "\\chapter{%s}\\n\\label{chap:%s}\\n\\n" "$$chapter_title" "$*" > "$@"; \
	awk '\
		NR == 1 && $$0 ~ /^# / { next } \
		/^[[:space:]]*[\*_]*(Next|Previous):/ { next } \
		/^[[:space:]]*[\*_]*To be continued in GitScroll / { next } \
		/^[[:space:]]*[_*]*GitScrolls: The Epic of Tuxicles/ { next } \
		/^[[:space:]]*[_*]*©[[:space:]]*2025 J\. Kirby Ross/ { next } \
		/^[[:space:]]*[_*]*Licensed under \[CC BY-NC-SA 4.0\]/ { next } \
		/^[[:space:]]*[_*]*Commercial use beyond the license\?/ { next } \
		{ print } \
	' "$<" | \
		$(PANDOC) $(PANDOC_FLAGS) \
		| sed -e 's#\\begin{center}\\rule{0.5\\linewidth}{0.5pt}\\end{center}#\\bookdivider#g' \
		      -e 's#\\begin{verbatim}#\\begin{codeblock}#g' \
		      -e 's#\\end{verbatim}#\\end{codeblock}#g' \
		| perl -0pe ' \
			s/\\section\{\\texorpdfstring\{\\textbf\{🎭 ([^}]*)\}\{[^}]*\}\}/\\chroniclersection{$$1}/g; \
			s/\\subsection\{\\texorpdfstring\{\\textbf\{🎭 ([^}]*)\}\{[^}]*\}\}/\\chroniclersubsection{$$1}/g; \
			s/\\subsubsection\{\\texorpdfstring\{\\textbf\{🎭 ([^}]*)\}\{[^}]*\}\}/\\chroniclersubsubsection{$$1}/g; \
			s/\\section\{🎭 ([^}]*)\}/\\chroniclersection{$$1}/g; \
			s/\\subsection\{🎭 ([^}]*)\}/\\chroniclersubsection{$$1}/g; \
			s/\\subsubsection\{🎭 ([^}]*)\}/\\chroniclersubsubsection{$$1}/g; \
			s/\\emph\{\\textbf\{CHRONICLER:\}\}/\\chronicler{CHRONICLER:}/g; \
			s/\\textit\{\\textbf\{CHRONICLER:\}\}/\\chronicler{CHRONICLER:}/g; \
			s/\\textbf\{CHRONICLER:\}/\\chronicler{CHRONICLER:}/g; \
			s/\\emph\{\\textbf\{CHRONICLER\}\}/\\chronicler{CHRONICLER}/g; \
			s/\\textit\{\\textbf\{CHRONICLER\}\}/\\chronicler{CHRONICLER}/g; \
			s/\\textbf\{CHRONICLER\}/\\chronicler{CHRONICLER}/g;' >> "$@"

$(CHAPTER_TXT): $(TXT_DIR)/%.txt: $(SCROLL_DIR)/%.md Makefile | $(TXT_DIR)
	@mkdir -p $(TXT_DIR)
	awk '/^[[:space:]]*[\*_]*(Next|Previous):/ { next } \
		/^[[:space:]]*[\*_]*To be continued in GitScroll / { next } \
		/^[[:space:]]*[_*]*GitScrolls: The Epic of Tuxicles/ { next } \
		/^[[:space:]]*[_*]*©[[:space:]]*2025 J\. Kirby Ross/ { next } \
		/^[[:space:]]*[_*]*Licensed under \[CC BY-NC-SA 4.0\]/ { next } \
		/^[[:space:]]*[_*]*Commercial use beyond the license\?/ { next } \
		{ print }' "$<" | \
		$(PANDOC) --from=gfm --to=plain --wrap=none -o "$@"

$(BOOK_TXT): $(CHAPTER_TXT)
	@mkdir -p $(BUILD_DIR)
	@printf '' > "$@"
	@for chapter_txt in $(CHAPTER_TXT); do \
		stem=$$(basename "$$chapter_txt" .txt); \
title=$$(awk 'NR == 1 {sub(/^# +/, "", $$0); print $$0; exit}' "$(SCROLL_DIR)/$$stem.md"); \
		printf '\n\\f\\n' >> "$@"; \
		printf '## %s\n' "$$title" >> "$@"; \
		printf '%s\n\n' "------------------------------------------------------------" >> "$@"; \
		cat "$$chapter_txt" >> "$@"; \
		printf '\n\n' >> "$@"; \
	done

single: $(CHAPTER_ONLY_TEX) $(CHAPTER_TEX)
	@if [ -z "$(SCROLL)" ]; then \
		echo "Usage: make single SCROLL=<scroll-file-stem>"; \
		echo "Example: make single SCROLL=01-Unbroken-Line"; \
		exit 2; \
	fi
	@if [ ! -f "$(SCROLL_DIR)/$(SCROLL).md" ]; then \
		echo "Missing source markdown: $(SCROLL_DIR)/$(SCROLL).md"; \
		exit 2; \
	fi
	@mkdir -p $(BUILD_DIR)
	@cd $(TEX_DIR) && \
		$(PDFLATEX) $(PDFLATEX_FLAGS) -output-directory=../build -jobname=chapter-$(SCROLL) "\\def\\SingleScroll=$(SCROLL)\\input{chapter-only.tex}" >/dev/null && \
		$(PDFLATEX) $(PDFLATEX_FLAGS) -output-directory=../build -jobname=chapter-$(SCROLL) "\\def\\SingleScroll=$(SCROLL)\\input{chapter-only.tex}" >/dev/null

clean:
	@rm -rf $(BUILD_DIR) $(CHAPTER_DIR) $(TXT_DIR) $(CHAPTER_LIST)

$(CHAPTER_DIR):
	@mkdir -p "$@"

$(TXT_DIR):
	@mkdir -p "$@"
