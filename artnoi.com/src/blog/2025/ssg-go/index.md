Feb 17, [2025](/blog/2025/)

# Introducing ssg-go

[My latest project](https://github.com/soyart/ssg) was originally just a Nix flake
for the original ssg shell script and all its runtime dependencies like Markdown.pl.

In the end, I ended up re-implenting ssg in Go (ssg-go), and a lot more (soyweb).

## The old webtools

We can't talk about ssg-go without mentioning [the old webtools](https://github.com/soyart/webtools/tree/93a36eef25f8ebf294cae0a3cb329c495d015261),
a collection of shell scripts and GitHub Actions workflows designed around the
[original ssg](https://romanzolotarev.com/ssg.html). It used ssg and other shell
scripts to publish to GitHub Pages with Markdown.

Artnoi.com *was* generated and published via webtools, which is responsible for everything.
While deployment was easy enough, I started to feel some friction whenever I wanted to make
changes to the old webtools however trivial the changes.

The old webtools was very fragile - relying on arbitary commands on the runners to run.
It also needs Markdown.pl *or* lowdown for Markdown conversion, python3 and extra packages
for minifiers, and jq to parse JSON manifests, in addition to other UNIX tools.

The old webtools GitHub Actions workflows feels like it was duct-taped together -
everything is pieced together via shell commands, from downloading the scripts and
other dependencies, building the output files, and minifying the whole thing.

A new version of a Python library could break our snowflake pipeline,
and changes in Ubuntu will now have direct effects on how the GitHub Actions scripts
are composed in webtools. The worst is when a dependency is somehow removed or no longer available,
or when our dependencies changed their package names.

All this mess used to run on GitHub Actions, an environment we cannot control.
Towards the end of 2024, I was thinking about overhauling the old webtools,
to make it more "reliable" in 3rd party systems such as GitHub Actions runner.

In short, the old webtools lacked the following:

- Reproducibility

    We depended too much on others, and they could easily break us

- Productivity

    With shell scripts, we can't add new features as easily.

## Addressing reproducibility with Nix

I wanted webtools to always work and continue to work anywhere long after its last Git commit.

This was back when I was learning [Nix](https://nixos.org) very actively.
So the first thing I do to address reproducibility is to package the original ssg and webtools with Nix,
my recent obsession, to make webtools reproducible.

Two Nix features that really caught my eyes is [*Nix Flake*](https://nixos.wiki/wiki/Flakes)
and [*Nix binary cache*](https://nixos.wiki/wiki/Binary_Cache).

With Nix Flake, I can pin the whole thing down to specific package versions,
like how `Cargo.toml` and `Cargo.lock` work in Rust, or `go.mod` and `go.sum` in Go.
This ensures I'll always get the same build inputs, cryptographically enforced via
SHA256 content hash.

Nix Binary Cache mechanism allows everything to persist forever in theory.
Nix community members already have set up these cache servers, and we profit off of their efforts.
Nix cache means that even though a derivation is old and no longer available,
it still lives on somewhere in Nix cache. With both features combined, we have packaged webtools
in a way that will always build in Nix.

Nix Binary Cache infrastructure and the availability of GitHub Actions workflows for Nix means that
I naturally chose Nix over Guix, because it had more batteries included and better community support.

> If Nix some how falls apart due to insider politics, I plan to migrate to Guix.

## Nix Flake is not enough

I had many annoyances with the old webtools, in particular, the fact that I had to
manually write index links for blog posts or custom header titles.

Because the old webtools was written in shell, adding features such as modifying
Markdown documents in-place programmatically becomes very difficult and hard to test.

This led me to try to reimplement ssg and webtools in a real programming language,
so that I can have those features and not end up shooting my own foot with shell scripts.

## Introducing ssg-go

I started with the core of it all - ssg the generator.

ssg-go is the reimplementation of ssg in Go with a few extra super simple features:

- Extensible with Go API

    I intend to import ssg to other code to build up the capabilities and complexity.
    This will be important later on when we want to replace all webtools scripts with
    real programs, each having ssg-go at its core.

- *Streaming* builds

    Instead of doing everything in a synchronous single-threaded fashion,
    ssg-go spawns 2 *main* threads, one to read and build the output,
    the other is responsible solely for spawning 1 writer thread for each output.

- Customizable HTML heading title

    Unlike the original ssg which only uses h1 tag.

    In ssg-go, `_header.html` can specify their preferred source of heading title:

    - `{{from-h1}}`

        ssg-go will use the 1st Markdown h1 (line starting with `#`) as heading title

    - `{{from-tag}}`

        ssg-go will use the first line starting with `:ssg-title` as heading title

- Concurrent writers

    Users can specify how many concurrent writers to be used when writing out
    via environment variable.

ssg-go provides a single executable: `github.com/soyart/ssg/cmd/ssg`,
which can be installed with `go install`:

```shell
go install github.com/soyart/ssg/cmd/ssg@latest
```

In addition to the executable, ssg-go exposes its own API for other consumers to augment
ssg-go and create a higher-level generator, which we'll soon introduce.

## soyweb

I still had to write my own indexes, and the heading title was still hard-coded.
Minifers were missing, and webtools's JSON manifest was still a foreign concept in ssg-go.

ssg-go is great, but it does not cover all of my needs for webtools and artnoi.com.
ssg-go only addresses the "HTML generation" part of the whole picture, and a lot more
work is needed to make it replace the old webtools.

We need minifiers, mechanism to prepare the source (i.e. copying or removing files),
and infrastructure for extra features. This is where soyweb comes in.

soyweb extends ssg-go with higher level features, such as index generators, manifests,
and minifers.

> Because we're no longer working with `jq`, so there's no need to keep the dreaded
> webtools's old manifest schema. soyweb opts for a new schema that reads more intuitively.

Like with many scripts in webtools, where each script only does one thing,
soyweb provides many executables, with most if not all of which sharing exactly
the same CLI parameters:

- minifer

    Minify a file or all files under a directory

- ssg-minifer

    Like ssg from ssg-go, but with minifer pipelines enabled

- ssg-manifest

    Reads JSON manifest and builds site(s) using ssg-go with soyweb features.
    All soyweb features such as minifers, index generators, etc are all available
    in ssg-manifest

In addition to the executables, soyweb also exposes its own functionality as Go API.
The API is carefully constructed to integrate seamlessly with ssg-go API.

All this allowed me to retire all of webtools old shell scripts with soyweb programs.

## The new webtools

Now we have our own ssg and all the binaries we need to replace shell-based webtools,
we can repurpose webtools to solely provide us CI/CD mechanisms for our websites.

The new webtools is just a GitHub Actions template. On push, a GitHub Actions workflow
is run, downloading and unpacking soyweb's `ssg-manifest` using Nix into the runner's
working directory, and use it to generate a website.

Like the original webtools, this new webtools provide us with full history of our websites,
in both source and built forms. But the new webtools is much more reproducible because Nix
is used to build the binaries and no `apt install lowdown` is ever needed on the runners.
