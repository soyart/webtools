#!/usr/bin/env bash

# TODO: refactor

downloader() {
	URL=$1;
	save_name="$2/$3"
	echo "downloading from $URL to $save_name";

	mkdir -p $2;
	command -v ftp && ftp -Vo "$save_name" "$URL"\
		|| command -v curl && curl $URL > "$save_name";

	chmod u+x $save_name;
}

# Download using ftp or curl to bin/ssg
get_ssg() {
	if [ ! -x bin/ssg ]; then
		echo "missing bin/ssg"\
		&& echo "get_ssg.sh: Downloading ssg from rgz.ee/bin"\
		&& downloader "https://rgz.ee/bin/ssg" "bin" "ssg"\
		&& echo "ssg downloaded to bin/ssg, please copy it to your one of your PATH"\
		&& echo "Your PATH: $PATH";
	else
		echo "bin/ssg: ok"
	fi
}
get_lb() {
	if [ ! -x bin/lb.sh ]; then
		echo "missing bin/lb.sh"\
		&& echo "downloading lb.sh from gitlab.com/artnoi/unix"\
		&& downloader "https://gitlab.com/artnoi/unix/-/raw/main/sh-tools/bin/lb.sh" "bin" "lb.sh"\
		&& echo "lb.sh downloaded to bin"
	else
		echo "bin/lb.sh: ok"
	fi
}

get_yn() {
	if [ ! -x bin/yn.sh ]; then
		echo "missing bin/yn.sh"\
		&& echo "downloading yn.sh from gitlab.com/artnoi/unix"\
		&& downloader "https://gitlab.com/artnoi/unix/-/raw/main/sh-tools/bin/yn.sh" "bin" "yn.sh"\
		&& echo "yn.sh downloaded to bin"
	else
		echo "bin/yn.sh: ok"
	fi
}

get_unix() {
	get_lb
	get_yn
}
