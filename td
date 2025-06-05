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

# 할 일 추가 기능 - add
if [ "$1" = "add" ]; then
    CONTENT=""
    DEADLINE=""
    if [ -z "$2"]; then # 내용 인자가 입력되지 않았을 때
        read -r -p "할 일 내용>> " CONTENT
        if [ -z "$CONTENT" ]; then
            echo "오류: 할 일 내용이 입력되지 않았습니다. 추가를 취소합니다." >&2
            exit 1
        fi
    else    # 내용 인자가 입력됐을 때
        CONTENT="$2"
    fi

    if [[ "$CONTENT" == *"$SEPARATOR"*]]; then
        echo "오류: 할 일 내용에 구분자(`${SEPARATOR}`)를 포함할 수 없습니다." >&2
        exit 1
    fi

    read -r -p "마감 기한 (YYYY-MM-DD, 비워두면 설정 안함)>> " DEADLINE
    if [ -n "$DEADLINE_DATE" ] && ! [[ "$DEADLINE_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "경고: 마감 기한 형식이 올바르지 않습니다 (YYYY-MM-DD). '미지정'으로 저장됩니다." >&2
        DEADLINE_DATE=""
    fi

    DOEN_STATUS="0" # 완료 상태(기본값: 0)

    # 내용을 파일에 추가
    echo "${CONTENT}${DELIMITER}${DEADLINE}${DELIMITER}${DOEN_STATUS}" >> "$TODO_FILE"
    echo "할 일 추가됨: \"$CONTENT\" (마감: ${DEADLINE:-미지정})"
    exit 0
fi

# 할 일 제거 - rm
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
