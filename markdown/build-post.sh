#!/bin/bash

pandoc --mathjax \
       --highlight-style pygments \
       -c ./assets/format.css \
       -H ./assets/extra-header.html \
       -A ./assets/footer.html \
       --title-prefix 'Blog of S.Süer' \
       --smart \
       ./markdown/posts/$1.md -o ./$1.html
