#!/usr/bin/env bash
## sendweb_tarball.sh - like sendweb.sh, but use tar to archive the directory before sending via scp.

# Source external files and source.sh
[[ "$fts_status" != 'ok' ]]\
&& . 'webtools.conf'\
&& . sendweb.sh; # sendweb_tarred needs loop_sendweb from sendweb.sh

sendweb_tarball() {
	dir=$1
	server=$2
	server_scp_path=$3

	echo "[$0] will use /tmp for temporary tarball storage";
	simyn "[$0] Send ${dir} to ${server} at ${server_scp_path}?"\
		&& tar -cf "/tmp/${dir}.tar" "${dir}"\
		&& tarball="/tmp/${dir}.tar"\
		&& line\
		&& printf "sendweb.sh: Sending %s to %s\n" "$tarball" "$server"\
		&& scp "$tarball" "$server_scp_path"\
		&& rm ${tarball}\
		&& echo "removed $tarball";
}

# loop_sendweb was defined in sendweb.sh
loop_sendweb sendweb_tarball;
