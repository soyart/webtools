#!/usr/bin/env bash
## cleanup.sh cleans up the directories before processing

# Source webtools.conf and source.sh
[[ "$fts_status" != 'ok' ]]\
&& . 'webtools.conf';

# Find and remove 'files to delete' $ftd
findrm() {
	# if no matched files were found, return to the loop
	[[ -z "$ftd" ]]\
		&& printf "%s: No files matching %s\n" "$0" "$k" && return 1\
		|| printf "%s\n" "$ftd";	
	# if matches were found, prompt user for removal
	simyn "${0}: Delete these files?"\
		&& find "$rootdir" -path "./.stversions" -prune -false -o -name "$k" -exec rm -f {} \;

	unset ynsh;
}

## Delete files matching the keywords $cleanup_find
main() {
	# Get lookup path
	read -r -p "$0: Relative path to search (DEFAULT=BLANK=$pwd): " rootdir;
	# File to delete directory 'rootdir' which will contain files to delete 'ftd', defaults to $(pwd)
	[ -z "$rootdir" ]\
		&& rootdir='.';
	
	# cleanup_find is defined in webtools.conf
	# Do NOT double quote the array cleanup_find in the for loop below
	for k in ${CLEANUP_PATTERNS[*]}; do
		# cleanup_excl (defined in webtools.conf) is for exclusion
		# See https://stackoverflow.com/questions/4210042/how-to-exclude-a-directory-in-find-command to understand the line below
		ftd=$(find "$rootdir" -path "$CLEANUP_EXCLUDES" -prune -false -o -name "$k"); # files to delete
		
		findrm;
	done;
}


main;
