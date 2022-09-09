#!/usr/bin/env bash

# Source external files and source.sh
[[ "$fts_status" != 'ok' ]]\
&& . 'webtools.conf';

# Our arrays of script ${script[]}; webtools.sh runs in these array order
typeset -a scripts;
typeset -a ranscripts;
# Delete .DS_Store, .files (to reset ssg), and other annoying files
scripts+=('cleanup.sh');
# Link resources to destination
scripts+=('linkweb.sh');
# Generate HTML files
scripts+=('genhtml.sh');
# run web.sh after new files are generated
scripts+=('sendweb.sh');

# run_ext_scripts is sorced from source.sh
for s in "${scripts[@]}";
do
	# prompt user to run each script
	simyn "$0: Run $s"\
	&& run_ext_scripts "$s"\
	&& ranscripts+="$s ";
	# line() is sourced by source.sh from lb.sh
	line;
done;

printf "$0: %s done\n" "scripts: ${ranscripts[@]}";
