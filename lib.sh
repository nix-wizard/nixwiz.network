#/usr/bin/env bash

shopt -s nullglob

replace_all() {
	placeholder=$1
	replacement=$2
	content=$(cat)
	printf '%s\n' "${content//$placeholder/$replacement}"
}

generate_tag()
{
	echo "<$1>$2</$1>"
}

generate_link()
{
	echo "<a href=\"$2\">$1</a>"
}

generate_include()
{
	echo "<!--#include virtual=\"$1\" -->"
}

generate_dirlist()
{
	for dir in "$1"/*/; do
		dirname=$(basename $dir)
		generate_tag h2 "$(generate_link "./$dirname/" "./$dirname/")"
		echo "<br>"
	done
	for file in "$1"/*; do
		filename=$(basename $file)
		if [ -f "$file" ] && [ "$filename" != "index.html" ]; then
			generate_tag h2 "$(generate_link "./$filename" "./$filename")"
			echo "<br>"
		fi
	done
}

generate_page()
{
	content="$1"
	title="$2"

	replace_all "<!-- CONTENT -->" "$content" < ./base.html | \
	replace_all "<!-- TITLE -->" "$2"
}
