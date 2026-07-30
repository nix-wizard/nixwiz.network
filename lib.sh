#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

origin="https://nixwiz.network"
server_name="nixwiz.network"

stylesheet='<link rel="stylesheet" href="/assets/style/minimal.css">'

clrf=$'\r\n'

replace_all() {
	local placeholder=$1
	local replacement=$2
	local content

	replacement=${replacement//&/\\&}
	content=$(</dev/stdin)
	printf '%s\n' "${content//$placeholder/$replacement}"
}

generate_tag()
{
	local tag="$1"
	local content="$2"

	printf '<%s>%s</%s>\n' "$tag" "$content" "$tag"
}

generate_link()
{
	local content="$1"
	local href="$2"

	printf '<a href="%s">%s</a>' "$href" "$content"
}

generate_include()
{
	local page="$1"

	printf '<!--#include virtual="%s" -->' "$page"
}

generate_dirlist()
{
	local directory="$1"

	for dir in "$directory"/*/; do
		local dirname=$(basename "$dir")
		generate_tag h2 "$(generate_link "./$dirname/" "./$dirname/")"
		printf '<br>\n'
	done
	for file in "$directory"/*; do
		local filename=$(basename "$file")
		if [ -f "$file" ] && [ "$filename" != "index.html" ]; then
			generate_tag h2 "$(generate_link "./$filename" "./$filename")"
			printf '<br>'
		fi
	done
}

generate_page()
{
	local content="$1"
	local title="$2"
	local page="$3"
	
	replace_all '<!-- CONTENT -->' "$content" < ./base.html | \
	replace_all '<!-- TITLE -->' "$title" | \
	replace_all '<!-- PAGE -->' "$page"
}

path_to_url()
	{
		string="$1"
		local string="${1//\/\//\/}" # uh
		printf '%s' "${string:1}"
	}


header() {
	printf '%s%s' "$1" "$clrf"
}

url_decode() {
	local data="${1//+/ }"
	printf '%b' "${data//%/\\x}"
}

parse_values() {
	local input="$1"
	local -n result="$2"

	local pair key value
	local IFS='&'

	read -ra pairs <<<"$input"

	for pair in "${pairs[@]}"; do
		IFS='=' read -r key value <<<"$pair"
		result["$key"]="$value"
	done
}


return_status() {
	header "Status: $1"
	header 'Content-Type: text/html'
	header ''
	printf '%s\n' "$stylesheet"
	printf '<p style="color: #FF0000;"">%s</p>\n' "$2"
	exit
}

assert_var() {
	if [ -z "$1" ]; then
		return_status "400" "bad request"
	fi
}

html_escape() {
	local s
	s=$(</dev/stdin)

	s=${s//&/\&amp;}
	s=${s//</\&lt;}
	s=${s//>/\&gt;}
	s=${s//\"/\&quot;}
	s=${s//\'/\&#39;}

	printf '%s' "$s"
}
