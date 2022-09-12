# My computing enviroment - [`unix-tools`](https://gitlab.com/artnoi-staple/unix)
`unix-tools` is a collection of mostly shell scripts and configuration for my personal use.

Lately, some of my friends also find it useful, so I decided to host it publicly on [GitLab](https://gitlab.com/artnoi-staple/unix). Some of the scripts or configuration may not be very useful, or not of any practical use that I myself forget about them.

## Groups
`unix-tools` can be categorized into the following groups:

- Environment variables

This category include files like `.profile`, `.bash_profile `, `.kshrc`, `.mkshrc`. They usually provide shell initialization, determine OS variants, and most importantly configure the shell(s).

They are in `unix/dotfiles/general`.

- Files-to-source (FTS)

Files in this group are meant to be sourced by other files to provide uniformed behaviors. This includes `source.sh` (to source other FTS files), `lb.sh` (line breaks), `yn.sh` (yes/no prompt).

They are usually in `unix/sh-tools/bin` because they need to be in `$PATH`

- Shell scripts for everyday use (`sh-tools`)

`sh-tools` include `up`, `svstat`, and the `dmenu*` scripts.

They are usually in `unix/sh-tools/bin` because they need to be in `$PATH`

- Shell scripts for writing artnoi.com (`web-tools`)

This group relies heavily on FTS to function. It is used to generate HTML from Markdown, to symlink the files, send documents to remote servers, etc.

Users must first edit `webtools.conf` with their own configuration for it to work.

- Configuration files (dotfiles)

The configurations for various programs can be found in `unix/dotfiles`. They usually require the entire `unix` files installed to work.

In addition to these groups, there are also some helper scripts `install.sh` to install these files, and `dv.sh` to view `diff` between the pulled and installed files.

> Learn more about certain groups below

## In-depth
### Environment variables
- `.profile`

As shell starts, it reads `.profile` for initialization. The first thing it (`.profile`) does is checking the operating system, and later exports `$OS` accordingly.

It detects the operating system with a `case` statement, so if it couldn't detect the OS, the `$OS` variable will be unset.

After that, it checks whether the user is in Wayland by `$XDG_SESSION_TYPE` variable. If so, it exports `WAYLAND` and `MOZ_ENABLE_WAYLAND`

`.profile` later *chain-load* the other files required for the shell. Currently, Bash and KornShell variants are supported.

Its content as of June 2021 is:

    if [ -z "$OS" ]; then
      kern="$(uname)";

      case "$kern" in
      'Darwin')
        export OS="$kern" ;;

      'OpenBSD')
        export OS="$kern" ;;

      'FreeBSD')
    	export OS="$kern" ;;

      'Linux')
    	[ -n "$(command -v apt-get )" ]\
		  && export OS="Debian";

    	[ -n "$(command -v pacman )" ]\
		  && export OS="Arch";

    	[ -n "$(command -v xbps)" ]\
		  && export OS="Void";

		[ -n "$(command -v dnf)" ]\
		  && export OS="Redhat"; ;;
      esac;
    fi;

	# Wayland support
	[ "$XDG_SESSION_TYPE" = 'wayland' ]\
	  && export WAYLAND=1\
	  && export MOZ_ENABLE_WAYLAND=1;

	case "$SHELL" in
	  # For ksh family, e.g. ksh, mksh, loksh
	  *'ksh')
	    export ENV="$HOME/.kshrc"; ;;
	  'bash')
	    export ENV="$HOME/.bashrc"; ;;
	esac;

- `.bash_profile`, `.kshrc`, `.mkshrc`

These files are sourced by `.profile`, and they later source the files in `unix/dotfiles/general/config/shell`

- Files in `unix/dotfiles/general/config/shell`

These files configures the `$PATH`, aliases, and prompts (`$PS1` and `$PS2`). Different shells will need different prompt files.

### Files-to-source (FTS)
This group provides uniformed behaviors like yes/no prompt for other files.

- `yn.sh`

A simple, stupid yes/no prompt that works in any of the supported shells. It can also be used to read string from user input.

- `lb.sh`

A useless script used to create line breaks.

- `source.sh`

This file can be used to source other frequently used FTS files like `lb.sh` and `yn.sh`

### `sh-tools` scripts
Scripts for everyday use. Some of the scripts require user configuration in `$HOME/bin/priv` (private config).

Scripts that need said configuration are `ufw.sh` (for rules), `dmenussh.sh` (for host list), `dmenusearch.sh` (for private search engine list), and `dmenufirefox.sh` (for bookmarks).

> In addition to their own configurations, `sh-tools` scripts usually require the environment variables from the repository to work properly.

This group can be roughly divided into 2 subgroups:

1. `dmenu*` scripts

Launcher scripts - from browser bookmarks, search engine searches, and power options (e.g. sleep or shutdown).

These files have `dmenu` prepended to the start of the names, e.g. `dmenufirefox` and `dmenupower`

If user is Wayland, the shell initialization from `.profile` and `unix/dotfiles/config/shell/alias` will make `dmenu` alias of `wofi -d`.

2. Other scripts in `unix/sh-tools/bin`

These other scripts are usually made because I don't want to memorize the commands. Examples include `up` (for system/package updates), `svstat` for service management, etc.

### Other configuration (`dotfiles`)
These are usually for desktop configuration. Configurations dotfiles are divided into:

- `dotfiles/general`

Configs that work on any operating systems. **The shell configuration (prompts, aliases) are also in this directory**.

> These files will be installed by `unix/install.sh`

- `dotfiles/general/config`

Configs that usually reside in `$HOME/.config`.

> These files will be installed by `unix/install.sh`

- `dotfiles/macOS`

Configs for macOS

> These files will NOT be installed by `unix/install.sh`

- `dotfiles/linux` (deprecated)

Configs for GNU/Linux

> These files will NOT be installed by `unix/install.sh`

- `dotfiles/freebsd` (deprecated)

Configs for FreeBSD

> These files will NOT be installed by `unix/install.sh`
