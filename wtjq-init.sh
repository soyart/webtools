#!/usr/bin/env bash

# wtjq-init.sh
# This file provides frequently used jq wrappers for wtjq.

MANIFEST="manifest.json"

# Get non-webtools dependencies, e.g. ssg, yn.sh, and lb.sh
. netget.sh;
get_unix;
. bin/yn.sh;
. bin/lb.sh;

# Gets all sites directly from file
get_all_sites_json() {
	echo $(cat $MANIFEST) | jq -c '.sites[]';
}

get_all_servers_json() {
	echo $(cat $MANIFEST) | jq -c '.servers[]';
}

get_cleanup_json() {
	echo $(cat $MANIFEST) | jq -c '.cleanup';
}

get_site_from_file_json() {
	test -z "$1"\
		&& echo "<<missing sitekey>>"\
		&& exit 1;

	sitekey=$1;
	cat manifest.json | jq -c ".sites[] | select(.sitekey == \"$sitekey\")";
}

get_sitekeys_json() {
	if [ -z $1 ]; then
		data=$(cat $MANIFEST);
	else
		data=$1;
	fi

	echo $data | jq -c '.sitekey';
}

get_name_json() {
	test -z $1\
		&& echo "<<missing data to get a name from>>"\
		&& exit 1

	access_field_json $1 'name';
}

access_field_json() {
	test -z "$1"\
		&& test -z $2\
		&& echo "<<missing both data and key>>"\
		&& exit 1

	test -z "$1"\
		&& echo "<<missing data>>"\
		&& exit 1;

	test -z "$2"\
		&& echo "<<missing key>>"\
		&& exit 1;

	data=$1;
	field=$2

	echo $data | jq -c ".${field}"
}

access_field_array_json() {
	test -z "$1"\
		&& test -z $2\
		&& echo "<<missing both data and key>>"\
		&& exit 1

	test -z "$1"\
		&& echo "<<missing data>>"\
		&& exit 1;

	test -z "$2"\
		&& echo "<<missing key>>"\
		&& exit 1;

	data=$1;
	field=$2
	access_field_json "$data" "${field}[]"
}
