# Vim cheat sheet for noobs

> Note: I have since 2022 migrated from Vim and NeoVim to [Helix](https://helix-editor.com)

This useless article will show you noobs how to use Normal mode and Insert mode in Vim so that you can get going. Note that this article is for Vim only and not `vi(1)`.

## Normal mode

When you launch Vim, you are usually in Normal mode, which we usually use for **navigating and entering editor commands**, but NOT really for writing.

> For actual writing, we use Insert mode, which will be discussed later.

To enter a command in Normal mode, press colon `:`, which will bring up the editor command prompt, and then enter the command.

For example, to write out (save) a file after you're done:

```vim
:write
```

or in its short form:

```vim
:w
```

Some of the more frequently used Vim commands are `w` for writing, `q` for quiting, `/` to search for pattern, `s` and `%s` to substitute pattern, and `set` to set configuration, etc. You can try to set Vim to show line number with:

```vim
set number
set relativenumber
set invnumber
```

### Normal mode navigation, and keybindings

In Normal mode, you can navigate through your text with **arrow keys**, or what is dubbed _the Vim keys_: **h, j, k, l keys**.

After some time, you'll learn to love the Vim keys, because they are actually more comfortable to use and are actually more reliable if you work with different keyboards.

Keybinding `G` will go to end of file, while `gg` will go to the beginning. `0` will go to the beginning of line, while `$` is for end of line. You can always navigate by word with `w`, or go backward by word with `b`. And the most frequently one for me is the dot `.` to execute previous command.

### Some command examples

These directional keys can also be used in combination with other commands. For example, key `d` (binded to `:delete` command):

```
d0	= delete from cursor til beginning of line

d$	= delete from cursor til end of line

dgg	= delete from cursor til beginning of file

dG	= delete from cursor til end of file

5dd	= delete 5 lines from cursor

d/text = delete up to pattern `text`
```

I learned a lot from [this YouTube video](https://www.youtube.com/watch?v=wlR5gYd6um0) about how to expressively use these editor commands in a more efficient and intuitive manner.

It is this combination of commands, bindings, regexp, etc. that makes Vim so loved by those who write a lot of text files.

## Insert mode

To enter Insert mode, either use `:insert` command or press _i_ key to insert text into Vim memory buffer. Note that This buffer will not be written to file until user gives the `:write` command.

> To exit the Insert mode (i.e. go back to Normal mode), press Esc.

You can also press _A_ (uppercase) to append the line (i.e. insert at the end of line).

After you are done editting, use `write` (`w`) command to write the buffer to file:

```
:w
```

Or save to another file;

```
:w <FILENAME>
```

And quit Vim with `quit` (`q`) command:

```
:q
```

Most people just combine these:

```
:wq
```

Sometimes, you just want to quit. To force anything in Vim, append `!` to the command. If you want to discard the text you've been editing in Vim, then you can _force_ quit without saving with:

```
:q!
```

## Some newbie tricks

Use `:tabedit` command to edit files in new Vim tab:

```
:tabedit <FILENAME>
```

To enable mouse support, add this line to your `.vimrc` file (Vim configuration) in your home directory:

```vim
set mouse=a
```

Or if you are using the same `.vimrc` on servers and desktops like I do:

```vim
    if has('mouse')
    	set mouse=a
    endif
```

Vim mouse support also works over SSH on many terminal emulators.

### .vimrc

`.vimrc` is where we store Vim "_run command_" configuration, apart from the `.vim` directory. My basic `.vimrc` looks like this:

```vim
" vim files
set viminfo=
set noswapfile
set nobackup
set undodir=$HOME/.vim/

" Editor settings
syntax on
set incsearch
set invnumber
set relativenumber
set smartindent
set tabstop=4 softtabstop=4
set shiftwidth=4
set cursorline
color iceberg

" Enable mouse in all modes if possible
if has('mouse')
    set mouse=a
endif

" Fixes backspace not working
set backspace=indent,eol,start
" Show the cursor position
set ruler
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
```

Also, [watch this YouTube video](https://www.youtube.com/watch?v=wlR5gYd6um0) for yanking (_copy_ text), pasting, and other cool _Vim language_.

If you made it, congrats! You have just learned to master a very expressive, efficient text editor that doesn't require graphic interface at all!

I myself use Vim for almost everything, including this website. Even when programming, I find it much easier to use Vim with a tiling window manager than most other IDEs. Vim is the only software I install to my OpenBSD webserver.

With Vim, you can artfully edit text anywhere from just a console.
