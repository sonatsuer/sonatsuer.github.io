#!/bin/bash

for file in ./markdown/posts/*.md
do
  echo "Doing $file"
  name=${file%.md}
  stripped="${name##*/}"
  ./markdown/build-post.sh $stripped
done
echo "Doing the index"
./markdown/build-index.sh
