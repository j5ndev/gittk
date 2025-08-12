# Git Toolkit (GITTK)

A git toolkit to facilite working with a large number of repositories

## Build

```sh
zig build

```

## Execute
Only POSIX environments are currently supported.

### gittk clone \<value>

Clone repositories into a tree structure under the default $HOME/projects.
Both relative and absolute paths are supported.

```sh
zig-out/bin/gittk clone git@github.com:ziglang/zig.git
```

### gittk --project=\<value> clone \<value>

Clone repositories into a different path other than the default $HOME/projects using the `--project`, `-p` option.

```sh
zig-out/bin/gittk --project=/tmp/gittk clone git@github.com:ziglang/zig.git
```

### env GITTK_PROJECT=\<value> gittk clone \<value>

Clone repositories into a different path other than the default $HOME/projects using the `GITTK_PROJECT` environment variable.

```sh
env GITTK_PROJECT=/tmp/gittk66 zig-out/bin/gittk clone git@github.com:ziglang/zig.git
```

#### Example when the cloned repository does not exist locally
```zig
$ zig-out/bin/gittk clone git@github.com:ziglang/zig.git   
Cloning into '/home/user/projects/github.com/ziglang/zig'...
remote: Enumerating objects: 332686, done.
remote: Counting objects: 100% (517/517), done.
remote: Compressing objects: 100% (199/199), done.
remote: Total 332686 (delta 413), reused 318 (delta 318), pack-reused 332169 (from 3)
Receiving objects: 100% (332686/332686), 351.28 MiB | 2.46 MiB/s, done.
Resolving deltas: 100% (252669/252669), done.
Updating files: 100% (20604/20604), done.

/home/user/projects/github.com/ziglang/zig
```
#### Example when the cloned repository already exists locally
```zig
$ zig-out/bin/gittk clone git@github.com:ziglang/zig.git
fatal: destination path '/home/user/projects/github.com/ziglang/zig' already exists and is not an empty directory.

/home/user/projects/github.com/ziglang/zig
```

#### Example when the cloned repository does not exist remotely
```zig
$ zig-out/bin/gittk clone git@github.com:ziglang/doesnotexist.git
Cloning into '/home/user/projects/github.com/ziglang/doesnotexist'...
ERROR: Repository not found.
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.

/home/user/projects/github.com/ziglang/doesnotexist
```
### gittk tree

Execute the tree command, three levels deep, on the project directory.
This command requires `tree` to be on PATH.

```sh
gittk tree
```
#### Example of gittk tree

```sh
/home/user/projects
├── codeberg.org
│   ├── j5ndev
│   │   ├── gittk
│   │   ├── rayliblab
│   │   ├── weblab
│   │   └── ziglings_exercises
│   └── pepomija
│       └── pandora
└── github.com
    ├── Alkaid-Benetnash
    │   └── EmuBTHID
    ├── blythinart
    │   └── blythinart.github.io
    ├── ghostty-org
    │   └── ghostty
    ├── j5ndev
    │   ├── exercism
    │   ├── gittk
    │   ├── kata
    │   ├── rayliblab
    │   ├── weblab
    │   ├── ziglab
    │   └── ziglings_exercises
    ├── nektro
    │   └── zigmod
    ├── pepomija
    │   ├── game-aster
    │   ├── habitual
    │   └── pandora
    ├── ziglang
    │   ├── runner
    │   └── zig
    └── zigtools
        └── zls
```

### gittk ls

Execute the ls command.  All repository directories will be listed.

```sh
gittk ls
```

#### Example of gittk ls

```
$ zig-out/bin/gittk ls
/home/user/projects/github.com/Alkaid-Benetnash/EmuBTHID
/home/user/projects/github.com/j5ndev/gittk
/home/user/projects/github.com/j5ndev/kata
/home/user/projects/github.com/j5ndev/rayliblab
/home/user/projects/github.com/j5ndev/exercism
/home/user/projects/github.com/j5ndev/ziglab
/home/user/projects/github.com/j5ndev/ziglings_exercises
/home/user/projects/github.com/j5ndev/weblab
/home/user/projects/github.com/zigtools/zls
/home/user/projects/github.com/nektro/zigmod
/home/user/projects/github.com/ziglang/runner
/home/user/projects/github.com/ziglang/zig
/home/user/projects/github.com/pepomija/game-aster
/home/user/projects/github.com/pepomija/habitual
/home/user/projects/github.com/pepomija/pandora
/home/user/projects/github.com/ghostty-org/ghostty
/home/user/projects/github.com/blythinart/blythinart.github.io
/home/user/projects/codeberg.org/j5ndev/gittk
/home/user/projects/codeberg.org/j5ndev/rayliblab
/home/user/projects/codeberg.org/j5ndev/ziglings_exercises
/home/user/projects/codeberg.org/j5ndev/weblab
/home/user/projects/codeberg.org/pepomija/pandora
```

### gittk ls --url

Execute the ls command with the url option.  All repository remote origin urls will be listed.

```sh
gittk ls --url
```

#### Example of gittk ls --url

```sh
$ zig-out/bin/gittk ls --url
https://github.com/Alkaid-Benetnash/EmuBTHID.git
git@github.com:j5ndev/gittk.git
git@github.com:j5ndev/kata.git
git@github.com:j5ndev/rayliblab.git
git@github.com:j5ndev/exercism.git
git@github.com:j5ndev/ziglab.git
git@github.com:j5ndev/ziglings_exercises.git
git@github.com:j5ndev/weblab.git
git@github.com:zigtools/zls.git
git@github.com:nektro/zigmod.git
git@github.com:ziglang/runner.git
git@github.com:ziglang/zig.git
git@github.com:pepomija/game-aster.git
git@github.com:pepomija/habitual.git
git@github.com:pepomija/pandora.git
https://github.com/ghostty-org/ghostty.git
git@github.com:blythinart/blythinart.github.io.git
git@codeberg.org:j5ndev/gittk.git
git@codeberg.org:j5ndev/rayliblab.git
git@github.com:j5ndev/ziglings_exercises.git
git@codeberg.org:j5ndev/weblab.git
git@codeberg.org:pepomija/pandora.git
```

## Test

Execute all tests with the following command.

```sh
zig build test --summary new
```

## Shortcut Scripts

Quick shortcuts to commonly executed commands can be found in the `bin` folder.

### Test

```sh
bin/test
```

### Test and build

```sh
bin/build
```

### Test, Build and Execute

```sh
bin/test_exe
```

## Clone Shell Function

Here is an example of a helper shell function to clone the repo and then cd into the directory.
For example, you would add this snippet to your `.zshrc` file if you are using zsh.

```sh
clone () {
    local TARGET=`gittk clone $@ | tail --lines=1`
    cd $TARGET
}
```
