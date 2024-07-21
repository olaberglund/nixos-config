#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "Usage: md-watch.sh <markdown file to watch>"
	exit 1
fi

echo "$1" | entr -rspc "echo 'Compiling...'; pandoc -f markdown -t pdf $1 -o output.pdf"
