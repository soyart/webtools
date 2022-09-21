#!/bin/sh
# Copy HTML files from $srcd to $dest

tarballs="/home/artnoi/web/*.tar.gz";
dest="/var/www/htdocs/";

if [ -w "$dest" ]; then
	for tarball in ${tarballs[@]}; do
		tar xfzv "$tarball" -C "$dest";
	done;
else
	printf "installweb.ksh: User %s cannot write to %s\n" "$USER" "$dest";
fi;
