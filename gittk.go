package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"./repository"
)

const usage = `
Commands:

    clone - Clone git repositories into consistent tree structure
			Accepts HTTPS or SSH or User or Org
			In the case of User or Org, there will be a prompt to select from a list of repositories
			Example:
	        $ gittk clone <HTTPS|SSH|User|Org>      

`

func main() {
	lg := log.New(os.Stderr, "", 0)

	flag.Parse()

	// Print usage if no command was given
	command := flag.Arg(0)
	if command == "" {
		fmt.Print(usage)
		os.Exit(0)
	}

	// Execute the given command
	switch command {
	case "clone":

		// Exit if URI argument was not given to clone command
		cloneTarget := flag.Arg(1)
		if cloneTarget == "" {
			lg.Fatalf("You must supply SSH or HTTPS or User or Org to the clone command.\n%v", usage)
		}

		// Clone
		repoDir, err := repository.Clone(cloneTarget)

		// Exit if error during clone
		if err != nil {
			lg.Fatalf("Unable to clone repository:  %v", err)
		}

		// Print the cloned directory
		fmt.Printf("%v\n", repoDir)

	default:
		lg.Fatalf("The given command is unknown.\n%v", usage)
	}
}
