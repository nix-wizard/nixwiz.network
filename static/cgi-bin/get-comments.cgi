#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

. ../../lib.sh

if [[ "${REQUEST_METHOD-}" != "GET" ]]; then
	return_status "403" "forbidden: not a GET"
fi

cd /var/lib/"$server_name"/comments

declare -A queries
parse_values "${QUERY_STRING-}" queries
assert_var "${queries[page]-}"
page="$(url_decode "${queries[page]-}")"
# prevents comments from the folder itself instead of index.html from being separate
if [[ $page != *".html" ]]; then
	page="/$page/index.html"
fi
# prevent path traversal
root="$(realpath ./)"
target="$(realpath -m "./$page")"
if [[ "$target" != "$root/"* && "$target" != "$root" ]]; then
	return_status "400" "bad request: fuck off!!!!"
fi
# make sure the page actually exists
if [ ! -f "/var/www/$server_name/htdocs/$page" ]; then
	return_status "400" "bad request: page does not exist"
fi

header 'Content-Type: text/html'
header ''

if [[ ! -d "./$page/" || -z "$(ls "./$page/")" ]]; then
	printf '<p>no comments.</p>\n'
	exit
fi

ls -d ./"$page"/*/ | sort -r | while IFS= read -r commentdir; do
	if [ "$(basename "$commentdir")" != "by-ip" ]; then
		printf '<hr>\n'
		printf '<p>%s said:</p>\n' "$(html_escape < "$commentdir/name")"
		printf '<p>%s</p>\n' "$(html_escape < "$commentdir/comment")"
	fi
done
printf '<hr>\n'
