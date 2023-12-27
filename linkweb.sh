#!/usr/bin/env bash

# Source jq wrapper functions
. init-wt.sh

MODELIVE="live-links"
MODEDRY="dry-run"
MODECLEAN="clean-links"

main() {
	if [ -n $1 ] && [ "$1" != "-"* ]; then
		# Examples:
		# PROG sitename;
		# PROG sitename -n;
		announce "Single-site mode"

		local sitekey="$1";
		local runflag="$2";
		local data=$(get_site_from_file_json "$sitekey");

		[ -z $data ]\
			&& die "no sitekey $sitekey found";

		local sitename=$(get_name_json "$data");
		local link_func="link_one_site";
	else
		# Examples:
		# PROG
		# PROG -n
		# PROG -a;
		# PROG -a -n;
		announce "All sites mode"

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

		link_func="link_many_sites";
		data=$(get_all_sites_json);

	fi

	case $runflag in
		"-n")
			runmode="$MODEDRY"; ;;
		"-c")
			runmode="$MODECLEAN"; ;;
		*)
			runmode="$MODELIVE"; ;;
	esac

	"${link_func}" "$runmode" "$data" "$sitename";
}

link_many_sites() {
	local runmode=$1;
	local sites=$2;

	for site in ${sites[@]}; do
		local sitename=$(get_name_json $site);

		link_one_site "$runmode" "$site" "$sitename"\
			|| die "failed to link $site"
	done;
}

link_one_site() {
	local runmode="$1";
	local sitedata="$2";
	local sitename="$3";

	local links_map=$(access_field_json $sitedata "links");
	local links_sources=$(echo $links_map | jq -c 'keys | .[]');

	wrapped_looplink "$runmode" "$links_map" "$links_sources" "$sitename";
}

wrapped_looplink() {
	local runmode=$1;
	local linksmap=$2;
	local sources=$3;
	local sitename=$4;

	simyn "[$PROG] Run for $sitename ($runmode)?"\
		&& looplink "$linksmap" "$sources" "$runmode";
}

looplink() {
	local site_links="$1";
	local link_sources="$2";
	local runmode="$3";

	for src in ${link_sources[@]}; do
		# These strings contain double quotes
		local pwdir="$(pwd)";
		local dst=$(echo $site_links| jq -c ".$src");

		# Remove double quotes from string literals
		src=$(echo $src | tr -d '"');
		dst=$(echo $dst | tr -d '"');

		# Convert to full, absolute path
		src="$(find $pwdir -wholename $pwdir/$src)";
		dst="$pwdir/$dst";

		if ! [ -r "$src" ]; then
			announce "file $src not readable, skipping";
			continue;
		fi;

		case $runmode in
			"$MODECLEAN")
				rmlink "$dst"; ;;
			"$MODELIVE")
				rmlink "$dst";
				cp -a "$src" "$dst"; ;;
		esac

		announce "$src -> $dst ($runmode)";
	done
}

rmlink() {
	test -L "$1" && rm "$1";
}

main $@;
