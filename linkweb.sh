#!/usr/bin/env bash
## linkweb.sh - link files for ssg5

# linkweb.sh has the potential to really nuke your directories,
# so you should first dry-run it with -n flag

main() {
	for srcdir in ${!WEB_DIST[@]}; do
		# Extract website name and ask user for confirmation
		webname="${WEB_NAMES[$srcdir]}";
		distdir="${WEB_DIST[$srcdir]}";

		# Dry-run with -n flag
		runmode="live"
		[[ $1 == "-n" ]]  && runmode="dry";

		simyn "linkweb.sh: link for $webname?"\
			|| continue;

		simyn "${0}: Link source (Markdown) directories?"\
			&& linksrc "$srcdir" "$srcdir" "$runmode";
		simyn "${0}: Link distribution (HTML) directories?"\
			&& linkdist "$srcdir" "$distdir" "$runmode";
	done;
}


# Source webtools.conf and source.sh
[[ "$fts_status" != 'ok' ]]\
&& . 'webtools.conf';

dolink() {
	test -z "$1" && echo "[$0] missing a source file for $2"\
		&& return;
	test -z "$2" && echo "[$0] missing a destination (soft link) for $1"\
		&& return;

	# Find targets
	# TODO: find with tilde expansion does not work yet
	# find ~+ gets expanded to $(pwd)
#	src_dir=$(find ~+ -path ${1});
#	dst_dir=$(find ~+ -path ${2});

	# Find targets
	pwdir="$(pwd)";
	src_dir="$(find $pwdir -wholename $pwdir/$1)";
	dst_dir="$pwdir/$2";

	# $3 is dry-run flag
	test ${3} != "dry"\
		&& test -L "$dst_dir"\
		&& rm "$dst_dir"\
		&& ln -s "$src_dir" "$dst_dir";

	echo "[$0 $3] $src_dir -> $dst_dir";
}

# Markdown directories (array indices/keys)
linksrc() {
	for d in "${!WEB_DIST[@]}";
	do
		# ssg files
		dolink "${LINK_SSG_HEADER[$1]}" "$2/_header.html" $3;
		dolink "${LINK_SSG_FOOTER[$1]}" "$2/_footer.html" $3;
		
		# Non-ssg files
		# You can uncomment the lines below if you want ssg5 to automatically copy style.css and favicon.ico for you
		dolink "${LINK_STYLECSS[$1]}" "$2/style.css" $3;
		dolink "${LINK_LOGO[$1]}" "$2/favicon.svg" $3;
		dolink "${LINK_LOGO[$1]}" "$2/favicon.ico" $3;
		dolink "${LINK_FONTS[$1]}" "$2/fonts" $3;
	done;
}

# HTML directories
linkdist() {
	for d in "${!WEB_DIST[@]}";
	do
		dolink "${LINK_LOGO[$1]}" "$2/favicon.svg" $3;
		dolink "${LINK_LOGO[$1]}" "$2/favicon.ico" $3;
		dolink "${LINK_BODYLOGO[$1]}" "$2/toplogo.png" $3;
		dolink "${LINK_STYLECSS[$1]}" "$2/style.css" $3;
		dolink "${LINK_SCRIPTJS[$1]}" "$2/script.js" $3;
		dolink "${LINK_FONTS[$1]}" "$2/fonts" $3;
	done;
}

main $1;
