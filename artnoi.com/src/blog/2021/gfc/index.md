Mar 16, [2021](/blog/2021)

<H1>gfc (go file crypt)</H1>

> For recent notes on gfc, see its [README.md](https://gitlab.com/artnoi/gfc)

I just wrote a small Go command-line utility to encrypt/decrypt files using AES-256. Its early versions support AES-GCM and AES-CTR, key file, and PBKDFF2 passphase hash. It is meant to be reused later in other programs, but now it is also a small standalone command-line program.

This is my second real program (not a `sh(1)` script), the first being UNIX `cat(1)` clone called [kat](https://gitlab.com/artnoi/c/-/blob/master/src/kat.c).

Check gfc out on [my Github](https://github.com/artnoi43/gfc) or [GitLab](https://gitlab.com/artnoi/gfc) (more frequent updates on GitLab)

## gfc features

- AES256-GCM (default)

- AES256-CTR (optional)

- PBKDF2 passphrase-key derivation (default)

- Hexademical output (optional)

## Usage

    -H <bool>
    	Use hex output
    -d <bool>
    	Use decrypt mode
    -k <bool>
    	Use keyfile mode
    -p <bool>
    	Print output to stdout
    -m <string>
    	AES modes (GCM or CTR) (default "GCM")
    -f <string>
    	Keyfile file (default "files/key.key")
    -i <string>
    	Input file (default "files/plain")
    -o <string>
    	Output file (default "/tmp/delete.me")

## How gfc works

    gfc
    ├── crypt
    │   ├── ctr.go
    │   ├── file.go
    │   ├── gcm.go
    │   └── key.go
    ├── files
    │   ├── hex
    │   ├── key.key
    │   ├── plain
    │   └── zeroes
    ├── gfc.go
    ├── go.mod
    ├── go.sum
    ├── README.md
    └── test.sh

> gfc will import `gfc/crypt`

`test.sh`

This shell script is used to test multiple combinations of command-line arguments to gfc. It uses associative arrays, so it's not POSIX shell compatible.

`files/`

This directory stores files for testing gfc, i.e. a random file, a plaintext file, a hex file, a 256-bit random key, etc. The keyfile from the repository should be replaced with your own random key:

    $ cd gfc;
    $ dd bs=1 count=32 if=/dev/random of=files/key.key;

gfc will _not_ hash keyfiles, because I expect user's keyfile to be more random than its PBKDF2 hash.

- `gfc.go`

The only file for `main` package is `gfc.go` and is responsible for controlling flows. Other code (e.g. I/O and AES) is in `gfc/crypt` directory.

This main file defines type `flags` that holds command-line flags information. The `flags` struct also has crypt.GfcFile embedded.

- `crypt/file.go`

I/O and file operation methods are defined in `aesgfc/file.go`. This file also defines a struct; `aesgfc.GfcFile` for files used by gfc.

Currently, this struct and its methods wraps basic `os.File` methods like `Open()`, `Create()`, `Read()` and `Write()`. Other functions and methods include those that deal with hex encoding and decoding.

If gfc is given `-H` (hexadecimal), then (1) for encryption, the encrypted output buffer is encoded to hex with `EncodeBuf()` before being written to outfile, or (2) for decryption, the infile is read into a buffer, and that read buffer is decoded from hex to bytes with `DecodeFile()`.

- `crypt/key.go`

This file contains code related to encryption key, e.g. reading passphrase from console, hashing passphrase, and reading keyfile. It also holds constants for gfc cryptography, e.g. the length of certain objects.

`crypt/ctr.go` and `crypt/gcm.go`

gfc supports 2 AES stream cipher modes; GCM (default) and CTR (optional). GCM mode enables message authentication, which should prevent the encrypted files from being tampered. Both modes are stream ciphers based on counter mode of block mode of operation.

## GCM (default mode)

In [AES256-GCM mode](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation), the file bytes is broken _sequentially_ into numbered blocks of 32 octets of bytes (256 bits).

Those block _counter_ (block numbers) is then combined with an initialization vector _iv_, and later encrypted with an AES _block_ cipher derived from the key.

The output from last operation is then used XORed with the underlying plaintext to produce the ciphertext output for the block. That resulting ciphertext is then used to compute the message authentication tag.

## CTR

Because gfc needs to pass all the bytes to `gcm.Seal()` or `gcm.Open()` to encrypt and decrypt respectively, consuming large amount of memoty. So I provided [AES256-CTR mode](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation), which encrypts data by fixed-sized chunks in memory, although gfc's **CTR mode does not have any message authentication (e.g. HMAC) built-in**.

## So we should always use CTR for larger files?

**But because I suck, the method `crypt/ctr.go` uses to read the file actually reads the whole file content** (although in chunks) into memory as read buffer before passing it to the encrypter/decrypter.

Even worse, the way I wrote the write methods for gfc is that the output ciphertext or plaintext is first written to a buffer, so that I can use a reader interface on this buffer later when I encode it (which needs another buffer) to hex, and that buffer is then converted to `[]byte` before it is written to a file.

This is because I want to later use channels and Goroutines to concurrently read, encrypt, and encode to hex, or read, decode hex, and decrypt.
