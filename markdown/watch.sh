postpath="./markdown/posts/$1.md"
while inotifywait -e close_write "${postpath}" ; do ./markdown/build-post.sh "$1"; done
