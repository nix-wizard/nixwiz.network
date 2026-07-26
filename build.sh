#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

. ./lib.sh

htdocs=./htdocs

# copy static files
if [ -d "$htdocs" ]; then
	rm -r "$htdocs"/*
else
	mkdir "$htdocs"
fi
www_root="$(cd "$htdocs" && pwd)"
cp -r ./static/* "$www_root"/
cd "$www_root"

# BLOG GENERATION
# year list
generate_page "$(generate_dirlist "./blog")" "blog" > ./blog/index.html
# month list
for yeardir in ./blog/*/; do
	year=$(basename "$yeardir")
	generate_page "$(generate_dirlist "$yeardir")" "$year" > "$yeardir/index.html"
	# day list
	for monthdir in "$yeardir"/*/; do
		month=$(basename "$monthdir")
		generate_page "$(generate_dirlist "$monthdir")" "$year-$month" > "$monthdir/index.html"
		# post list
		for daydir in "$monthdir"/*/; do
			day=$(basename "$daydir")
			date="$year-$month-$day"
			generate_page "$(generate_dirlist "$daydir")" "$date" > "$daydir/index.html"
			for postdir in "$daydir"/*/; do
				post=$(<"$postdir/post.html")
				title=$(<"$postdir/title")
				description=$(<"$postdir/description")
				printf '%s\n' "$date" > "$postdir/date"
				generate_page " $(generate_tag h1 "$title") $(generate_tag p "$date") $(generate_tag h3 "$description") <hr> $post" "$title" > "$postdir/index.html"
			done
		done
	done
done
# blog page
printf '<ul>\n' >> ./pages/blog/index.html
find ./blog/ -type f -name 'post.html' | sort -r | while IFS= read -r file; do
	dir=$(dirname "$file")
	title=$(<"$dir/title")
	date=$(<"$dir/date")
	postdir="/blog/$(printf '%s\n' "$date" | replace_all "-" "/")/$(basename "$dir")/" # there has gotta be a better way to do this
	generate_tag li "$(generate_tag h2 "$(generate_link "$(printf '%s\n' "$date") - $(printf '%s\n' "$title")" "$postdir")")" >> ./pages/blog/index.html
done
printf '</ul>\n' >> ./pages/blog/index.html

# iterate through all of the pages & generate html files for them
for dir in ./pages/*/; do
	page=$(basename "$dir")
	generate_page "$(<"$dir/index.html")" "$page" > "$page".html
done

find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
