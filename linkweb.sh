#!/usr/bin/env bash
## linkweb.sh - link files for ssg5

# Source webtools.conf and source.sh
[[ "$fts_status" != 'ok' ]]\
&& . 'webtools.conf';

# Markdown directories (array indices/keys)
linksrc() {
	for d in "${!WEB_DIST[@]}";
	do
		# ssg files
		ln -sf "${LINK_SSG_HEADER[$1]}" "$2/_header.html";
		ln -sf "${LINK_SSG_FOOTER[$1]}" "$2/_footer.html";
		
		# Non-ssg files
		# You can uncomment the lines below if you want ssg5 to automatically copy style.css and favicon.ico for you
		ln -sf "${LINK_STYLECSS[$1]}" "$2/style.css";
		ln -sf "${LINK_LOGO[$1]}" "$2/favicon.svg";
		ln -sf "${LINK_LOGO[$1]}" "$2/favicon.ico";
		cp -r "${LINK_FONTS[$1]}" "$2/";
	done;
}

# HTML directories
linkdist() {
	for d in "${!WEB_DIST[@]}";
	do
		ln -sf "${LINK_LOGO[$1]}" "$2/favicon.svg";
		ln -sf "${LINK_LOGO[$1]}" "$2/favicon.ico";
		ln -sf "${LINK_BODYLOGO[$1]}" "$2/toplogo.png";
		ln -sf "${LINK_STYLECSS[$1]}" "$2/style.css";
		ln -sf "${LINK_SCRIPTJS[$1]}" "$2/script.js";
		cp -r "${LINK_FONTS[$1]}" "$2/";
	done;
}

main() {
	for srcdir in ${!WEB_DIST[@]}; do
		# Extract website name and ask user for confirmation
		webname="${WEB_NAMES[$srcdir]}";
		distdir="${WEB_DIST[$srcdir]}";
		simyn "linkweb.sh: link for $webname?"\
			|| continue;
		simyn "${0}: Link source (Markdown) directories?"\
			&& linksrc "$srcdir" "$srcdir";
		simyn "${0}: Link distribution (HTML) directories?"\
			&& linkdist "$srcdir" "$distdir";
	done;
}

main
