#!/usr/bin/env bash

flag_require_import="require_import"

# Downloads and sources required shell scripts
download_resource() {
	local download_url="$1";
	local download_dir="$2";
	local download_file="$download_dir/$3";
	local action_flags="$4"

	announce "Downloading from $download_url to $download_file";

	local downloaded=$(curl "$download_url");

	announce "Resource from $download_url downloaded successfully";

	printf "Previewing content in memory:\n\n--- START %s ---\n\n%s\n\n--- END %s ---\n\n" "$download_url" "$downloaded" "$download_url";

	if [ -z $action_flags ]; then
		simyn "Write out to file $download_file?"\
			&& mkdir -p $download_dir\
			&& announce "$downloaded" > "$download_file";

	else
			announce "WARN: resource from URL $download_url is a required import, writing out to file $download_file now"
			mkdir -p $download_dir\
				&& announce "$downloaded" > "$download_file";
	fi;

	chmod u+x $download_file;
}

# Checks if target_path exists, if not, download and maybe source
check_download_source() {
	local target_dir="$1";
	local target_file="$2";
	local download_url="$3";
	local action_flags="$4";
	local target_path="$target_dir/$target_file"

	announce "Checking $target_path"

	if [ ! -x "$target_path" ]; then
		announce "Missing $target_path"\
			&& download_resource "$download_url" "$target_dir" "$target_file" "$action_flags"\
			|| die "Failed to download resource $download_url to $target_path";
	fi;

	if [ "$action_flags" == "$flag_require_import" ]; then
			announce "Sourcing downloaded resource from $download_url at $target_path"\
				&& source $target_path\
				|| die "Failed to source $target_path";
	fi

	announce "$target_path: ok"
}

# Download using ftp or curl to bin/ssg
# Since ssg is not from me, you may need to check its content first.
get_ssg() {
	check_download_source\
		"bin"\
		"ssg"\
		"https://rgz.ee/bin/ssg";
}

get_lb() {
	check_download_source\
		"bin"\
		"lb.sh"\
		"https://gitlab.com/artnoi/unix/-/raw/master/sh-tools/bin/lb.sh";
}

get_yn() {
	check_download_source\
		"bin"\
		"yn.sh"\
		"https://gitlab.com/artnoi/unix/-/raw/master/sh-tools/bin/yn.sh"\
		"$flag_require_import";
}

get_shtools() {
	get_yn;
	get_lb;
}
