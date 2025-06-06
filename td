#!/bin/bash

# Simple ToDo Script

# ToDO File
# 문자열을 구분하기 위해 '|'이 포함된 txt파일
TODO_FILE=$HOME/.todo.txt
SEPARATOR='|'   # 구분자

# 할 일 저장 파일이 존재하지 않을 경우 파일 생성
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

# 아이디 생성 함수
get_next_ID(){
    if [ ! -s "$TODO_FILE" ]; then  # 파일이 비어있으면
        echo 1
    else 
        # awk문법을 사용해서 id(필드 1)의 최댓값을 찾아 +1
        # $1+0 -> $1의 값을 정수로 보장
        awk -F"$SEPARATOR" 'BEGIN{max=0} ($1+0 > max) {max=$1} END{print max+1}' "$TODO_FILE"
    fi
}


# 할 일 추가 기능 - add
if [ "$1" = "add" ]; then
    CONTENT=""
    DEADLINE=""

    if [ -z "$2" ]; then # 내용 인자가 입력되지 않았을 때
        read -r -p "할 일 내용>> " CONTENT
        if [ -z "$CONTENT" ]; then
            echo "오류: 할 일 내용이 입력되지 않았습니다. 추가를 취소합니다." >&2
            exit 1
        fi
    else    # 내용 인자가 입력됐을 때
        shift # 명령어 인자 제거 -> 뒤의 인자들만 남김 ex)"hello jsh"
                # 공백까지 문자열로 인식하기 위함
        CONTENT="$*"    # 나머지 인자들
    fi

    if [[ "$CONTENT" == *"$SEPARATOR"* ]]; then
        echo "오류: 할 일 내용에 구분자(`${SEPARATOR}`)를 포함할 수 없습니다." >&2
        exit 1
    fi

    read -r -p "마감 기한 (YY-MM-DD, 비워두면 설정 안함)>> " DEADLINE
    if [ -n "$DEADLINE" ] && ! [[ "$DEADLINE" =~ ^[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "경고: 마감 기한 형식이 올바르지 않습니다 (YY-MM-DD). '미지정'으로 저장됩니다." >&2
        DEADLINE=""
    fi

    ID=$(get_next_ID)
    DONE_STATUS="0" # 완료 상태(기본값: 0)

    # 내용을 파일에 추가
    echo "${ID}${SEPARATOR}${CONTENT}${SEPARATOR}${DEADLINE}${SEPARATOR}${DONE_STATUS}" >> "$TODO_FILE"
    echo "할 일 추가됨: (ID-$ID) \"$CONTENT\" (마감: ${DEADLINE:-미지정})"
    exit 0
fi

# # 할 일 제거 - rm
# if [ "$1" = "rm" -o "$2" =~ ^[0-9] -o "$2" -lt 1 ]; then
#     ID=0
#     if [ -z "$2"]; then     # 내용의 인자가 전달되지 않았을 때
#         read -r -p "삭제할 할 일의 ID>> " ID
#         if [ -z "$CONTENT" ]; then
#             echo "오류: ID가 입력되지 않았습니다. 삭제를 취소합니다." >&2
#             exit 1
#         fi
#     else 
#         ID="$2"
    
    

#     sed -i "${2}d" $TODO_FILE
#     echo "할 일 제거됨: $2"
# fi

# if [ "$1" = "edit" ] && [ -n "$2"]; then
#     sed "${2}s/"

# # list tasks using bat
# if [ "$1" = "list" ]; then
#     bat -n $TODO_FILE
# fi

# 할 일 목록 초기화
if [ "$1" = "clean" ]; then
    if [ ! -s "$TODO_FILE" ]; then
        echo "이미 할 일 데이터가 비어있습니다." >&2
        exit 1
    fi
    check=""
    read -r -p "정말 초기화 하시겠습니까? 한번 지워진 데이터는 되돌릴 수 없습니다.(y/n)>> " check

    if [ "$check" == "y" ]; then
        > "$TODO_FILE"
        echo "초기화 성공"
    else 
        exit 1
    fi
fi