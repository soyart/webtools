# webtools
webtools is a wrapper for [ssg](https://rgz.ee/ssg.html). It's a set of shell scripts that makes maintaining and publishing multiple simple static websites with ssg easier by writing a manifest config file `manifest.json`. This repository serves as [an example project](#longterm).

> As of now, webtools require [`unix/sh-tools`](https://gitlab.com/artnoi/unix) for some of its features e.g. yes-no prompt. If it is not found on your host, `netget.sh` will download missing dependencies from Github.

## Usage
webtools is written to reflect my needs - managing multiple simple static sites with shared resources. The convention for webtools is that, each website should live in its own root level directory. Provided in this example are `./johndoes.com` and `./artnoi.com`. Anything exclusive to that website should live there.

Usually, each website has 3 subdirectories under their root:

1. `src` holds your website as a tree of Markdown files

2. `dist` is where your ssg output (HTML file tree) live

3. `resc` is where you store this website exclusive resources.

The usual workflow for the 1st run

1. You prepare your source directory and resources

2. You update your site manifest(s) in `manifest.json` to reflect your needs

3. You run a webtools command to perform some task

4. You push the website documents to webserver

After the 1st run, you can now just do tasks 3-4 and your websites will get updated real quick.

## Client-side components
These scripts are run on the user local machine when they are writing or publishing.

### `cleanup.sh`

    $ cleanup.sh [ROOT_DIR];

`cleanup.sh` finds and cleans files whose names match some configured patterns. The default values include `.DS_Store` and `.files` file createdby `ssg`, as well as `*sync-conflict*` for Syncthing users. This is usually runs when `.files` becomes outdated or corrupted.

### `genhtml.sh`
As the name suggests, this script loops over available websites, and use `ssg` to convert Markdown files into structured website tree of HTML files.

    $ genhtml.sh [SITEKEY] [-n];

### `linkweb.sh`
This script loops over available configured websites to create symbolic links as configured. Useful when you're managing expensive resources.

    $ linkweb.sh [SITEKEY] [-n | -c];

### `sendweb.sh`
This script loops over available configured websites and tries to send the target directories to remote locations

    $ sendweb.sh [SITEKEY] [-n];

## Server-side components
These scripts are run on the remote server, usually when the new files were just recently pushed. In the future, `sendweb.sh` maybe refactored to be able to specify these scripts to run on the server after pushing finished. Most if not all of these server-side scripts are in OpenBSD Korn Shell, which do not support associative arrays.

### `installweb.ksh`
A Korn Shell script for copying website directory to webserver root (or any other) locations.

### `installweb_tarred.ksh`
If `installweb.ksh` is meant to be for copying files sent by `sendweb.sh`, then `installweb_tarred.ksh` is jus like that, but for the tarball sent by `sendweb_tarred.sh`.

## Example: a new website from scratch
### Using `genhtml.sh`
In this stage, we'll init and populate an `index.md` for our website's `index.html`, and see if `genhtml.sh` can correctly output it yo the correct location.

Recall that a website should have its own root directory and in that root we need a `src`, a `dist`, and a `resc`? Well then, let's create those directories:

    $ mkdir -p example.com/{src,dist,resc};

And start populating your `src` with something, e.g.

    $ echo "# Hello, world!" > example.com/src/index.md;

And copy some good `ssg` header and footer files, we'll assume that those files are in `~/.ssg`:

    $ cp ~/.ssg/{_header.html,_footer.html} example.com/src/;

Now, update `webtools.conf` to reflect your website state. Add your website info in `${WEB_DIST}`, `${WEB_URLS}`, `${WEB_NAMES}`. Because `genhtml.sh` only uses the mentioned variables, we can try using it right away after these 3 variables has been updated:

   $ ./genhtml.sh;
   $ find example.com/dist -name "index.html" && echo "webtools ok";

If the command above went well, then `genhtml.sh` and the 3 variables work now.

### Using `cleanhtml.sh`
`ssg` will not update the HTML files if the Markdown versions were not changed, i.e. `ssg` will only create a new HTML for an existing Markdown files if the Markdown checksum changed.

This means that, if you want to change `_header.html` and you want that change reflected in the `dist` folder, `ssg` will not proceed and your HTML files will stay the same with same header. Try this one for yourself:

    $ ./genhtml.sh; # New HTML files created
	$ ./genhtml.sh; # No HTML files created!

The second call to `genhtml.sh` will never yield anything. This is because, when the first call is done to `genhtml.sh`, the hash table in `.files` has been updated with the latest hash of the Markdowns. When the second call starts, `ssg` still sees that `.files` had not changed, and so it exits without doing anything.

To make `ssg` create our website again, we must remove `.files`. We can do that manually, but it gets tiresome after a few websites. So that you do is you use `cleanup.sh` to take care of these deletetions for you, since string `.files` is already in the manifest (`cleanup.toRemove` array).

Try doing just that by executing `cleanup.sh`:

    $ ./cleanup.sh;
	$ ./genhtml.sh;

You should see `example.com/dist/.files` showing up in your delete prompt. After you deleted that file, `ssg` should work again and this time `genhtml.sh` will create the new files with new headers, even if their Markdown content stayed the same.

Your website should pop up in the prompt, and a new `index.html` should be available in `example.com/dist`

### Using `sendweb.sh`
Now that you can create new HTML files at will, it's time we push our documents to the webserver. To do that, let's first assume that on our local machine, we have a SSH Host `myserverlol` defined in `~/.ssh/config` with user `admin`, and we want to push our documents to `$ADMIN_HOMEDIR/dropbox/websites`, which is writable by user `admin`.

To do this, add the server object to `servers` arrays of the manifest files:

		{
			"hostname": "myserverlol",
			"scpPath": "admin@myserverlol@:~/dropbox/websites"
		}

Now, try executing `sendweb.sh`. It should give you a prompt asking if you really want to send the directory.

### Using `linkweb.sh` to manage content and resources in the long term

> I recommend that you use `tree` to inspect the directory changes

As you can see, webtools is pretty straightforward. You setup a source directory, and ssg replicates its Markdown content tree are into distribution tree, with the same scheme, but in HTML instead.

`linkweb.sh` allows webtools users to put shared resources anywhere on their machine, and links it back to the `src` or `dist` directory for optimum storage and maintenance.

> `linkweb.sh` does this by reading the manifest. Each website will have field `links` which is map of source file to the link destination.

For the source directory, you might want to link ssg `_header.html`/`_footer.html`, and for the distribution directory, you might wanna link things like style cheat or media e.g. images.

> Users of `linkweb.sh` should already know where they want each file to go in and why

And now, run `linkweb.sh`:

    $ ./linkweb.sh;

And now, check your link destinations. You should see all those soft links:

	$ tree example.com johndoes.com;

## <a name="longterm"></a>Long-term usage

> See branch [`artnoi.com`](https://github.com/artnoi43/webtools/tree/artnoi.com) if you're not sure what to do

As explained, this repo is meant to be the reference code base for webtools from today onwards. I will no longer be helping with diverged webtools code. So, to use this repo directly to develop your website, you just need to

1. Clone this repository, and `unix/sh-tools`

Or you can fork it to your own repo and start working from there

    $ git clone https://gitlab.com/artnoi/unix;
	$ cd unix && ./install.sh;
	$ cd ..;
	$
    $ git clone https://github.com/artnoi43/webtools;
	$ cd webtools;

2. Play and test

The main branch comes with `johndoe.com` example websites (provided in the main branch). Try using webtools to manipulate `johndoe.com` first.

    $ ./linkweb.sh
    $ ./genhtml.sh
    $ tree johndoe.com

3. Fork your branch

After you understand how it all works, now fork a new branch for your website, e.g. `ramaxisgay.kuy`

    $ git checkout -b ramaxisgay.kuy;
    $ mkdir -p ramaxisgay.kuy/{src,dist,resc};
    $ echo "I'm an incel from an incest, i.e. full of bad genes from the Thai royal family" > ramaxisgay.kuy/src/index.md;

4. Try webtools on your own websites

Try generating HTML documents and sending them to the server

    $ ./linkweb.sh;
    $ ./genhtml.sh;
	$
	$ # See results
	$ tree ramaxisgay.kuy
    $ less ramaxisgay.kuy/dist/index.html; # OK
	$
	$ # Try sending to server and see result
	$ ./sendweb.sh;
	$ curl ramaxisgay.kuy;

5. If all works and you can push to your server, then you're all set. When there's a new change in the master branch, you can just pull it and merge to your branch. The only culprits for conflicts will be `manifest.json`, which is quite easy to resolve.

It has been my web publishing environment for over a year, and it's pretty simple to setup and use continously.

Before creating this repo, webtools has always been bundled with `sh-tools`, and the code in the repo is different than the one I usually used. And because I always showed it to my friends, many people use it, but with their own modifications.

Usually people start by mirroring my setup, and then they make more customizations, both to the project tree and in the webtools code. Over time, these scattered webtools become cluttered and a mess to deal with, and both the users and I are lost. So I made my mind to use this repository as the upstream code, where the reference webtools code is hosted.

From this repo, my friends or you can clone this repository, create a fork, and start building your shitty static websites in the branches. When webtools or ssg is updated, you can just pull the changes and merge to your branch.

webtools is composed of many shell scripts that read from the same configuration `manifest.json`. Each script is a standalone script that works well when chained together. Here are webtools components.
