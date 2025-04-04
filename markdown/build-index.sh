#!/bin/bash
pandoc --mathjax=https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml-full.js \
       --standalone \
       --highlight-style pygments \
       -c ./assets/format.css \
       -H ./assets/extra-header.html \
       -V title='' \
       ./markdown/index.md -o ./index.html
