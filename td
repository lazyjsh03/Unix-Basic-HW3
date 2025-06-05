#!/bin/bash

# Simple ToDo Script

# ToDO File
# 문자열을 구분하기 위해 '|'이 포함된 txt파일
TODO_FILE=$HOME/.todo.txt
SEPARATOR='|'   # 구분자

# create file if it doesn't exist
if [ ! -f "$TODO_FILE" ]; then
    touch $TODO_FILE
fi

# help message
if [ "$1" = "" -o "$1" = "-h" -o "$1" = "--help" ]; then
    echo "사용법: td <명령어> [인자]"
    echo
    echo "명령어:"
    echo "  add \"할 일 내용\"   : 새 할 일을 추가합니다. (내용에 `${DELIMITER}` 문자 사용 불가)"
    echo "  rm <번호>          : 해당 번호의 할 일을 삭제합니다. (번호는 'list'로 확인)"
    echo "  list               : 모든 할 일을 목록으로 보여줍니다."
    echo "  done <번호>        : 해당 번호의 할 일을 완료 상태로 변경합니다."
    echo "  undone <번호>      : 해당 번호의 할 일을 미완료 상태로 변경합니다."
    echo "  -h, --help         : 이 도움말 메시지를 보여줍니다."
    exit 0
fi

# 임시 파일 (데이터 변경 시 저장)
TEMP_FILE="${TODO_FILE}.tmp"

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
