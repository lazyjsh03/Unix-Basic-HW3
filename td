#!/bin/bash

# Simple ToDo Script

# ToDO File
# 문자열을 구분하기 위해 '|'이 포함된 txt파일
TODO_FILE=$HOME/.todo.txt
SEPARATOR='|'   # 구분자



# 아이디 생성 함수
get_next_ID(){
    # 파일이 비어있으면 ID는 1로 설정
    if [ ! -s "$TODO_FILE" ]; then  
        echo 1
    else 
        # awk문법을 사용해서 id(필드 1)의 최댓값을 찾아 +1 -> 새로 적용될 ID
        # $1+0 -> $1의 값을 정수로 보장
        awk -F"$SEPARATOR" 'BEGIN{max=0} ($1+0 > max) {max=$1} END{print max+1}' "$TODO_FILE"
    fi
}



# 할 일 저장 파일이 존재하지 않을 경우 파일 생성
if [ ! -f "$TODO_FILE" ]; then
    touch $TODO_FILE



# help message
# 명령 인자가 비어있거나 옵션으로 -h, --help가 전될되었을 때
elif [ "$1" = "" -o "$1" = "-h" -o "$1" = "--help" ]; then
    echo "사용법: td <명령어> [인자]"
    echo
    echo "명령어:"
    echo "  add \"할 일 내용\"   : 새 할 일을 추가합니다. (내용에 `${DELIMITER}` 문자 사용 불가)"
    echo "  rm <번호>          : 해당 번호의 할 일을 삭제합니다. (번호는 'list'로 확인)"
    echo "  list               : 모든 할 일을 목록으로 보여줍니다."
    echo "  edit               : 할 일의 내용을 수정합니다."
    echo "  done <번호>        : 해당 번호의 할 일을 완료 상태로 변경합니다."
    echo "  undone <번호>      : 해당 번호의 할 일을 미완료 상태로 변경합니다."
    echo "  clean              : 할 일 목록을 초기화 합니다."
    echo "  -h, --help         : 이 도움말 메시지를 보여줍니다."
    exit 0



