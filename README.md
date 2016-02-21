alpine-devel-howto
==================

WHAT IS THIS?
-------------
This is the way to build alpinelinux packages using docker containers. This is
an example, is should be taken as a base and the `build.bash.base` be modified
according to your needs and put on your `~/bin/` or `/usr/local/bin/`.

The docker containers that uses is `resnullius/alpine-devel` and the tags
available are `3.2`, `3.3` and `edge`. It can be used with
`resnullius/alpine-devel-armv7l` as well (it has the same tags), you just need
to change the docker image's name.

There is a script for helping you figure out how to create your developer keys
called `createkeys.bash`.

It expects you to have a `~/.alpine` directory with subdirectories `keys` and
`conf`.

UPDATE THE ABUILD.CONF
----------------------
First, update your `abuild.conf`, you can copy from the one shipped in this
repo, just make sure you do change the `PACKAGER` line and the `CHOST` line if
you are not building for the architecture `x86_64`. Remember to add it into your
`~/.alpine/conf/`.

GENERATING YOUR KEYS
--------------------
After saving your `abuild.conf` into `~/.alpine/conf/` and created
`~/.alpine/keys` you can run `bash createkeys.bash` from this repo, the output
should be something like:

    $ bash createkeys.bash
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

**You just need to do this once.**

BUILDING A PACKAGE
------------------
Go to the directory where your `APKBUILD` lives and run the script you renamed
from `build.bash.base`, in my case is called `alpine-pkg-build` on my `~/bin/`
so just:

    $ alpine-pkg-build

That will create a `pkgs/` directory in your `$PWD` and inside you will have a
folder with the name of your architecture and inside there will be an
`APKINDEX.tar.gz` and the `.apk`s created by your `APKBUILD`.

There are more options for building, just keep reading other titles.

RUNNING THE CONTAINER
---------------------
There's an extra `run.bash` script that just mounts everything for you and
leaves you in a `sh` shell inside the container so you can test things out
there.

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
    $ REPO_DIR=~/build/repo alpine-pkg-build
    $ cd ../rtorrent/
    $ REPO_DIR=~/build/repo alpine-pkg-build

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

AUTHOR AND LICENSE
------------------
© 2016, Jose-Luis Rivas `<me@ghostbar.co>`.

This software is licensed under the MIT terms, you can find a copy of the
license in the `LICENSE` file in this repository.
