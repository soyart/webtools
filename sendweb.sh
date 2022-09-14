#!/usr/bin/env bash
# linkweb-jq.sh is a wtjq replacement for linkweb.sh.

PROG=${0#'./'}
MODELIVE="live-send"
MODEDRY="dry-run"

# Source jq wrapper functions
. wtjq-init.sh

main() {
	if [ ! -z $1 ] && [ "$1" != "-"* ]; then
	# PROG sitename;
	# PROG sitename -n;
		sitekey="$1";
		runflag="$2";
		send_func="send_one_site";
		data=$(get_site_from_file_json "${sitekey}");

		[ -z $data ]\
			&& echo "[$PROG] no sitekey $sitekey found"\
			&& exit 1
	else
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
	dist=$(access_field_json "$site" "dist");

	src=$(echo $src | tr -d '"');
	dist=$(echo $dist | tr -d '"');

	send_to_servers "$runmode" "$name" "$dist" "$servers";
}

send_to_servers() {
	runmode="$1";
	name="$2"
	dist="$3";
	servers="$4";

	for server in ${servers[@]}; do
		hostname=$(access_field_json "$server" "hostname");
		scppath=$(access_field_json "$server" "scpPath");
		hostname=$(echo $hostname | tr -d '"');
		scppath=$(echo $scppath | tr -d '"');

		if simyn "Publish $name to $hostname?";
		then
			if simyn "Send $dist as a tarball? ($hostname)";
			then
				sendweb_tarball "$dist" "$hostname" "$scppath";
			else
				simyn "Send $dist as a directory? ($hostname)"\
					&& sendweb "$dist" "$scppath";
			fi

			echo "$dist -> $scppath";
		fi
	done;
}

sendweb() {
	dist="$1";
	fullpath="$3";

	scp -r "$1" "$2";
}

sendweb_tarball() {
	dist="$1";
	hostname="$2";
	fullpath="$3";

	tarball="/tmp/$(basename $dist).tar.gz";
	tar -czvf "$tarball" "$dist";
	sendweb "$tarball" "$fullpath";

	simyn "Remove tarball $tarball ?"\
		&& rm -v $tarball;
}

main $1 $2;
