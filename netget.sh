#!/usr/bin/env bash

# TODO: refactor

downloader() {
	URL=$1;
	save_name="$2/$3"
	echo "downloading from $URL to $save_name";

	mkdir -p $2;
	command -v ftp && ftp -Vo "$save_name" "$URL"\
		|| command -v curl && curl $URL > "$save_name";
}

# Download using ftp or curl to bin/ssg
get_ssg() {
	test ! -x bin/ssg\
		&& echo "missing bin/ssg"\
		&& echo "get_ssg.sh: Downloading ssg from rgz.ee/bin"\
		&& downloader "https://rgz.ee/bin/ssg" "bin" "ssg"\
		&& chmod u+x bin/ssg\
		&& echo "ssg downloaded to bin/ssg, please copy it to your one of your PATH"\
		&& echo "Your PATH: $PATH";
}
get_lb() {
	test ! -r bin/lb.sh\
		&& echo "missing bin/lb.sh"\
		&& echo "downloading lb.sh from gitlab.com/artnoi/unix"\
		&& downloader "https://gitlab.com/artnoi/unix/-/raw/main/sh-tools/bin/lb.sh" "bin" "lb.sh"\
		&& echo "lb.sh downloaded to bin"
}

get_yn() {
	test ! -r bin/yn.sh\
		&& echo "missing bin/yn.sh"\
		&& echo "downloading yn.sh from gitlab.com/artnoi/unix"\
		&& downloader "https://gitlab.com/artnoi/unix/-/raw/main/sh-tools/bin/yn.sh" "bin" "yn.sh"\
		&& echo "yn.sh downloaded to bin"
}

get_unix() {
	get_lb
	get_yn
}

# TODO: better dependency manifest
#typeset -A DEPENDENCIES
#DEPENDENCIES['ssg']="https://rgz.ee/bin/ssg";
#DEPENDENCIES['source.sh']="https://gitlab.com/artnoi/unix/-/raw/main/sh-tools/bin/source.sh";
#DEPENDENCIES['yn.sh']="https://gitlab.com/artnoi/unix/-/raw/main/sh-tools/bin/yn.sh";
#DEPENDENCIES['lb.sh']="https://gitlab.com/artnoi/unix/-/raw/main/sh-tools/bin/lb.sh";
