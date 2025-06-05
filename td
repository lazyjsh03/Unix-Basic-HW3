#!/bin/bash

# Written By Woland

# Simple & Colorful ToDo Script

#Dependency:
#          bat instead of cat
#          Add Script To $PATH

# https://github.com/wolandark
# https://github.com/wolandark/BASH_Scripts_For_Everyone

# ToDO File
TODO_FILE=$HOME/.todo.txt

# create file if it doesn't exist
if [ ! -f "$TODO_FILE" ]; then
    touch $TODO_FILE
fi

# help message
if [ "$1" = "" -o "$1" = "-h" ]; then
    echo "Usage: td add \"task\""
    echo "       td rm N - remove task by its number"
    echo "       td list - list all tasks"
    exit 0
fi

# add task to file
if [ "$1" = "add" ] && [ -n "$2" ]; then
    echo "$2" >> $TODO_FILE
    echo "할 일 추가됨: $2"
    # sort file based on priority
    sort -k1,1 -t $'\e' $TODO_FILE -o $TODO_FILE
fi

# remove task from file
if [ "$1" = "rm" ] && [ -n "$2" ]; then
    sed -i "${2}d" $TODO_FILE
    echo "할 일 제거됨: $2"
fi

# if [ "$1" = "edit" ] && [ -n "$2"]; then
#     sed "${2}s/"

# list tasks using bat
if [ "$1" = "list" ]; then
    bat -n $TODO_FILE
fi


# Simple Version
# # create file if it doesn't exist
# if [ ! -f "$TODO_FILE" ]; then
#     touch $TODO_FILE
# fi

# # add task to file
# if [ "$1" = "add" ] && [ -n "$2" ]; then
#     echo "$2" >> $TODO_FILE
#     echo "Task added: $2"
# fi

# # remove task from file
# if [ "$1" = "rm" ] && [ -n "$2" ]; then
#     sed -i "${2}d" $TODO_FILE
#     echo "Task removed: $2"
# fi

# # list tasks using bat
# if [ "$1" = "list" ]; then
#     bat -n $TODO_FILE
# fi
