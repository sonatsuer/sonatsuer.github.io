#!/bin/bash
pandoc --mathjax \
       --highlight-style pygments \
       -c ./assets/format.css \
       -H ./assets/extra-header.html \
       -V title='' \
       ./markdown/index.md -o ./index.html
