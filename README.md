# Git Toolkit (GITTK)

A git toolkit to facilite working with a large number of repositories

## Build

```sh
zig build

```

## Execute
Only POSIX environments are currently supported.

### Clone

Clone repositories into a tree structure under $HOME/projects.

```sh
zig-out/bin/gittk clone a/b/c
```

#### Example when the cloned repository does not exist locally
```zig
$ zig-out/bin/gittk clone git@github.com:ziglang/zig.git   
Cloning into '/home/mj/projects/github.com/ziglang/zig'...
remote: Enumerating objects: 332686, done.
remote: Counting objects: 100% (517/517), done.
remote: Compressing objects: 100% (199/199), done.
remote: Total 332686 (delta 413), reused 318 (delta 318), pack-reused 332169 (from 3)
Receiving objects: 100% (332686/332686), 351.28 MiB | 2.46 MiB/s, done.
Resolving deltas: 100% (252669/252669), done.
Updating files: 100% (20604/20604), done.

/home/mj/projects/github.com/ziglang/zig
```
#### Example when the cloned repository already exists locally
```zig
$ zig-out/bin/gittk clone git@github.com:ziglang/zig.git
fatal: destination path '/home/mj/projects/github.com/ziglang/zig' already exists and is not an empty directory.

/home/mj/projects/github.com/ziglang/zig
```

#### Example when the cloned repository does not exist remotely
```zig
$ zig-out/bin/gittk clone git@github.com:ziglang/doesnotexist.git
Cloning into '/home/mj/projects/github.com/ziglang/doesnotexist'...
ERROR: Repository not found.
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.

/home/mj/projects/github.com/ziglang/doesnotexist
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

