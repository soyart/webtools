Aug 14, 2020

# I just refactored gfc

So I was relatively free last week, so I updated my most beloved program, [gfc](http://github.com/artnoi43/gfc), which was also my first real program. Within a window of 3-4 days, I had refactored the hell out of it and also added ZSTD compression, XChaCha20/ChaCha20-Poly1305 encryption to the little program, all while remaining <4.5MB in binary size, which is similar to the code before refactoring.

## The CLI parts

### Messy argument handling

My initial goal was simple - I want to rewrite the CLI parts of the program so that it is more coherent and intuitive for users. Before this, gfc only used the Go standard library `flag` package for CLI flag management. It was ugly, and it felt like this was not a free UNIX CLI tools.

This is the [last commit of the classic gfc CLI code](https://github.com/artnoi43/gfc/tree/804d2d9347b8c38a7e442f800f1f77082f1386b7):

In the commit, you can see that [`main` was pretty messy](https://github.com/artnoi43/gfc/blob/804d2d9347b8c38a7e442f800f1f77082f1386b7/cmd/gfc/main.go). It had to handle all exceptions using `if` blocks. As you can see in the code, this will make it extremely difficult to add new features such as compression, or a new encryption cipher.

Before the rewrite, gfc took arguments like this:

```shell
gfc -m CTR -i plain.txt -o enc.bin
```

This looks fine, however, there's no _long_ flag support in the `flag` package, so the following was impossible:

```shell
# Not possible if we used flag package
$ gfc --mode CTR --infile plain.txt --outfile enc.bin
```

And because there's only on big `flags` struct defined in main, this means that both AES and RSA used the same CLI flags, and that we cannot use `-k` for both symmetric and assymetric keys.

My previous stand was that I wasn't going to be using non-stdlib package for building the CLI, but `flag` limitations are really getting in the way. I don't want to focus my efforts on handling arguments/flags. So I started looking for external dependencies for CLI.

There were 2 contenders - [`github.com/urfave/cli` (~18k GitHub stars)](https://github.com/urfave/cli) and [`github.com/alexflint/go-arg`](https://github.com/alexflint/go-arg). I ultimately chose the latter (`go-arg`) because of smaller dependency list and I don't need all those extra functionalities offered by `github.com/urfave/cli` _yet_.

To refactor the CLI parts, I added a new [`cli` package](https://github.com/artnoi43/gfc/tree/stable/pkg/cli), and decide to have only _1_ implementation of the CLI, via the interface `cli.command`. Different algorithms will instead be implemented as a new struct, which implements `cli.command`.

### Shared template `cli.baseCryptFlags`

To standardize the _basic_ stuff that all algorithm structs in package `cli` have to deal with, like infile and outfile specification, compression and encoding flags, I created a new struct `cli.baseCryptFlags`. `baseCryptFlags` partially implements `cli.command`,so that new algo struct can just embed `baseCryptFlags` and inherit all the standard flags. This allows me to easily add new encryption algorithms.

Now that each algorithm subcommand is a struct, like `rsaCommand` for RSA, we can now create a new exported struct `cli.Gfc` that will hold all these subcommands. This makes `gfc` CLI similar to other CLI programs that use subcommands, like `git`.

## Refactoring the main logic

### Method `cli.Gfc.Run()` - aka the true `main()`

Now that we have all these subcommands implementing the same interface `subcommand`, we can write a method for `cli.Gfc` that can handle all subcommands and all the flags.

To do this, I divide gfc logic into [4 different stages](https://github.com/artnoi43/gfc/blob/develop/assets/excalidraw/handle.png?raw=true).

![Stage diagram](https://github.com/artnoi43/gfc/blob/develop/assets/excalidraw/handle.png?raw=true)

- Read infile

If user doesn't specify infile, `os.Stdin` file is used as infile. And if stdin is used, it must not be closed.

- Preprocess

Now is the time where compression occurs when encrypting, or where decoding occurs when decrypting a gfc-encoded file.

- Cryptography

This is when encryption/decryption takes place. It is handled by the algorithm subcommand's `crypt` method.

- Postprocess

Now is the time when gfc performs decompression (when decrypting), or encoding (when encrypting)

You can see all of this in file [`cli.go`](https://github.com/artnoi43/gfc/blob/stable/pkg/cli/cli.go).

## Adding ZSTD

Now that the _main_ logic is standardized in `cli.Gfc.Run()`, we can easily introduce new preprocessing/postprocessing tricks in the pipeline!

First thing I want to do is to add some kind of compression for gfc, and I chose Zstd for its pretty great compress ratio and fast decompression time. The compression is actually pretty easy, but adding it as an option in the command line is even easier! Now you just add a new `compress` field to `cli.baseCryptFlags`!

## Adding XChaCha20/ChaCha20-Poly1305

And because now we can easily introduce new algorithm by just creating a new struct implementing `subcommand`, why not add ChaCha20 family to gfc? As a Wireguard user, I've always wanted to do this. ChaCha20 is faster in software than AES, and, it sounds cool.

I first added only XChaCha20-Poly1305, but later wrote generic functions for both ChaCha20 and XChaCha20 ciphers. So gfc has 2 new algorithm modes, and the code for this is very small. The code for XChaCha20/ChaCha20-Poly1305 is written in 2 files, [one for the generic functions](https://github.com/artnoi43/gfc/blob/stable/pkg/gfc/gfc_chacha20.go), the other for [mode-specific functions](https://github.com/artnoi43/gfc/blob/stable/pkg/gfc/chacha20-poly1305.go).

## Refactoring encryption/decryption code

After adding ChaCha20-family modes, I realized there're some redundant code that's not very obvious. So I tried to aggregate the logic for decoding and writing the [final output stage](https://github.com/artnoi43/gfc/blob/stable/pkg/gfc/gfc_symmetric_aead.go) for the Cryptography stage of gfc.

This led me to realize that some how, I can further refactor this logic! But now I'm too busy trying to configure my new infrastructure, so it may take some time before I can finalize this.

See ya!
