#!/usr/bin/env bash
## sendweb.sh - send HTML pages in directories whose names match keyword $sendweb_find to send destination $sendweb_dest

# Source external files and source.sh
[[ "$fts_status" != 'ok' ]]\
&& . 'webtools.conf';

sendweb() {
	dir=$1
	server=$2
	server_scp_path=$3

	simyn "sendweb.sh: Send ${dir} to ${server} at ${server_scp_path}?"\
		&& line\
		&& printf "sendweb.sh: Sending %s to %s at %s\n" "$dir" "$server" "$server_scp_path"\
		&& scp -r "$dir" "$server_scp_path";
}


loop_sendweb() {
	# Inject sendweb_func
	sendweb_func=$1
	for src_dir in ${!WEB_NAMES[@]}; do
		# Extract website distribution directory using src_dir
		webdist="${WEB_DIST[$src_dir]}";
		webname="${WEB_NAMES[$src_dir]}";

		# Search one-level for directories with names matching webdist
		# If there's no dir matching webdist, sendweb.sh exits quietly.
		for server in ${!SENDWEB_DESTS[@]};
		do
			# Extract server SCP path
			server_scp_path="${SENDWEB_DESTS[$server]}";
			"$sendweb_func" "$webdist" "$server" "$server_scp_path";
		done;
		line;
	done;
}

loop_sendweb sendweb;
