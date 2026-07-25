#!/usr/bin/env sh

www_root=./htdocs

escape_sed_replacement()
{
	printf '%s\n' "$1" | sed -e 's/[\/&]/\\&/g'
}

generate_object()
{
	echo "<object type=\"text/html\" data=\"$1\"></object>"
}

generate_page()
{
	content=$(escape_sed_replacement "$1")
	link=$(escape_sed_replacement "$2")
	title=$3

	sed "s/<!-- CONTENT --!>/$content/" ./base.html | \
	sed "s/<!-- LINK --!>/$link/" | \
	sed "s/<!-- TITLE --!>/$title/"
}

# add static files
if [ -d "$www_root" ]; then
	rm -rf $www_root/*a
else
	mkdir $www_root
fi
cp -r ./static/* $www_root/
cd $www_root

# PAGES

for dir in ./pages/*/; do
	page=$(basename $dir)
	if [ -f $dir/index.html ]; then
		generate_page "$(generate_object "/pages/$page/index.html")" "/pages/$page/index.html" "$page" > $page.html
	fi
done


find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
