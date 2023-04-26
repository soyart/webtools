#!/usr/bin/env bash

# wtutils define helper functions for webtools

# Gets all sites directly from file
get_all_sites_json() {
	echo $MANIFEST | jq -c '.sites[]';
}

get_all_servers_json() {
	echo $MANIFEST | jq -c '.servers[]';
}

get_cleanup_json() {
	echo $MANIFEST | jq -c '.cleanup';
}

get_site_from_file_json() {
	test -z "$1"\
		&& die "<<missing sitekey>>";

	sitekey=$1;
	cat manifest.json | jq -c ".sites[] | select(.sitekey == \"$sitekey\")";
}

get_sitekeys_json() {
	if [ -z $1 ]; then
		data=$(echo $MANIFEST);
	else
		data=$1;
	fi

	echo $data | jq -c '.sitekey';
}

get_name_json() {
	test -z $1\
		&& die "<<missing data to get a name from>>";

	access_field_json $1 'name';
}

access_field_json() {
	test -z "$1"\
		&& test -z $2\
		&& die "<<missing both data and key>>";

	test -z "$1"\
		&& die "<<missing data>>";

	test -z "$2"\
		&& die "<<missing key>>";

	data=$1;
	field=$2

	echo $data | jq -c ".${field}"
}

access_field_array_json() {
	test -z "$1"\
		&& test -z $2\
		&& die "<<missing both data and key>>";

	test -z "$1"\
		&& die "<<missing data>>";

	test -z "$2"\
		&& die "<<missing key>>";

	data=$1;
	field=$2
	access_field_json "$data" "${field}[]"
}
