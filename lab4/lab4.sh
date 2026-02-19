#!/bin/bash

shopt -s nullglob

print_global_help() {
    echo "lab4.sh — утилита для анализа пересдач и формата ФИО"
    echo
    echo "Доступные команды:"
    echo "  retakes <Группа>   — студент с минимальным числом пересдач и количество пересдач"
    echo "  badnames <Группа>  — список студентов с именами, не соответствующими формату ФамилияИО"
    echo
    echo "Справка по команде:"
    echo "  ./lab4.sh <команда> --help"
}

print_retakes_help() {
    echo "Команда: retakes"
    echo "Формат:  ./lab4.sh retakes A-XX-XX | Ae-XX-XX"
    echo
    echo "Описание:"
    echo "  По указанной группе ищет студента с минимальным количеством пересдач"
    echo "  (по всем тестам двух предметов) и выводит его имя и число пересдач."
    echo
    echo "Пересдача — любая попытка сдачи теста студентом после первой."
}

print_badnames_help() {
    echo "Команда: badnames"
    echo "Формат:  ./lab4.sh badnames A-XX-XX | Ae-XX-XX"
    echo
    echo "Описание:"
    echo "  По указанной группе выводит имена студентов, которые не соответствуют"
    echo "  формату ФамилияИО (латинские буквы, без пробелов, фамилия + две буквы ИО)."
}

if [[ -z "$1" ]]; then
    echo "Некорректный ввод. Для справки вызовите:"
    echo "./lab4.sh --help"
    exit 1
fi

COMMAND="$1"
GROUP="$2"

GROUPS_DIR="students/groups"
GROUP_FILE="$GROUPS_DIR/$GROUP"
TEST_POP="Поп-Культуроведение/tests"
TEST_CIRCUS="Цирковое_Дело/tests"

if [[ "$COMMAND" == "--help" || "$COMMAND" == "-h" ]]; then
    print_global_help
    exit 0
fi

if [[ "$COMMAND" == -* ]]; then
    echo "Такого ключа не существует. Для справки по ключам введите: ./lab4.sh -h и нажмите Enter"
    exit 1
fi

check_group_arg() {
    local cmd="$1"
    local group="$2"

    if (( $# != 2 )); then
        echo "Некорректный ввод. Для справки по команде $cmd вызовите: ./lab4.sh $cmd -h"
        exit 1
    fi

    if [[ "$group" == "-h" || "$group" == "--help" ]]; then
        case "$cmd" in
            retakes)  print_retakes_help ;;
            badnames) print_badnames_help ;;
        esac
        exit 0
    fi

    if [[ "$group" == -* ]]; then
        echo "Такого ключа не существует. Для справки по команде введите: ./lab4.sh $cmd -h и нажмите Enter"
        exit 1
    fi

    if [[ ! "$group" =~ ^(A|Ae)-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Номер группы не соответствует формату. Для справки по команде $cmd введите: ./lab4.sh $cmd -h и нажмите Enter"
        exit 1
    fi

    if [[ ! -f "$GROUP_FILE" ]]; then
        echo "Группы не существует в общем списке групп в папке students/groups/. Вот список существующих групп:"
        ls "$GROUPS_DIR"
        exit 1
    fi

    if [[ ! -r "$GROUP_FILE" ]]; then
        echo "Ошибка: нет прав на чтение файла students/groups/$group (Permission denied)"
        exit 1
    fi
}

count_retakes_for_student() {
    local student="$1"
    local total_retakes=0

    for subject in "$TEST_POP" "$TEST_CIRCUS"; do
        for test in "$subject"/TEST-[1-4]; do
            [[ -f "$test" ]] || continue
            if [[ ! -r "$test" ]]; then
                echo "Ошибка: нет прав на чтение файла теста (Permission denied)"
                exit 1
            fi

            attempts=$(awk -F';' -v g="$GROUP" -v s="$student" '$1==g && $2==s {c++} END{print c+0}' "$test")
            if (( attempts > 1 )); then
                ret=$((attempts - 1))
                total_retakes=$((total_retakes + ret))
            fi
        done
    done

    echo "$total_retakes"
}

if [[ "$COMMAND" == "retakes" ]]; then
    check_group_arg "retakes" "$GROUP"

    declare -A RETAKES
    min_retakes=-1
    best_student=""

    while read -r student; do
        [[ -z "$student" ]] && continue
        r=$(count_retakes_for_student "$student")
        RETAKES["$student"]=$r

        if (( min_retakes == -1 || r < min_retakes )); then
            min_retakes=$r
            best_student="$student"
        fi
    done < "$GROUP_FILE"

    if [[ -z "$best_student" ]]; then
        echo "Нет данных по студентам группы $GROUP."
        exit 0
    fi

    echo "retakes:"
    echo "$best_student | $min_retakes"
    exit 0
fi

if [[ "$COMMAND" == "badnames" ]]; then
    check_group_arg "badnames" "$GROUP"

    bad_list=()

    while read -r student; do
        [[ -z "$student" ]] && continue
        if [[ ! "$student" =~ ^[A-Z][a-zA-Z]+[A-Z]{2}$ ]]; then
            bad_list+=("$student")
        fi
    done < "$GROUP_FILE"

    echo "badnames:"
    echo "Студенты группы \"$GROUP\" с некорректными именами:"
    if (( ${#bad_list[@]} == 0 )); then
        echo "Все имена соответствуют формату ФамилияИО."
    else
        for s in "${bad_list[@]}"; do
            echo "$s"
        done
    fi

    exit 0
fi

echo "Такой команды не существует. Для справки по командам введите: ./lab4.sh -h и нажмите Enter"
exit 1
