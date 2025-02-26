# ssg-pages

ssg-pages is a GitHub Actions workflow for deploying [ssg/soyweb](https://github.com/soyart/ssg)
websites to GitHub Pages.

> See [ssg](https://github.com/soyart/ssg) before using ssg-pages

The entrypoint workflow [`ci_v2.yaml`](./.github/workflows/ci_v2.yaml) sets parameters
for [`ssg-pages.yaml`](./.github/workflows/ssg-pages.yaml), which uses Nix
to build ssg-go executables and uses the executables to build our website(s).

# Hosting with GitHub Pages

ssg-pages requires at least 2 branches - a *source* and a *publish* branches.
The steps are pretty straightforward:

- Host your Markdown site in a *site* branch, e.g. [`artnoi.com`](https://github.com/soyart/ssg-pages/tree/artnoi.com).

- Push new changes to the branch, and `ci_v2.yaml` will be triggered to build your website

- The build output from the previous step is then published to another branch,
  a *publish*  or *deploy* branch, e.g. [`publish/artnoi.com`](https://github.com/soyart/ssg-pages/tree/publish/artnoi.com).
  This preserves the whole history of our websites, in both source and web form.

- GitHub Pages is set up to serve from publish branch, so the build output is served
  on GitHub Pages after the workflow ran.

For example of how all this works, see branch [`artnoi.com`](https://github.com/soyart/ssg-pages/tree/artnoi.com),
and [`publish/artnoi.com`](https://github.com/soyart/ssg-pages/tree/publish/artnoi.com).

## [ssg-pages.yaml](./.github/workflows/ssg-pages.yaml) steps

1. Install Nix on runner

2. Checks out source branch

3. Build soyweb binaries using Nix

4. Use soyweb's ssg-manifest to build from `./manifest.json`

5. Generate other deployment metadata, e.g. file `CNAME`

6. Snapshot the output directory and publish it to deploy branch

7. Enable HTTPS on GitHub Pages menu in your repository

Note that if we do not have custom domain for our website, then GitHub Pages will serve
your website at `username.github.io/repository`, i.e. `opensoy.github.io/ssg-pages`
for this repository.

This might break your `href` if it's absolute path. To observe this,
go see [opensoy.github.io/ssg-pages](https://opensoy.github.io/ssg-pages)
and try the navbar links to see where they take you.
