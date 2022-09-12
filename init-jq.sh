#!/usr/bin/env bash

# This file provides frequently used jq wrappers for wtjq.
MANIFEST="manifest.json"

# Get non-webtools dependencies, e.g. ssg, yn.sh, and lb.sh
. netget.sh;
get_unix;
. bin/yn.sh;
. bin/lb.sh;

get_all_sites_json() {
	if [ -z $1 ]; then
		data=$(cat $MANIFEST);
	else
		data=$1;
	fi

	echo $data | jq -c;
}

access_field_json() {
	test -z "$1"\
		&& test -z $2\
		&& echo "missing both data and key"\
		&& exit 1

	test -z "$1"\
		&& echo "missing data"\
		&& exit 1;

	test -z "$2"\
		&& echo "missing key"\
		&& exit 1;

	data=$1;
	field=$2

	echo $data | jq -c ".${field}"
}

get_site_from_file_json() {
	key=$1;
	access_field_json "$(cat $MANIFEST)" "${key}";
}

get_name_json() {
	test -z $1\
		&& echo "missing data to get a name from"\
		&& exit 1

	access_field_json $1 "name";
}

get_site_keys_json() {
	if [ -z $1 ]; then
		data=$(cat $MANIFEST);
	else
		data=$1;
	fi

	echo $data | jq -c 'keys|.[]';
}
