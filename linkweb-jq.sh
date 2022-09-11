#!/usr/bin/env bash
# linkweb-jq.sh is a wtjq replacement for linkweb.sh.

PROG=${0#'./'}
MODELIVE="live-links"
MODEDRY="dry-run"
MODECLEAN="clean-links"

# Source jq wrapper functions
. init-jq.sh

main() {
	if [[ $1 == "-*" ]]; then
		echo "[$PROG] all sites mode"
		runflag=$1;
		link_func="link_many_sites";
		data=$(get_all_sites_json);
	elif [[ $2 != "-*" ]]; then
		sitekey="$1";
		runflag="$2";
		link_func="link_one_site";
		data=$(get_site_from_file_json "${sitekey}");
	fi

	case $runflag in
		"-n")
			runmode="$MODEDRY"; ;;
		"-c")
			runmode="$MODECLEAN"; ;;
		*)
			runmode="$MODELIVE"; ;;
	esac

	"${link_func}" "$runmode" "$data" "$sitekey";
}

link_many_sites() {
	runmode=$1;
	data_json=$2;
	sites=$(echo $data_json | jq -c 'keys');

	for site in ${sites[@]}; do
		sitedata=$(access_field_json $data_json $site);
		sitekey=$(get_name_json $sitedata)
		link_one_site "$runmode" $sitedata $sitekey
	done;
}

link_one_site() {
	runmode="$1";
	sitedata="$2";
	sitekey="$3";
	
	site_links=$(echo $sitedata | jq -c '.links');
	link_sources=$(echo $site_links | jq -c 'keys | .[]');

	simyn "[$PROG] Run for $sitekey ($runmode)?"\
		&& looplink "$site_links" "$link_sources" "$runmode";
}

rmlink() {
	test -L "$1" && rm "$1";
}

looplink() {
	site_links="$1";
	link_sources="$2";
	runmode="$3";

	for src in ${link_sources[@]}; do
		# These strings contain double quotes
		dst=$(echo $site_links| jq -c ".$src");

		# Remove double quotes from string literals
		src=$(echo $src | tr -d '"');
		dst=$(echo $dst | tr -d '"');

		# Convert to full, absolute path
		pwdir="$(pwd)";
		src="$(find $pwdir -wholename $pwdir/$src)";
		dst="$pwdir/$dst";

		if ! [ -r "$src" ]; then
			echo "file $src not readable, skipping";
			continue;
		fi;

		case $runmode in
			"$MODECLEAN")
				rmlink "$dst"; ;;
			"$MODELIVE")
				rmlink "$dst";
				ln -s "$src" "$dst"; ;;
		esac
		echo "[$PROG] $src -> $dst ($runmode)";
	done
}

main $1 $2;
