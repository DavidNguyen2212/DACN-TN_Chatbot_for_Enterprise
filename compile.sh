#!/usr/bin/env bash
# Run the Script from the folder you are in...
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CMD_LATEX=pdflatex
USE_LATEXMK=false

# avoid $TERM warning
export TERM=xterm-256color

echo "Compiling in Language: $1"

# Check if latexmk is available
if command -v latexmk &> /dev/null; then
  USE_LATEXMK=true
fi

# Compilation command
if [ "$1" = "en" ] || [ "$2" = "en" ]; then
  compile="$CMD_LATEX -interaction=nonstopmode --shell-escape --jobname=document '\def\FOMEN{}\input{$CURRENT_DIR/main.tex}'"
else
  compile="$CMD_LATEX -interaction=nonstopmode --shell-escape --jobname=document $CURRENT_DIR/main.tex"
fi

if $USE_LATEXMK; then
  compile="latexmk -pdf -shell-escape -interaction=nonstopmode $CURRENT_DIR/main.tex"
fi

# Run the compilation
eval "$compile"
RETVAL="$?"
if [[ "${RETVAL}" -ne 0 ]] ; then
    echo "First compilation failed"
    exit ${RETVAL}
fi

# Rename PDF if latexmk is used
if $USE_LATEXMK; then
  mv "$CURRENT_DIR/main.pdf" "$CURRENT_DIR/document.pdf"
fi

# Run bibtex if not using latexmk
if ! $USE_LATEXMK; then
  bibtex "$CURRENT_DIR/main"
  RETVAL="$?"
  if [[ "${RETVAL}" -ne 0 ]] ; then
      echo "bibtex run failed"
      exit ${RETVAL}
  fi
fi

# Additional pdflatex runs if not using latexmk
if ! $USE_LATEXMK; then
  eval "$compile"
  RETVAL="$?"
  if [[ "${RETVAL}" -ne 0 ]] ; then
      echo "Second compilation failed"
      exit ${RETVAL}
  fi

  eval "$compile"
  RETVAL="$?"
  if [[ "${RETVAL}" -ne 0 ]] ; then
      echo "Third compilation failed"
      exit ${RETVAL}
  fi
fi

# Cleanup
rm -f ./*.{bbl,blg,aux,bcf,ilg,lof,log,lot,nlo,nls,out,toc,run.xml,sub,suc,syc,sym}

echo "PDF Compile: Success"
exit 0
