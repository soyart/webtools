#!/usr/bin/env bash

# TODO: refactor

# Download using ftp or curl to bin/ssg
# Since ssg is not from me, you may need to check its content first.
get_ssg() {
	if [ ! -x bin/ssg ]; then
		ssg_url="https://rgz.ee/bin/ssg";
		ssg_tmp="/tmp/ssg_webtools_tmp.sh";
		ssg_dst="bin/ssg";

		echo "missing bin/ssg";
		echo "";
		echo "Getting preview";

		curl "$ssg_url" > "$ssg_tmp"\
		&& cat  "$ssg_tmp"\
		&& simyn "Install this version of ssg?"\
		&& mv $ssg_tmp "$ssg_dst"\
		&& chmod +x "$ssg_dst"\
		&& echo "ssg download from $ssg_url to ./$ssg_dst";
	else
		echo "bin/ssg: ok"
	fi
}

downloader() {
	URL=$1;
	save_name="$2/$3"
	echo "downloading from $URL to $save_name";

	mkdir -p $2;
	command -v ftp && ftp -Vo "$save_name" "$URL"\
		|| command -v curl && curl $URL > "$save_name";

	chmod u+x $save_name;
}

get_shtools() {
	target_dir="$1";
	target_file="$2";
	download_url="$3";

	if [ ! -x "$target" ]; then
		echo "missing $target"\
		&& echo "downloading $target from $download_url"\
		&& downloader "$download_url" "$target_dir" "$target_file"\
		&& echo "$target_file downloaded to $target_dir from $download_url"
	else
		echo "$target_dir/$target_file: ok"
	fi
}

get_lb() {
	get_shtools "bin" "lb.sh"\
		"https://gitlab.com/artnoi/unix/-/raw/main/sh-tools/bin/lb.sh";
}

get_yn() {
	get_shtools "bin" "yn.sh"\
		"https://gitlab.com/artnoi/unix/-/raw/main/sh-tools/bin/yn.sh";
}

get_unix() {
	get_lb
	get_yn
}
