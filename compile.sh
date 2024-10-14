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
  compile="$CMD_LATEX -interaction=nonstopmode --shell-escape --jobname=\"main\" \"\def\FOMEN{}\input{$CURRENT_DIR/main.tex}\""
else
  compile="$CMD_LATEX -interaction=nonstopmode --shell-escape \"$CURRENT_DIR/main.tex\""
fi

if $USE_LATEXMK; then
  compile="latexmk -pdf -shell-escape -interaction=nonstopmode \"$CURRENT_DIR/main.tex\""
fi

# Run the compilation
eval "$compile"
RETVAL="$?"
if [[ "${RETVAL}" -ne 0 ]] ; then
    echo "First compilation failed"
    exit ${RETVAL}
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
rm ./*.bbl 2> /dev/null
rm ./*.blg 2> /dev/null
rm ./*.aux 2> /dev/null
rm ./*.bcf 2> /dev/null
rm ./*.ilg 2> /dev/null
rm ./*.lof 2> /dev/null
rm ./*.log 2> /dev/null
rm ./*.lot 2> /dev/null
rm ./*.nlo 2> /dev/null
rm ./*.nls* 2> /dev/null
rm ./*.out 2> /dev/null
rm ./*.toc 2> /dev/null
rm ./*.run.xml 2> /dev/null
rm ./*.lot 2> /dev/null
rm ./*.sub 2> /dev/null
rm ./*.suc 2> /dev/null
rm ./*.syc 2> /dev/null
rm ./*.sym 2> /dev/null

echo "PDF Compile: Success"
exit 0
