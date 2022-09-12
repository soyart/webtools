#!/usr/bin/env bash
. wtjq-init.sh;

cleanup=$(get_cleanup_json)
to_removes=$(access_field_array_json $cleanup "toRemove")

if [ -z "$1" ]; then
	read -r -p "$0: Relative path to search (DEFAULT=BLANK=$pwd): " rootdir;
else
	rootdir=$1
fi

	# File to delete directory 'rootdir' which will contain files to delete 'ftd', defaults to $(pwd)
[ -z "$rootdir" ]\
		&& rootdir='.';

for to_remove in ${to_removes}; do
	to_remove=$(echo "$to_remove" | tr -d '"');
	results=$(find "$rootdir" -name "$to_remove");

	for result in ${results[@]}; do
		simyn "Remove $result?"\
			&& rm -v $result;
	done;
done;
