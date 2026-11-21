# Project Launcher 

A Bash script that saves your project folders under short names and opens them in VS Code with one command or from an interactive menu.

## Usage 

```bash
bash launch.sh                      # interactive menu
bash launch.sh add my-app           # save the current folder as "my-app"
bash launch.sh add notes ~/notes    # save a specific folder
bash launch.sh list                 # show saved projects
bash launch.sh open my-app          # open in VS Code
bash launch.sh remove my-app        # forget a project
```

## Where data is stored 

Your projects are saved in `~/.projects.conf` in your home folder, one `name=path` per line.

## Requirements 

Bash (Git Bash on Windows) and VS Code with the `code` command available.

## Author

Written by hand by Brian Angaluki