# gittk

A git toolkit with a focus on managing a multitude of repos.

## Usage

### View usage

Write usage to stdout

    $ gittk

### clone

Currently only supports github https and ssh URIs.

    $ gittk clone <GIT_URI>

The default projects directory is `~/projects`.  You can change this default with the
`GITTK_PATH` environment variable.

    $ GITTK_PATH=~/go/src clone <GIT_URI>

### -bash option

A boolean option to not execute operations, only write bash commands to STDOUT.

The motivation for outputing bash is to enable automatically
changing directory to the cloned repository.

To accomplish this task, use the following function:

    gittk(){
        eval "$(/usr/local/bin/gittk -bash $@)"
    }


To use only the clone command, use this function:

    clone(){
        eval "$(/usr/local/bin/gittk -bash clone $@)"
    }

Example of bash commands output:

    $ gittk -bash clone https://github.com/majgis/ngify.git

    mkdir -p /home/mjackson/projects/github.com/majgis/ngify \
        && cd /home/mjackson/projects/github.com/majgis/ngify \
        && git clone https://github.com/majgis/ngify.git

## Example tree

    projects
    └── github.com
        ├── majgis
        │   ├── change-log
        │   ├── gittk
        │   └── ngify
        ├── shuhei
        │   └── pelo
        └── willjk
            └── okta-saml-express

## WIP: clone-many

clone ssh|https|org|user

ssh and https currently work for github
Add support for org or user:
1. determine if org or user
2. call correct api endpoint based on 1 to get list of repositories
3. list all ssh and clone urls
4. allow dynamic selection and clone concurrently after selected
    1. space to select
    2. return to proceed
    3. confirm final list if > 1 selected
    4. concurrent downloads using goroutines up to limit of #


List repositories for org:
```
curl \                           
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/orgs/ORG/repos 
```

List repositories for user:
```
curl \                           
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/users/USER/repos

```
