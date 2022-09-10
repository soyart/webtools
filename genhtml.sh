#!/usr/bin/env bash
## genhtml.sh uses ssg5 to generate static HTML web pages from Markdown files

# Source webtools.sh and source.sh
[[ "$fts_status" != 'ok' ]]\
&& . 'webtools.conf';

if command -v ssg; then
	echo "Using system ssg: $(command -v ssg)";
	ssg_cmd="ssg";
else
	echo "Missing ssg in PATH, calling get_ssg.sh";
	. get_ssg.sh;
	ssg_cmd="bin/ssg";
fi

genhtml() {
	simyn "${0}: [$3] Generate HTML in $2 from $1 using $ssg_cmd"\
		&& mkdir -p $2\
		&& ${ssg_cmd} "$1" "$2" "$3" "$4";
}

loop_genhtml() {
	for srcdir in "${!WEB_DIST[@]}";
	do
		webname="${WEB_NAMES[$srcdir]}";
		distdir="${WEB_DIST[$srcdir]}";
	 	weburl="${WEB_URLS[$srcdir]}";

		printf "\n";
		genhtml "$srcdir" "$distdir" "$webname" "$weburl";
	done;
}

# Generate HTML files
loop_genhtml;