# 할 일 추가 기능 - add
elif [ "$1" = "add" ]; then
    CONTENT=""      # 내용 정보 들어갈 변수
    DEADLINE=""     # 마감기한 정보 들어갈 변수

    # 내용 인자가 입력되지 않았을 때
    if [ -z "$2" ]; then

        # read를 통해서 사용자에게 CONTENT 정보를 입력받음
        # -p: 프롬프트를 통해서 입력받음 / -r: 백슬래시 무시
        read -r -p "할 일 내용>> " CONTENT

        # 내용 입력이 이루어지지 않았을 때 오류 발생(표준 에러)
        if [ -z "$CONTENT" ]; then
            echo "오류: 할 일 내용이 입력되지 않았습니다. 추가를 취소합니다." >&2
            exit 1
        fi
    # 내용 인자가 입력됐을 때
    else    

        # 명령어 인자 제거 -> 뒤의 인자들만 남김 ex)"add hello Unix" -> "hello Unix"
        # 공백까지 문자열로 인식하기 위함
        shift 

        # 나머지 인자들(add를 제외한 모든 인자) 정보 저장
        CONTENT="$*"
    fi

    # CONTENT에 '|' 구분자가 포함될 경우 오류 발생
    if [[ "$CONTENT" == *"$SEPARATOR"* ]]; then
        echo "오류: 할 일 내용에 구분자(`${SEPARATOR}`)를 포함할 수 없습니다." >&2
        exit 1
    fi

    # read와 -p 옵션을 통해 DEADLINE 정보를 프롬프트를 통해 입력받음
    read -r -p "마감 기한 (YY-MM-DD, 비워두면 설정 안함)>> " DEADLINE

    # DEADLINE 의 입력이 이루어졌는데 그 형식이 YY-MM-DD이 아닐 때
    if [ -n "$DEADLINE" ] && ! [[ "$DEADLINE" =~ ^[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "경고: 마감 기한 형식이 올바르지 않습니다 (YY-MM-DD). '미지정'으로 저장됩니다."

        # DEADLINE 정보를 미지정으로 설정
        DEADLINE=""
    fi

    # 추가할 할 일 데이터의 ID를 설정
    # 앞에서 설정한 함수를 이용해서 TODO_FILE에 저장된 ID의 최댓값+1
    ID=$(get_next_ID)

    # 완료 상태(기본값: 0)
    DONE_STATUS="0" 

    # 내용을 파일에 추가
    # 저장 형식 -> "ID|내용|마감기한|완료상태"
    echo "${ID}${SEPARATOR}${CONTENT}${SEPARATOR}${DEADLINE}${SEPARATOR}${DONE_STATUS}" >> "$TODO_FILE"
    echo "할 일 추가됨: (ID-$ID) \"$CONTENT\" (마감: ${DEADLINE:-미지정})"
    exit 0



# 할 일 제거 - rm
elif [ "$1" = "rm" ]; then

    # 인자가 입력되지 않았을 때
    if [ -z "$2" ]; then 

        # read와 -p 옵션을 통해 프롬프트와 함께 ID를 입력받음
        read -r -p "삭제할 할 일의 ID>> " ID

        # ID가 입력되지 않았을 때
        if [ -z "$ID" ]; then
            echo "오류: ID가 입력되지 않았습니다. 삭제를 취소합니다." >&2
            exit 1
        fi

    # 인자가 입력됐을 때
    else    
        ID="$2"
    fi

    # ID가 숫자가 아니거나 1보다 작을 때 오류 발생
    if ! [[ "$ID" =~ ^[0-9]+$ ]] || [ "$ID" -lt 1 ]; then
        echo "오류: 유효하지 않은 ID입니다. 숫자만 입력해주세요." >&2
        exit 1
    fi
    
    # awk를 사용
    # -F 옵션으로 구분자 설정 / -v 옵션으로 변수 설정
    # 입력한 ID가 현재 행의 첫번째 필드의 값과 같은지 검사
    # 조건이 참이면 그 행의 줄 번호를 target_id에 저장
    target_id=$(awk -F"$SEPARATOR" -v target_id="$ID" '$1 == target_id {print NR; exit}' "$TODO_FILE")

    # target_id가 없을 때(일치하는 라인을 찾지 못했을 때) 오류 발생
    if [ -z "$target_id" ]; then
        echo "오류: ID $ID 에 해당하는 항목을 찾을 수 없습니다." >&2
        exit 1
    fi

    # awk를 사용
    # -F 옵션으로 구분자 설정 / -v 옵션으로 변수 설정
    # target_id와 같은 행 번호에 해당하는 행 빼고 TODO_FILE.tmp에 저장
    awk -F"$SEPARATOR" -v target_id="$target_id" 'NR != target_id' "$TODO_FILE" > "$TODO_FILE.tmp"

    # TODO_FILE.tmp를 다시 TODO_FILE로 이름변경
    mv "$TODO_FILE.tmp" "$TODO_FILE"

    # 직전 명령어가 실패하면 오류 발생
    if [ $? -ne 0 ]; then
        echo "오류: 할 일을 제거하는 중 문제가 발생했습니다." >&2
        exit 1
    fi

    echo "할 일 제거됨: $ID"



# 할 일 수정 기능
elif [ "$1" = "edit" ]; then
     if [ -z "$2" ]; then
        read -r -p "수정할 할 일 ID>> " id
    else
        id="$2"
    fi

    # ID에 해당하는 줄 번호 찾기
    line_num=$(awk -F"$SEPARATOR" -v target_id="$id" '$1 == target_id {print NR; exit}' "$TODO_FILE")
    
    if [ -z "$line_num" ]; then
        echo "오류: ID $id 에 해당하는 항목을 찾을 수 없습니다." >&2
        exit 1
    fi

    echo "무엇을 수정 하겠습니까? 1) 명칭 2) 날짜(번호 선택)"
    read -r choice

    case "$choice" in
        1)
            read -r -p "새로운 할 일 명칭>> " newContent
            if [[ "$newContent" == *"$SEPARATOR"* ]]; then
                echo "오류: 명칭에 구분자 '${SEPARATOR}'를 포함할 수 없습니다." >&2
                exit 1
            fi
            oldLine=$(sed -n "${line_num}p" "$TODO_FILE")
            oldDeadline=$(echo "$oldLine" | cut -d "$SEPARATOR" -f3)
            oldStatus=$(echo "$oldLine" | cut -d "$SEPARATOR" -f4)
            sed -i "${line_num}s/.*/${id}${SEPARATOR}${newContent}${SEPARATOR}${oldDeadline}${SEPARATOR}${oldStatus}/" "$TODO_FILE"
            echo "할 일 명칭이 수정되었습니다."
            ;;
        2)
            read -r -p "새로운 마감 기한 (YY-MM-DD, 비워두면 삭제)>> " newDeadline
            if [ -n "$newDeadline" ] && ! [[ "$newDeadline" =~ ^[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
                echo "경고: 날짜 형식이 올바르지 않습니다. 수정 취소." >&2
                exit 1
            fi
            oldLine=$(sed -n "${line_num}p" "$TODO_FILE")
            oldContent=$(echo "$oldLine" | cut -d "$SEPARATOR" -f2)
            oldStatus=$(echo "$oldLine" | cut -d "$SEPARATOR" -f4)
            sed -i "${line_num}s/.*/${id}${SEPARATOR}${oldContent}${SEPARATOR}${newDeadline}${SEPARATOR}${oldStatus}/" "$TODO_FILE"
            echo "마감 기한이 수정되었습니다."
            ;;
        *)
            echo "잘못된 선택입니다. 수정 취소."
            exit 1
            ;;
    esac
    exit 0



# list 목록 출력 기능
elif [ "$1" = "list" ]; then
    if [ ! -s "$TODO_FILE" ]; then
        echo "일정이 없습니다"
        exit 0
    fi

    awk -F"$SEPARATOR" '
    # 문자열의 '표시되는' 너비를 계산하는 함수 선언
    # ASCII는 한 칸, 그 외 문자는 두 칸 차지함
    # ASCII는 1, 한글 등 그 외 문자는 2로 계산
    # 함수 내의 지역 변수를 파라미터에서 선언
    function get_display_width(str, i, char, width) {
        width = 0;
        for (i = 1; i <= length(str); i++) {
            char = substr(str, i, 1);
            if (char ~ /[ -~]/) {
                width += 1;
            } else {
                width += 2;
            }
        }
        return width;
    }

    BEGIN {        
        # 목표 너비
        id_w=4; todo_w=25; deadl_w=15;

        # 문자열 길이 계산하여 빈칸 조절 - * 사용
        printf "%s%*s | %s%*s | %s%*s | %s\n",
            "ID", id_w - get_display_width("ID"), "",
            "할 일 내용", todo_w - get_display_width("할 일 내용"), "",
            "마감 기한", deadl_w - get_display_width("마감 기한"), "",
            "완료 여부";
            
        print "-------------------------------------------------------------------";
    }
    {
        if ($3 == "") {
            $3 = "날짜 미지정";
        }

        id_display_w = get_display_width($1);
        todo_display_w = get_display_width($2);
        deadl_display_w = get_display_width($3);

        printf "%s%*s | %s%*s | %s%*s | [%s]\n",
            $1, id_w - id_display_w, "",
            $2, todo_w - todo_display_w, "",
            $3, deadl_w - deadl_display_w, "",
            ($4 == "1" ? "v" : " ");
            
    }' "$TODO_FILE"



# 할 일 목록 초기화 - clean
elif [ "$1" = "clean" ]; then

    # TODO_FILE이 비어있을 때 오류 발생
    if [ ! -s "$TODO_FILE" ]; then
        echo "이미 할 일 데이터가 비어있습니다." >&2
        exit 1
    fi

    # 사용자 확인 작업
    read -r -p "정말 초기화 하시겠습니까? 한번 지워진 데이터는 되돌릴 수 없습니다.(y/n)>> " check

    # 사용자가 y를 입력하면 > 를 사용해 TODO_FILE을 빈 파일로 설정
    if [ "$check" == "y" ]; then
        > "$TODO_FILE"
        echo "초기화 성공"
    else 
        exit 1
    fi



# 할 일 완료 상태 변경 - done
elif [ "$1" = "done" ]; then
    if [ -z "$2" ]; then
        read -r -p "완료 처리할 할 일 ID>> " id
    else
        id="$2"
    fi

    # 해당 ID의 줄 번호 찾기
    line_num=$(awk -F"$SEPARATOR" -v target_id="$id" '$1 == target_id {print NR; exit}' "$TODO_FILE")

    if [ -z "$line_num" ]; then
        echo "오류: ID $id 에 해당하는 항목을 찾을 수 없습니다." >&2
        exit 1
    fi

        oldLine=$(sed -n "${line_num}p" "$TODO_FILE")
        content=$(echo "$oldLine" | cut -d "$SEPARATOR" -f2)
        deadline=$(echo "$oldLine" | cut -d "$SEPARATOR" -f3)

        sed -i "${line_num}s/.*/${id}${SEPARATOR}${content}${SEPARATOR}${deadline}${SEPARATOR}1/" "$TODO_FILE"
        echo "완료 처리 되었습니다."
        exit 0



# 할 일 미완료 상태로 되돌리기 - undone
elif [ "$1" = "undone" ]; then
    if [ -z "$2" ]; then
        read -r -p "미완료로 되돌릴 할 일 ID>> " id
    else
        id="$2"
    fi
    line_num=$(awk -F"$SEPARATOR" -v target_id="$id" '$1 == target_id {print NR; exit}' "$TODO_FILE")

    if [ -z "$line_num" ]; then
        echo "오류: ID $id 에 해당하는 항목을 찾을 수 없습니다." >&2
        exit 1
    fi

    oldLine=$(sed -n "${line_num}p" "$TODO_FILE")
    content=$(echo "$oldLine" | cut -d "$SEPARATOR" -f2)
    deadline=$(echo "$oldLine" | cut -d "$SEPARATOR" -f3)

    sed -i "${line_num}s/.*/${id}${SEPARATOR}${content}${SEPARATOR}${deadline}${SEPARATOR}0/" "$TODO_FILE"
    echo "미완료 처리 되었습니다."
    exit 0


# 잘못된 명령어 입력 시
else 
    echo "명령어를 찾을 수 없습니다. (도움말: -h, --help)"
    exit 1

fi
