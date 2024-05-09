#!/bin/sh

if [ -z "$1" ]; then
	echo "Usage: md-watch.sh <markdown file to watch>"
	exit 1
fi

echo "-- Updating 'output.pdf' on every change --"
watchexec -e md -- echo "Compiling..." && pandoc -f markdown -t pdf "$1" -o output.pdf
