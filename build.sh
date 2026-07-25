#!/usr/bin/env bash

. ./lib.sh

htdocs=./htdocs

# copy static files
if [ -d "$htdocs" ]; then
	rm -r $htdocs/*
else
	mkdir $htdocs
fi
www_root="$(cd htdocs && pwd)"
cp -r ./static/* $www_root/
cd $www_root

# BLOG GENERATION
# year list
generate_page "$(generate_dirlist "./blog")" "blog" > ./blog/index.html
# month list
for year in ./blog/*/; do
	generate_page "$(generate_dirlist "$year")" "$(basename $year)" > "$year/index.html"
	# day list
	for month in "$year"/*/; do
		generate_page "$(generate_dirlist "$month")" "$(basename $year)-$(basename $month)" > "$month/index.html"
		# post list
		for day in "$month"/*/; do
			generate_page "$(generate_dirlist "$day")" "$(basename $year)-$(basename $month)-$(basename $day)" > "$day/index.html"
			for post in "$day"/*/; do
				# AHHHHHHHHHHHHHHH
				echo "$(basename $year)-$(basename $month)-$(basename $day)" > "$post/date"
				generate_page " $(generate_tag h1 "$(cat "$post/title")") $(generate_tag p "$(cat "$post/date")") $(generate_tag h3 "$(cat "$post/description")") <hr> $(cat "$post/post.html")" "$(cat "$post/title")" > "$post/index.html"
			done
		done
	done
done
# blog page
echo "<ul>" >> ./pages/blog/index.html
find ./blog/ -type f -name 'post.html' | sort -r | while IFS= read -r file; do
	dir=$(dirname "$file")
	title=$(cat "$dir/title")
	date=$(cat "$dir/date")
	generate_tag li "$(generate_tag h2 "$(generate_link "$(echo "$date") - $(echo "$title")" "/blog/$(echo "$date" | replace_all "-" "/")/$(basename "$dir")/")")" >> ./pages/blog/index.html
done
echo "</ul>" >> ./pages/blog/index.html

# iterate through all of the pages & generate html files for them
for dir in ./pages/*/; do
	page=$(basename $dir)
	generate_page "$(cat "$dir/index.html")" "$page" > "$page".html
done

find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
