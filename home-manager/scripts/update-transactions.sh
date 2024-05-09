#!/bin/sh

temp_file=$(mktemp)
gzip -c /home/ola/Code/rinder/transactions.json >"$temp_file"
gdrive files update 1xJaSg5vrV9EXG36z74B5ynSgI6jzT-sJ --mime application/json "$temp_file"

rm "$temp_file"
