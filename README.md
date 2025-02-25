# webtools

webtools is a GitHub Actions workflow for deploying [ssg/soyweb websites](https://github.com/soyart/ssg)
to GitHub Pages.

> See [ssg](https://github.com/soyart/ssg) before using webtools

The entrypoint [`ci_v2.yaml`](./.github/workflows/ci_v2.yaml) sets parameters for
[`webtools.yaml`](./.github/workflows/webtools.yaml), which uses Nix to build ssg-go
executables and uses the executables to build our website(s).

# Hosting with GitHub Pages

webtools requires at least 2 branches - a *source* and a *publish* branches.
The steps are pretty straightforward:

- Host your Markdown site in a *site* branch, e.g. [`artnoi.com`](https://github.com/soyart/webtools/tree/artnoi.com).

- Push new changes to the branch, and `ci_v2.yaml` will build your website

- The build output from the previous step is then published to another branch,
  a *publish*  or *deploy* branch, e.g. [`publish/artnoi.com`](https://github.com/soyart/webtools/tree/publish/artnoi.com).

- GitHub Pages is set up to serve from publish branch, so the build output is served
  on GitHub Pages after the workflow ran.

For example of how all this works, see branch [`artnoi.com`](https://github.com/soyart/webtools/tree/artnoi.com),
and [`publish/artnoi.com`](https://github.com/soyart/webtools/tree/publish/artnoi.com).

## [webtools.yaml](./.github/workflows/webtools.yaml) steps

1. Install Nix on runner

2. Checks out source branch

3. Build soyweb binaries using Nix

4. Use soyweb's ssg-manifest to build from `./manifest.json`

5. Generate other deployment metadata, e.g. file `CNAME`

6. Snapshot the output directory and publish it to deploy branch

Repository owners must manually set up GitHub Pages to serve from the publish branch, otherwise,
the workflow will only put the output files in the deploy branch.
