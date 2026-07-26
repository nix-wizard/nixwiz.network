#!/usr/bin/env bash

shopt -s nullglob

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

	replace_all "<!-- CONTENT -->" "$content" < ./base.html | \
	replace_all "<!-- TITLE -->" "$title"
}
