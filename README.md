alpine-devel-howto
==================

WHAT IS THIS?
-------------
This is my way to build alpinelinux packages using docker containers.

I use the bash script `alpine-build-pkg` to generate my keys, build packages and
run into a shell in them.

Just clone this repo and make a symbolic link to your `~/bin/` or
`/usr/local/bin/` and you should be ready to go.

This is supposed to be used together with
[docker-alpine-devel](https://github.com/resnullius/docker-alpine-devel) and
it works with both: `x86_64` and the `armv7l` version!. It supports alpine's
versions: `3.2`, `3.3` and `edge`.

It expects you to have a `~/.alpine` directory with subdirectories `keys` and
`conf`. You can change this with arguments to the script.

UPDATE THE ABUILD.CONF
----------------------
First, update your `abuild.conf`, you can copy from the one shipped in this
repo, just make sure you do change the `PACKAGER` line and the `CHOST` line if
you are not building for the architecture `x86_64`. Remember to add it into your
`~/.alpine/conf/`.

GENERATING YOUR KEYS
--------------------
**You just need to do this once.**

After saving your `abuild.conf` into `~/.alpine/conf/` and created
`~/.alpine/keys` you can run `bash alpine-build-pkg gen-key` from this repo,
the output should be something like:

    $ bash alpine-build-pkg gen-key
    Generating RSA private key, 2048 bit long modulus
    ....................+++
    ................................................................+++
    e is 65537 (0x10001)
    writing RSA key
    >>>
    >>> You'll need to install
    >>> /home/builder/.abuild/me@ghostbar.co-56c80129.rsa.pub into
    >>> /etc/apk/keys to be able to install packages and repositories signed
    >>> with
    >>> /home/builder/.abuild/me@ghostbar.co-56c80129.rsa
    >>>
    >>> You might want add following line to /home/builder/.abuild/abuild.conf:
    >>>
    >>> PACKAGER_PRIVKEY="/home/builder/.abuild/me@ghostbar.co-56c80129.rsa"
    >>>
    >>>
    >>> Please remember to make a safe backup of your private key:
    >>> /home/builder/.abuild/me@ghostbar.co-56c80129.rsa
    >>>

This keys will be copied then into `~/.alpine/keys/` and you will be able to
sign with those all your packages.

Add the line that starts with `PACKAGER_PRIVKEY` to your `abuild.conf`, the one
you just saved into `~/.alpine/conf/abuild.conf`.

You can change where the keys are saved with the `-k` argument, so doing `bash
alpine-build-pkg gen-key -k .` would save the keys in your `$PWD`. The other
argument that accepts is `-c` to tell where should look for the `abuild.conf`
file. See more with `alpine-build-pkg --help`.

**You just need to do this once.**

BUILDING A PACKAGE
------------------
Go to the directory where your `APKBUILD` lives and run the `alpine-build-pkg`.

    $ alpine-build-pkg

That will create a `pkgs/` directory in your `$PWD` and inside you will have a
folder with the name of your architecture and inside there will be an
`APKINDEX.tar.gz` and the `.apk`s created by your `APKBUILD`.

Right now, it defaults to build things with alpine's version 3.3, which is the
current stable, but you can change it to 3.2 or edge by using the `-v` flag
like this:

    $ alpine-build-pkg -v edge

There are more options for building, just keep reading other titles and check
out what's in `alpine-build-pkg --help`.

RUNNING THE CONTAINER
---------------------
There's an extra option on `alpine-build-pkg`, maybe you want to get into the
container and run `entrypoint.sh` by yourself or do other stuff there, you can
get into it's shell by running:

    $ alpine-build-pkg run

It accepts arguments as well. See which ones with `alpine-build-pkg --help`.

PLAYING WITH THE OPTIONS ON THE BUILD AND RUN SCRIPTS
-----------------------------------------------------
What if I want to build `libtorrent` and `rtorrent`? This is a tricky case,
since `rtorrent` depends on `libtorrent` so in order to build `rtorrent` you
should be able to install the latests freshly built `libtorrent` on you dev
container, **but do not worry**, I thought about this, you can just use the
`/opt/repo` as a local repo, so let's consider you have an structure like this:

    $ ls ~/build
    libtorrent        rtorrent

And inside each directory there's an `APKBUILD`, so you would end up doing
something like this to get it built correctly:

    $ cd libtorrent/
    $ alpine-build-pkg -r ../repo
    $ cd ../rtorrent/
    $ alpine-build-pkg -r ~/build/repo

Since they both shared the same repository directory `rtorrent` was able to use
the `libtorrent-dev.apk` you just build and it will even have a
`APKINDEX.tar.gz` in `~/build/repo/` with `libtorrent`, `libtorrent-dev` and
`rtorrent` packages there! What does this means? That by publishing on the web
your `~/build/repo` more people can just put that URL on their
`/etc/apk/repositories` and install the latest versions of those packages with
`apk add rtorrent`!

PS: Remember, if they don't have your `.rsa.pub` key in their `/etc/apk/keys`
they will need to make `apk add --allow-untrusted rtorrent` in order to actually
be able to install the package you built.

PS2: Did you saw `-r` supports relative paths? Yes, it does! And all the path
arguments too. Check what other options are available with `alpine-build-pkg
--help`.

AUTHOR AND LICENSE
------------------
© 2016, Jose-Luis Rivas `<me@ghostbar.co>`.

This software is licensed under the MIT terms, you can find a copy of the
license in the `LICENSE` file in this repository.
