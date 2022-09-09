#!/bin/ksh
# Copy HTML files from $srcd to $dest

srcd="/home/artnoi/web";
dest="/var/www/htdocs/";

if [[ ! -d $dest ]]; then
    printf "%s is not a directory" "$dest";
fi;

if [[ -w $dest ]]; then
	for html in $srcd/html-*;
		do cp -r $html $dest/ && printf "%s copied\n" "$html";
	done;
else
	printf "installweb.ksh: User %s cannot write to %s\n" "$USER" "$dest";
fi;
