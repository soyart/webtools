Nov 20, [2023](/blog/2023/)

# artnoi.com is now using GitHub Pages

As much as I prefer self-hosting the website,
my current responsibilities have been limiting
my free time for maintaining the website.

While I've setup an old-school CI/CD pipelines
using shell scripts on my OpenBSD box to sync
website files from Git repo periodically,
I'm tired of worrying about security.

## But you said OpenBSD was cool

The only reason I chose OpenBSD as previous webserver
was because of security concerns. If I, a noob,
have to host a public website on the internet,
I'd rather prefer the most secure OS by defaults
as my webserver box.

But lately, I've been thinking, if I could
delegate this public-facing component with someone else's,
then I wouldn't have to worry about being hacked!

## How

I just simply added a GitHub Actions file in [webtools](https://github.com/soyart/webtools),
and this will build and deploy my websites to GitHub Pages
with my custom domain name.

I push the new articles markdowns and the website
gets updated like before, but without the risks of having my
personal servers attacked.

Laziness wins I guess.
