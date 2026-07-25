#!/usr/bin/env bash

. ./lib.sh

htdocs=./htdocs
www_root="$(cd htdocs && pwd)"

# copy static files
if [ -d "$www_root" ]; then
	rm -rf $www_root/*
else
	mkdir $www_root
fi
cp -r ./static/* $www_root/
cd $www_root

# iterate through all of the pages & generate html files for them
for dir in ./pages/*/; do
	page=$(basename $dir)
	generate_page "$(generate_include "/pages/$page/index.html")" "$page" > "$page".html
done

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
				generate_page " $(generate_tag h1 "$(cat "$post/title")") $(generate_tag h3 "$(cat "$post/description")") <hr> $(generate_include "./post.html") " > "$post/index.html"
			done
		done
	done
done

find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
