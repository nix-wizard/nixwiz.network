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

commentdirs=(./"$page"/*/)
for ((i=${#commentdirs[@]}-1; i>=0; i--)); do
	if [ "$(basename "${commentdirs[$i]}")" != "by-ip" ]; then
		timestamp="$(<"${commentdirs[$i]}/timestamp")"
		date="$(date -d "@$((timestamp / 1000000000))" --iso-8601)"
		
		printf '<p>%s said:</p>\n' "$(html_escape < "${commentdirs[$i]}/name")"
		printf '<p>%s</p>\n' "$(html_escape < "${commentdirs[$i]}/comment")"
		printf '<p>%s</p>\n' "$date"
		printf '<label class="fake-button" for="replycheck-%s">reply</label>\n' "$timestamp"
		printf '<input class="invisible" type="checkbox" id="replycheck-%s">\n' "$timestamp"
		printf '<div class="invisible replybox reply">\n'
			printf '<p>leave a reply!</p>\n'
			printf '<iframe name="replybox-%s" width="100%%" height="200px" frameborder="0" src="/cgi-bin/commentbox.cgi?page=%s&reply=%s"></iframe>\n' "$timestamp" "$page" "$timestamp"
		printf '</div>\n'
		printf '<hr>\n'
		
		replydirs=("${commentdirs[$i]}"/replies/*/)
		for ((j=${#replydirs[@]}-1; j>=0; j--)); do
			if [ "$(basename "${replydirs[$j]}")" != "by-ip" ]; then
				timestamp="$(<"${replydirs[$j]}/timestamp")"
				date="$(date -d "@$((timestamp / 1000000000))" --iso-8601)"
				
				printf '<div class="reply">\n'
					printf '<p>%s replied:</p>\n' "$(html_escape < "${replydirs[$j]}/name")"
					printf '<p>%s</p>\n' "$(html_escape < "${replydirs[$j]}/comment")"
					printf '<p>%s</p>\n' "$date"
				printf '</div>\n'
			fi
		done
	fi
done
