# Git cheat sheet
## Stashing changes
Add the changes to stash, and then stash. Once you're done, pop the stash, and optionally reset the staging changes:

    $ git add ./recent_works;
	$ git stash;
	.
	.
	$ git stash pop;
	$ git reset; # Un-add stashed changes

## Comparing Git repositories
Usually, to compare diffs between branches, we'd do:

    $ git diff <BRANCH_A> <BRANCH_B>;
    $ git diff master develop;

We can also compare remote branch with the exact same command:

	$ git diff origin/master master;

If the remote branch is not known to the local repo, add it, and then compare

    $ git remote add github_upstream https://github.com/foo/bar;
	$ git diff github_upstream/main main;

If the branch to compare lives in a local directory, add the local repo, and see diffs.

    $ git remote add -f localrepo path/to/localrepo;
	$ git remote update;
	$ git diff master localrepo/master;

And we can just remove the remote repo once we're done.

    $ git remote rm localrepo;

### Comparing Git repositories: special keywords
We can use `@`, `@{upstream}`, `@{push}` to get diffs too.

Comparing working copy with upstream branch.

    $ git diff @{upstream};

Comparing current `HEAD` with upstream branch.

    $ git diff @ @{upstream};

Comparing against a branch we're pushing to (in case upstream is not yet set)

    $ git diff @{push};

## Reseting Git repositories
> If you want to preserve recent changes, use shallow clone instead. This guide will removes all commit history and start over.

### Local
[To start over](https://stackoverflow.com/a/2006252), remove `.git` directory and re-initialize the repository with:

    $ sudo rm -r .git;
    $ git init;

Now we have our new `.git` directory, we can add then files with `git add <files>` and commit the change:

    $ git add .;
    $ git commit -m 'Initialized';

### Remote
To *force* rebase a remote repository with our recently reset local repository, first you will need to add the remote repository URL to our local repository:

    $ git remote add [OPTIONS] <REMOTE NAME> <URL>;

The URL can be SSH URL `<user>@<host>:<path>`, or HTTP(S) URL `https://<host>/<path>`. For example, my [gfc](https://gitlab.com/artnoi/gfc.git) GitLab repository can be accessed with both:

    https://gitlab.com/artnoi/gfc.git

and

    git@gitlab.com:artnoi/gfc.git

Now you can *force* update the remote repository with the following `git push` command:

    $ git push --force --set-upstream <REMOTE NAME> <BRANCH NAME>;

## Using SSH keypair to authenticate GitLab/GitHub

> We will be using OpenBSD's OpenSSH, and this guide assumes you will be using just one keypair for one account (i.e. GitHub or GitLab), so that one keypair will be used to authenticate all projects on the website.

Generate new RSA keypair with `ssh-keygen(1)`:
	
	$ ssh-keygen -t <TYPE> -C <COMMENT>

For example, 4096-bit RSA keypair:

    $ ssh-keygen -t rsa -b 4096 -C 'My RSA GitHub key';

Or with ED25519:

    $ ssh-keygen -t ed25519 -C 'My ED25519 GitHub key';

After creating new key (incl. assigning key path and passphrase), add the following key with `ssh-agent(1)` and `ssh-add(1)`:

    $ eval $(ssh-agent -s);
    $ ssh-add <KEY FILE>;

> Note: list keys added by `ssh-add(1)` with `$ ssh-add -l`, and remove all keys with `$ssh-add -D`

You may now add the public keys to GitLab/GitHub accounts on their websites, and test authentication with:

    $ ssh -Tv git@gitlab.com;
    $ ssh -Tv git@github.com;

If that works, we can now reassign Git URLs as remote URLs, replacing HTTP URLs:

    $ git remote set-url <REMOTE NAME> git@gitlab.com:<USER>/<PATH>.git;
    $ git remote set-url <REMOTE NAME> git@github.com:<USER>/<PATH>.git;

Edit OpenSSH configuration (`$HOME/.ssh/config`) to explicitly use the keyfiles:

    Host gitlab.com
	  PreferredAuthentications publickey
	  IdentityFile <KEY FILE>

    Host github.com
	  PreferredAuthentications publickey
	  IdentityFile <KEY FILE>

After this is done, you should be able to use your SSH keys to authenticate with remote repositories.
