#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

. ../../lib.sh

if [[ "${REQUEST_METHOD-}" != "POST" ]]; then
	return_status "403" "forbidden: not a POST"
fi
if [[ "${HTTP_SEC_FETCH_SITE-}" != "same-origin" ]]; then
	return_status "403" "forbidden: requires valid Sec-Fetch-Site header"
fi

cd ../../comments

declare -A queries
declare -A body
parse_values "${QUERY_STRING-}" queries
parse_values "$(</dev/stdin)" body
assert_var "${queries[page]-}"
assert_var "${body[name]-}"
assert_var "${body[comment]-}"
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
if [ ! -f "../htdocs/$page" ]; then
	return_status "400" "bad request: not a page"
fi
name="$(url_decode "${body[name]}")"
comment="$(url_decode "${body[comment]}")"
# input length validation
if ((${#name} > 32)); then
	return_status "400" "name must be at most 32 characters"
fi
if ((${#comment} > 256)); then
	return_status "400" "comment must be at most 256 characters"
fi
# weird characters
if printf '%s' "$name" | grep -q '[[:cntrl:]]'; then
	return_status "400" "invalid characters"
fi
if printf '%s' "$comment" | grep -q '[[:cntrl:]]'; then
	return_status "400" "invalid characters"
fi
ip="${HTTP_X_REAL_IP-}" # ONLY CORRECT WHEN BEHIND THE REVERSE PROXY
timestamp="$(date +%s%N)"

if [ -e "./$page/by-ip/$ip" ]; then # if this ip has already posted
	old_timestamp=$(<"./$page/by-ip/$ip/timestamp")
	rm -rf "./$page/$old_timestamp/"
	rm -rf "./$page/by-ip/$ip"
fi

mkdir -p "./$page/by-ip"
ln -s "../$timestamp" "./$page/by-ip/$ip"

mkdir -p "./$page/$timestamp"
cd "./$page/$timestamp"

printf '%s' "$page" > page
printf '%s' "$name" > name
printf '%s' "$comment" > comment
printf '%s' "$ip" > ip
printf '%s' "$timestamp" > timestamp

header 'Content-Type: text/html'
header ''

printf '<p>success!</p>\n'
