#!/usr/bin/env bash

# Source jq wrapper functions
. init-wt.sh

MODELIVE="live-send"
MODEDRY="dry-run"

main() {
	if [ ! -z $1 ] && [ "$1" != "-"* ]; then
	# PROG sitename;
	# PROG sitename -n;
		local sitekey="$1";
		local runflag="$2";
		local send_func="send_one_site";
		local data=$(get_site_from_file_json "${sitekey}");

		[ -z $data ]\
			&& die "[$PROG] no sitekey $sitekey found";
	else
	# PROG
	# PROG -n
	# PROG -a;
	# PROG -a -n;
		announce "all sites mode"
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

	local servers=$(get_all_servers_json)

	"${send_func}" "$runmode" "$data" "$servers";
}

send_many_sites() {
	local runmode="$1";
	local sites="$2";
	local servers="$3";

	for site in ${sites[@]}; do
		send_one_site "$runmode" "$site" "$servers";
	done;
}

send_one_site() {
	local runmode="$1";
	local site="$2";
	local servers="$3";

	local name=$(get_name_json "$site");
	local dist=$(access_field_json "$site" "dist");
	local src=$(echo $src | tr -d '"');

	dist=$(echo $dist | tr -d '"');

	simyn "Publish $name?"\
		&& send_to_servers "$runmode" "$name" "$dist" "$servers";
}

send_to_servers() {
	local runmode="$1";
	local name="$2"
	local dist="$3";
	local servers="$4";

	for server in ${servers[@]}; do
		local hostname=$(access_field_json "$server" "hostname");
		local scppath=$(access_field_json "$server" "scpPath");
		local hostname=$(echo $hostname | tr -d '"');
		local scppath=$(echo $scppath | tr -d '"');

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
	local dist="$1";
	local fullpath="$3";

	scp -r "$1" "$2";
}

sendweb_tarball() {
	local dist="$1";
	local hostname="$2";
	local fullpath="$3";
	local tarball="/tmp/$(basename $dist).tar.gz";

	tar --dereference -czvf "$tarball" "$dist";
	sendweb "$tarball" "$fullpath";

	simyn "Remove tarball $tarball ?"\
		&& rm -v $tarball;
}

main $@;
