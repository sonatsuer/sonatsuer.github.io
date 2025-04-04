#!/bin/bash

pandoc --mathjax=https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml-full.js\
       --standalone \
       --highlight-style pygments \
       -c ./assets/format.css \
       -H ./assets/extra-header.html \
       -A ./assets/footer.html \
       --title-prefix 'Blog of S.Süer' \
       ./markdown/posts/"$1".md -o ./"$1".html
