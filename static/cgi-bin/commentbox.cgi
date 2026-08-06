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
assert_var "${queries[reply]-}"
page="$(url_decode "${queries[page]-}")"
reply="$(url_decode "${queries[reply]-}")"

header 'Content-Type: text/html'
header ''

printf '%s\n' "$stylesheet"
printf '%s\n' "<form action=\"/cgi-bin/comment.cgi?page=$page&reply=$reply\" method=\"POST\" target=\"commentdummy\">"
printf '%s\n' '<label for="name">name:</label><br>'
printf '%s\n' '<input style="width: 100%;" type="text" rows="1" maxlength="32" id="name" name="name"></input><br>'
printf '%s\n' '<label for="comment">comment:</label><br>'
printf '%s\n' '<textarea style="resize: vertical; width: 100%;" rows="4" maxlength="256" id="comment" name="comment"></textarea><br>'
printf '%s\n' '<iframe name="commentdummy" width="100%" id="commentdummy" frameborder="0" height="32px"></iframe>'
printf '%s\n' '<input type="submit" name="Submit" value="Submit">'
printf '%s\n' '</form>'
