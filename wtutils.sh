#!/usr/bin/env bash

# wtutils define helper functions for webtools

# Gets all sites directly from file
get_all_sites_json() {
	jq -c '.sites[]' <<<"$MANIFEST"
}

get_all_servers_json() {
	jq -c '.servers[]' <<<"$MANIFEST"
}

get_cleanup_json() {
	jq -c '.cleanup' <<<"$MANIFEST"
}

get_site_from_file_json() {
	test -z "$1" &&
		die "<<missing sitekey>>"

	sitekey=$1
	jq -c ".sites[] | select(.sitekey == \"$sitekey\")" <manifest.json
}

get_sitekeys_json() {
	if [ -z $1 ]; then
		data="$MANIFEST"
	else
		data="$1"
	fi

	jq -c '.sitekey' <<<"$data"
}

get_name_json() {
	test -z "$1" &&
		die "<<missing data to get a name from>>"

	access_field_json "$1" 'name'
}

access_field_json() {
	test -z "$1" &&
		test -z "$2" &&
		die "<<missing both data and key>>"

	test -z "$1" &&
		die "<<missing data>>"

	test -z "$2" &&
		die "<<missing key>>"

	data=$1
	field=$2

	jq -c ".${field}" <<<"$data"
}

access_field_array_json() {
	test -z "$1" &&
		test -z "$2" &&
		die "<<missing both data and key>>"

	test -z "$1" &&
		die "<<missing data>>"

	test -z "$2" &&
		die "<<missing key>>"

	data=$1
	field=$2
	access_field_json "$data" "${field}[]"
}
