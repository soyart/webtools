#!/usr/bin/env bash
# https://rgz.ee/ssg.html

# Download using ftp or curl to bin/ssg

URL="https://rgz.ee/bin/ssg";
if [ ! -x bin/ssg ]; then
	echo "missing bin/ssg";
	echo "get_ssg.sh: Downloading ssg from rgz.ee/bin";

	command -v ftp && ftp -Vo bin/ssg "$URL"\
		|| command -v curl && curl $URL > 'bin/ssg';
	chmod u+x bin/ssg;
fi;

echo "ssg downloaded to bin/ssg, please copy it to your one of your PATH";
echo "Your PATH: $PATH";
