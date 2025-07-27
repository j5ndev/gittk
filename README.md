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

## Test

Execute all tests with the following command.

```sh
zig build test --summary new
```

## Go Scripts

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
