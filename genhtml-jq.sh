#!/usr/bin/env bash
# linkweb-jq.sh is a wtjq replacement for linkweb.sh.

PROG=${0#'./'}
MODELIVE="live-gen"
MODEDRY="dry-run"

# Source jq wrapper functions
. init-jq.sh

# Test if we have ssg installed
if command -v ssg; then
	ssg_cmd="ssg";
else
	get_ssg;
	ssg_cmd="bin/ssg";
fi

main() {
	if [[ $1 == "-*" ]]; then
		echo "[$PROG] all sites mode"
		runflag=$1;
		gen_func="gen_many_sites";
		data=$(get_all_sites_json);
	
	elif [[ $2 != "-*" ]]; then
		sitekey="$1";
		runflag="$2";
		gen_func="gen_one_site";
		data=$(get_site_from_file_json "${sitekey}");
	fi

	case $runflag in
		"-n")
			runmode="$MODEDRY"; ;;
		*)
			runmode="$MODELIVE"; ;;
	esac

	"${gen_func}" "$runmode" "$data" "$sitekey";
}

gen_many_sites() {
	runmode=$1;
	data_json=$2;
	sites=$(echo $data_json | jq -c 'keys');

	for site in ${sites[@]}; do
		sitedata=$(access_field_json $data_json $site);
		sitekey=$(get_name_json $sitedata)
		link_one_site "$runmode" $sitedata $sitekey
	done;
}

gen_one_site() {
	runmode="$1";
	sitedata="$2";
	sitekey="$3";

	src=$(access_field_json $sitedata "src");
	dist=$(access_field_json $sitedata "dist");
	name=$(get_name_json $sitedata);
	url=$(access_field_json $sitedata "url");

	src=$(echo $src | tr -d '"');
	dist=$(echo $dist | tr -d '"');

	test $runmode == $MODELIVE\
		&& "$ssg_cmd" "$src" "$dist" "$name" "$url"\
		|| continue;

	echo "[$PROG] Site $sitekey ($name $url)"
	echo "[$PROG] $src -> $dist"
}

main $1 $2;
