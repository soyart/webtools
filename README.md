# webtools

webtools is a GitHub Pages wrapper for [ssg](https://github.com/soyart/ssg).

> See [ssg](https://github.com/soyart/webtools) before using webtools

It provides a GitHub Actions workflow entrypoint, `ci_v2.yaml`, which uses Nix to build
ssg-go executables and uses the executables to build our website(s).

# Hosting with GitHub Pages

- Host your Markdown site in a *site* branch, e.g. `artnoi.com`.

- Push new changes to the branch, and `ci_v2.yaml` will build your website

- The build output from the previous step is then published to another branch,
  a *publish* branch, e.g. `publish/artnoi.com`.

- GitHub Pages is set up to serve from publish branch, so the build output is served
  on GitHub Pages after the workflow ran.

For example of how all this works, see branch [`artnoi.com`](https://github.com/soyart/webtools/tree/artnoi.com),
and [`publish/artnoi.com`](https://github.com/soyart/webtools/tree/publish/artnoi.com).
