#!/usr/bin/env sh

# PLEASE FEEL FREE TO KILL ME FOR THIS SCRIPT

www_root=./htdocs

escape_sed_replacement() {
	printf '%s\n' "$1" | sed -e 's/[\/&]/\\&/g'
}

# add static files to public
rm -rf $www_root/*
cp -r ./assets/ $www_root/assets
cp -r ./share/ $www_root/share
cp -r ./pages/ $www_root/pages

# add robots.txt
cat ./robots.txt > $www_root/robots.txt

# PAGES

# index
index_object=$(escape_sed_replacement '<object type="text/html" data="/pages/index/index.html"></object>')
index_link=$(escape_sed_replacement '/pages/index/index.html')
sed "s/<!-- CONTENT --!>/$index_object/" ./base.html | sed "s/<!-- TITLE --!>/index/" | sed "s/<!-- LINK --!>/$index_link/" > $www_root/index.html

# about
about_object=$(escape_sed_replacement '<object type="text/html" data="/pages/about/index.html"></object>')
about_link=$(escape_sed_replacement '/pages/about/index.html')
sed "s/<!-- CONTENT --!>/$about_object/" ./base.html | sed "s/<!-- TITLE --!>/about/" | sed "s/<!-- LINK --!>/$about_link/" > $www_root/about.html

# socials
socials_object=$(escape_sed_replacement '<object type="text/html" data="/pages/socials/index.html"></object>')
socials_link=$(escape_sed_replacement '/pages/socials/index.html')
sed "s/<!-- CONTENT --!>/$socials_object/" ./base.html | sed "s/<!-- TITLE --!>/socials/" | sed "s/<!-- LINK --!>/$socials_link/" > $www_root/socials.html

# sona gallery
sonagallery_object=$(escape_sed_replacement '<object type="text/html" data="/pages/sonagallery/index.html"></object>')
sonagallery_link=$(escape_sed_replacement '/pages/sonagallery/index.html')
sed "s/<!-- CONTENT --!>/$sonagallery_object/" ./base.html | sed "s/<!-- TITLE --!>/sona gallery/" | sed "s/<!-- LINK --!>/$sonagallery_link/" > $www_root/sonagallery.html

find "$www_root" -type d -exec chmod 755 {} \;
find "$www_root" -type f -exec chmod 644 {} \;
