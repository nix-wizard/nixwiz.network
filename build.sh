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
generate_page "$(generate_dirlist "./blog")" "blog" "/blog/index.html" > ./blog/index.html
# month list
for yeardir in ./blog/*/; do
	year=$(basename "$yeardir")
	generate_page "$(generate_dirlist "$yeardir")" "$year" "$(path_to_url "$yeardir")"> "$yeardir/index.html"
	# day list
	for monthdir in "$yeardir"/*/; do
		month=$(basename "$monthdir")
		generate_page "$(generate_dirlist "$monthdir")" "$year-$month" "$(path_to_url "$monthdir")" > "$monthdir/index.html"
		# post list
		for daydir in "$monthdir"/*/; do
			day=$(basename "$daydir")
			date="$year-$month-$day"
			generate_page "$(generate_dirlist "$daydir")" "$date" "$(path_to_url "$daydir")" > "$daydir/index.html"
			for postdir in "$daydir"/*/; do
				post=$(<"$postdir/post.html")
				title=$(<"$postdir/title")
				description=$(<"$postdir/description")
				printf '%s\n' "$date" > "$postdir/date"
				generate_page " $(generate_tag h1 "$title") $(generate_tag p "$date") $(generate_tag h3 "$description") <hr> $post" "$title" "$(path_to_url "$postdir")" > "$postdir/index.html"
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
	postdir="$(path_to_url "$dir")"
	generate_tag li "$(generate_tag h2 "$(generate_link "$(printf '%s\n' "$date") - $(printf '%s\n' "$title")" "$postdir")")" >> ./pages/blog/index.html
done
printf '</ul>\n' >> ./pages/blog/index.html

# iterate through all of the pages & generate html files for them
for dir in ./pages/*/; do
	page=$(basename "$dir")
	generate_page "$(<"$dir/index.html")" "$page" "$page".html > "$page".html
done

find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
find ./cgi-bin -type f -exec chmod 755 {} \;
