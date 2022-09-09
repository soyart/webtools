#!/usr/bin/env bash
## sendweb_tarred.sh - like sendweb.sh, but use tar to archive the directory before sending via scp.

# Source external files and source.sh
[[ "$fts_status" != 'ok' ]]\
&& . 'webtools.conf';

sendweb_tarred() {
	dir=$1
	server=$2
	server_scp_path=$3
	
	simyn "sendweb.sh: Send ${dir} to ${server} at ${server_scp_path}?"\
		&& tar -cf "/tmp/${dir}.tar" "${dir}"\
		&& tarred="/tmp/${dir}.tar"\
		&& line\
		&& printf "sendweb.sh: Sending %s to %s\n" "$tarred" "$server"\
		&& scp "$tarred" "$server_scp_path"\
		&& rm ${tarred};
}

# loop_sendweb was defined in sendweb.sh
loop_sendweb sendweb_tarred;
