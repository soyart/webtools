Feb 17, [2025](/blog/2025/)

# ssg-go

My latest project was originally just a Nix flake for ssg to package all the original
ssg shell script and its runtime dependencies.

In the end, I ended up re-implenting ssg in go (ssg-go), and a lot more (soyweb).

## The old webtools

We can't talk about ssg-go without mentioning webtools, a collection of shell scripts
and GitHub Actions workflows designed to use ssg to publish to GitHub Pages with Markdown.

Towards the end of 2023, I was thinking about overhauling
[the old webtools](https://github.com/soyart/webtools/tree/93a36eef25f8ebf294cae0a3cb329c495d015261).
The old webtools was very fragile - relying on arbitary commands on the runners to run.

It needs Markdown.pl or lowdown for Markdown conversion, python3 and packages for minifiers,
and jq to parse JSON manifests, in addition to other UNIX tools used across the scripts.

The old webtools GitHub Actions workflows feels very fragile - everything is pieced together
via shell commands, from downloading the scripts to other dependencies.

This is why I started packaging the original ssg and webtools with Nix, my recent obsession.

## Nix Flake is not enough

I had many annoyance with the old webtools, in particular, the fact that I had to
manually write indexes for blog posts or custom header titles.

Because the old webtools was written in shell, adding features such as modifying
Markdown documents programmatically are very difficult and hard to test.

This led to try to reimplement ssg and webtools in a real programming language,
so that I can have those features and not end up killing myself over frustration.

## Introducing ssg-go

I started with the core of it all - ssg the generator.

ssg-go is the reimplementation of ssg, in Go, and with a few extra dead simple features:

- Extensible with Go API

    I intend to import ssg to other code to build up the capabilities and complexity.

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

    Users can specify how many concurrent writers to be used when writing out.

ssg-go provides a single executable: `github.com/soyart/ssg/cmd/ssg`,
which can be installed with `go install`:

```shell
go install github.com/soyart/ssg/cmd/ssg@latest
```

In addition to the executable, ssg-go exposes its own API for other consumers to augment
ssg-go and create a higher-level generator, which we'll soon introduce.

## soyweb

ssg-go is great, but it does not cover all of my needs for artnoi.com.

I still had to write my own indexes, and the heading title was still hard-coded.
Minifers were missing, and webtools's JSON manifest was still a foreign concept in ssg-go.

Here comes soyweb, a webtools replacement written in Go.

soyweb extends ssg-go with higher level features, such as index generators, manifests,
and minifers.

> Because we're no longer working with `jq`, so there's no need to keep the old, dreaded
> webtools manifest schema. soyweb opts for a new schema that reads more intuitively.

soyweb provides many executables, with most if not all of which sharing
exactly the same CLI parameters:

- minifer

    Minify a file or all files under a directory

- ssg-minifer

    Like ssg from ssg-go, but with minifer pipelines enabled

- ssg-manifest

    Reads JSON manifest and builds site(s) using ssg-go with soyweb features.
    All soyweb features such as minifers, index generators, etc are all available
    in ssg-manifest

## The new webtools

Now we have our own ssg and all the binaries we need to replace shell-based webtools,
we can repurpose webtools to solely provide us CI/CD mechanisms for our websites.

The new webtools is just a GitHub Actions template. On push, a GitHub Actions workflow
is run, downloading and unpacking soyweb's `ssg-manifest` using Nix into the runner's
working directory, and use it to generate a website.

Like the original webtools, this new webtools provide us with full history of our websites,
in both source and built forms. But the new webtools is much more reproducible because Nix
is used to build the binaries and no `apt install lowdown` is ever needed on the runners.
