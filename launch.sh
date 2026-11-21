#!/bin/bash
# Project launcher: save project folders and open them quickly 

conf="$HOME/.projects.conf"
touch "$conf"

declare -A projects 

usage() {
    echo "Usage: bash launch.sh                         interactive menu"
    echo "       bash launch.sh add <name> [path]       save a project (default: current folder)"
    echo "       bash launch.sh list"
    echo "       bash launch.sh open <name>"
    echo "       bash launch.sh remove <name>"
    exit 1
}

load_projects() {
    local name path
    while IFS='=' read -r name path || [ -n "$name" ]; do 
        name="${name%$'\r'}"
        path="${path%$'\r'}"
        [ -z "$name" ] && continue 
        projects["$name"]="$path"
    done < "$conf"
}

sorted_names() {
    printf '%s\n' "${!projects[@]}" | sort 
}

add_project() {
    local name="$1" path="${2:-$PWD}"

    [ -z "$name" ] && usage 

    if [[ ! "$name" =~ ^[A-Za-z0-9_-]+$ ]]; then 
        echo "Error: name can only contain letters, numbers, - and _"
        return 1
    fi 

    if [ ! -d "$path" ]; then 
        echo "Error: '$path' is not a folder"
        return 1 
    fi 

    path=$(cd "$path" && pwd)

    if [ -n "${projects[$name]}" ]; then 
        echo "Error: '$name' already exists (remove it first)"   
        return 1 
    fi 

    echo "$name=$path" >> "$conf"
    projects["$name"]="$path"
    echo "Saved: $name -> $path"
}

list_projects() { 
    if [ "${#projects[@]}" -eq 0 ]; then 
        echo "No projects saved yet. Add one with: bash launch.sh add <name>"
        return 
    fi 

    local name 
    for name in $(sorted_names); do 
        printf "%-24s %s\n" "$name" "${projects[$name]}"
    done 
}

open_project() { 
    local name="$1" path
    path="${projects[$name]}"


    if [ -z "$path" ]; then 
        echo "Error: no project named '$name'"
        return 1
    fi 

    if [ ! -d "$path" ]; then 
        echo "Error: that folder no longer exists: $path"
        return 1
    fi 

    if ! command -v code > /dev/null 2>&1; then 
        echo "Error: the 'code' command was not found. Install VS Code's shell command."
        return 1 
    fi 

    code "$path"
    echo "Opened $name in VS Code"
} 

remove_project() {
    local name="$1"

    if [ -z "${projects[$name]}" ]; then 
        echo "Error: no project named '$name'"
        return 1
    fi 

    sed -i "/^${name}=/d" "$conf"
    unset 'projects[$name]'
    echo "Removed: $name"

}

menu() {
    if [ "${#projects[@]}" -eq 0 ]; then 
        echo "No projects saved yet. Add one with: bash launch.sh add <name>"
        return
    fi 

    local names choice action
    mapfile -t names < <(sorted_names)

    echo "Pick a project (Ctrl+C to quit):"
    PS3="Project number: "

    select choice in "${names[@]}"; do 
        if [ -z "$choice" ]; then 
            echo "Invalid choice"
            continue 
        fi 

        PS3="Action: "
        select action in "Open in VS Code" "Open in File Explorer" "Show path" "Back"; do 
            case "$action" in 
                "Open in VS Code")        open_project "$choice" ;;
                "Open in File Explorer")  explorer "$(cygpath -w "${projects[$choice]}")" ;;
                "Show path")              echo "${projects[$choice]}" ;;
                "Back")                   ;;
                *) echo "Invalid choice"; continue ;;
            esac
            break
        done 
        PS3="Project number: "
    done 
}

load_projects

case "$1" in 
    "")      menu ;;
    add)     add_project "$2" "$3" || exit 1 ;;
    list)    list_projects ;;
    open)    open_project "$2" || exit 1 ;;
    remove)  remove_project "$2" || exit 1 ;;
    *)       usage ;;
esac 