# webtools

webtools is a wrapper for [ssg](https://rgz.ee/ssg.html).

It's a set of shell scripts that makes maintaining and publishing multiple simple
static websites with ssg easier by writing a manifest config file [`manifest.json`](/manifest.json).

> As of now, webtools require [`unix/sh-tools`](https://gitlab.com/artnoi/unix)
> for some of its features e.g. yes-no prompt. If it is not found on your host,
> [`netget.sh`](/netget.sh) will download missing dependencies from Github.

## Usage

webtools is written to reflect my needs - managing multiple simple static sites
with shared resources. The convention for webtools is that, each website should live
in its own root level directory. Provided in this example are `./johndoes.com` and
`./artnoi.com`. Anything exclusive to that website should live there.

Each _website_ has 3 subdirectories under their root:

1. `src` holds your website as a tree of Markdown files

2. `dist` is where your ssg output (HTML file tree) live

3. `resc` is where you store this website exclusive resources.

The usual workflow for the 1st run

1. You prepare your source directory and resources

2. You update your site manifest(s) in `manifest.json` to reflect your needs

3. You run a webtools command to perform some task

4. You push the website documents to webserver

After the 1st run, you can now just do tasks 3-4 and your websites will get updated.

## Client-side components

These scripts are run on the user local machine when they are writing or publishing.
Most of them have `-n` flag for doing dry runs.

### `cleanup.sh`

```bash
cleanup.sh [ROOT_DIR];
```

Finds and cleans files according to the manifest.
The default values include `.DS_Store` and `.files` file createdby `ssg`,
as well as `*sync-conflict*` for Syncthing users. This is usually runs when
`.files` becomes outdated or corrupted.

### `genhtml.sh`

Loops over available websites in the manifest, and use `ssg`
to convert Markdown files into structured website tree of HTML files.

```bash
genhtml.sh [SITEKEY] [-n];
```

### `linkweb.sh`

Loops over available websites in the manifest to create symbolic links
as configured. Useful when you're managing expensive resources.

```bash
linkweb.sh [SITEKEY] [-n | -c];
```

### `sendweb.sh`

Loops over available websites in the manifest and tries to send the
target directories to remote locations

```bash
sendweb.sh [SITEKEY] [-n];
```

## Example: a new website from scratch

### Using `genhtml.sh`

In this stage, we'll init and populate the directories with`index.md`
for our website's `/index.html`, and see if `genhtml.sh` can correctly output
it to the correct location.

Start by creating the directories:

```bash
mkdir -p example.com/{src,dist,resc};
```

And start populating your `src` with something, e.g. with `<h1>Hello, world!</h1>`:

```bash
echo "# Hello, world!" > example.com/src/index.md;
```

And copy some good [`ssg`](https://rgz.ee) header and footer files; we'll assume
that those files are already in `~/.ssg`:

```bash
cp ~/.ssg/{_header.html,_footer.html} example.com/src/;
```

Now, update your manifest in `manifest.json` to reflect your website state by adding
your new example website to `sites` JSON key in the manifest.

After you are done writing the website manifest, you should now be able to use
webtools script. Verify that by running `genhtml.sh` and checks if it created
HTML files for us:

```bash
./genhtml.sh;
find example.com/dist -name "index.html" && echo "webtools ok";
```

### Using `cleanhtml.sh`

`ssg` will not update the HTML files if the Markdown versions were not changed,
i.e. `ssg` will only create a new HTML for an existing Markdown files if the
Markdown checksum changed.

This means that, if you want to change `_header.html` and you want that change
reflected in the `dist` folder, `ssg` will not proceed and your HTML files will
stay the same with same header. Try this one for yourself:

```bash
./genhtml.sh; # New HTML files created
./genhtml.sh; # No HTML files created!
```

The second call to `genhtml.sh` will never yield anything. This is because,
when the first call is done to `genhtml.sh`, the hash table in `.files` has been
updated with the latest hash of the Markdowns. When the second call starts, `ssg`
still sees that `.files` had not changed, and so it exits without doing anything.

To make `ssg` create our website again, we must remove `.files`. We can do that
manually, but it gets tiresome after a few websites. So that you do is you use
`cleanup.sh` to take care of these deletetions for you, since string `.files` is
already in the manifest (`cleanup.toRemove` array).

Try doing just that by executing `cleanup.sh`:

```bash
./cleanup.sh;
./genhtml.sh;
```

You should see `example.com/dist/.files` showing up in your delete prompt.
After you deleted that file, `ssg` should work again and this time `genhtml.sh`
will create the new files with new headers, even if their Markdown content stayed
the same.

Your website should pop up in the prompt, and a new `index.html` should be
available in `example.com/dist`

### Using `sendweb.sh`

Now that you can create new HTML files from Markdowns, it's time we push our
HTML documents to the webserver.

To do that, let's first assume that on our local machine, we have a SSH Host `myserverlol`
defined in `~/.ssh/config` with user `admin`, and we want to push our documents to
`$ADMIN_HOMEDIR/dropbox/websites`, which is writable by user `admin`.

To do this, add the server object to `servers` arrays of the manifest files:

```json
{
  "hostname": "myserverlol",
  "scpPath": "admin@myserverlol@:~/dropbox/websites"
}
```

Now, try executing `sendweb.sh`. It should give you a prompt asking if you
really want to send the directory.

### Using `linkweb.sh` to manage content and resources in the long term

> I recommend that you use `tree` to inspect the directory changes

As you can see, webtools is pretty straightforward. You setup a source directory,
and ssg replicates its Markdown content tree are into distribution tree, with the
same scheme, but in HTML instead.

`linkweb.sh` allows webtools users to put shared resources anywhere on their machine,
and links it back to the `src` or `dist` directory for optimum storage and maintenance.

`linkweb.sh` knows how to link by reading the `links` field in the manifest.

For the source directory, you might want to link ssg `_header.html`/`_footer.html`,
and for the distribution directory, you might wanna link things like style sheet
or media e.g. images.

And now, run `linkweb.sh`:

```bash
./linkweb.sh;
```

And now, check your link destinations. You should see all those soft links.

The other scripts are pretty straightforward. If your manifest is correct,
you should be able to use them without problems.
