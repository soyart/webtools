#!/usr/bin/env bash
# linkweb-jq.sh is a wtjq replacement for linkweb.sh.

PROG=${0#'./'}
MODELIVE="live-send"
MODEDRY="dry-run"

# Source jq wrapper functions
. init-jq.sh

main() {
	if [ -z $2 ] || [[ $1 == "-*" ]]; then
	# PROG
	# PROG -n
	# PROG -a;
	# PROG -a -n;
		echo "[$PROG] all sites mode"
		if [ -z $1 ]; then
		# PROG
			runflag="";
		elif [[ $1 == "-a" ]]; then
		# PROG -a;
		# PROG -a -n;
			runflag="$2"
		else
		# PROG -n
			runflag="$1"
		fi

		data=$(get_all_sites_json);
		send_func="send_many_sites";
	else
	# PROG sitename;
	# PROG sitename -n;
		sitekey="$1";
		runflag="$2";
		send_func="send_one_site";
		data=$(get_site_from_file_json "${sitekey}");

		[ -z $data ]\
			&& echo "[$PROG] no sitekey $sitekey found"\
			&& exit 1
	fi

	case $runflag in
		"-n")
			runmode="$MODEDRY"; ;;
		*)
			runmode="$MODELIVE"; ;;
	esac

	servers=$(get_all_servers_json)

	"${send_func}" "$runmode" "$data" "$servers";
}

send_many_sites() {
	runmode="$1";
	sites="$2";
	servers="$3";

	for site in ${sites[@]}; do
		send_one_site "$runmode" "$site" "$servers";
	done;
}

send_one_site() {
	runmode="$1";
	site="$2";
	servers="$3";

	name=$(get_name_json "$site");
	url=$(access_field_json "$site" "url");
	dist=$(access_field_json "$site" "dist");

	src=$(echo $src | tr -d '"');
	dist=$(echo $dist | tr -d '"');

	if [[ $runmode == $MODELIVE ]]; then
		simyn "Send (publish) $name?"\
		&& send_to_servers "$runmode" "$dist" "$servers";
	fi
}

send_to_servers() {
	runmode="$1";
	dist="$2";
	servers="$3";

	for server in ${servers}; do
		hostname=$(access_field_json "$server" "hostname");
		scppath=$(access_field_json "$server" "scpPath");
		hostname=$(echo $hostname | tr -d '"');
		scppath=$(echo $scppath | tr -d '"');
		fullpath="$hostname@$scppath"

		simyn "Send $dist to $hostname?"\
			&& scp -r "$dist" "$fullpath"\
			|| continue;

		echo "$dist -> $fullpath"
	done;
}

main $1 $2;
