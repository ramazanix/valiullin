#!/bin/bash

# -----------------------------
# Парсинг аргументов
# -----------------------------

DIRPATH="."
MASK="*"
NUMBER=""
COMMAND=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --path)
            DIRPATH="$2"
            shift 2
            ;;
        --mask)
            MASK="$2"
            shift 2
            ;;
        --number)
            NUMBER="$2"
            shift 2
            ;;
        *)
            COMMAND="$1"
            shift
            break
            ;;
    esac
done

# Остальные параметры после команды — игнорируются по ТЗ (команда принимает только путь к файлу)

# -----------------------------
# Проверки аргументов
# -----------------------------

# Каталог должен существовать
if [[ ! -d "$DIRPATH" ]]; then
    echo "Ошибка: каталог '$DIRPATH' не существует" >&2
    exit 1
fi

# Маска не пустая
if [[ -z "$MASK" ]]; then
    echo "Ошибка: mask не может быть пустой" >&2
    exit 1
fi

# Команда указана
if [[ -z "$COMMAND" ]]; then
    echo "Ошибка: не указана команда" >&2
    exit 1
fi

# Команда должна существовать и быть исполняемой
if [[ ! -x "$COMMAND" ]]; then
    echo "Ошибка: команда '$COMMAND' не существует или не исполняема" >&2
    exit 1
fi

# number по умолчанию = число CPU
if [[ -z "$NUMBER" ]]; then
    NUMBER=$(nproc)
fi

# Проверка number
if ! [[ "$NUMBER" =~ ^[0-9]+$ ]] || [[ "$NUMBER" -le 0 ]]; then
    echo "Ошибка: --number должно быть целым числом > 0" >&2
    exit 1
fi

# -----------------------------
# Формирование списка файлов
# -----------------------------

FILES=()

while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        FILES+=("$file")
    fi
done < <(find "$DIRPATH" -maxdepth 1 -type f -name "$MASK" -print0)

# Если нет файлов — просто завершиться
if [[ ${#FILES[@]} -eq 0 ]]; then
    exit 0
fi

# -----------------------------
# Основной цикл обработки
# -----------------------------

RUNNING=0
INDEX=0
TOTAL=${#FILES[@]}

while [[ $INDEX -lt $TOTAL ]]; do

    # Если активно процессов меньше NUMBER — запускаем новый
    if [[ $RUNNING -lt $NUMBER ]]; then
        FILE="${FILES[$INDEX]}"
        "$COMMAND" "$FILE" &
        RUNNING=$((RUNNING + 1))
        INDEX=$((INDEX + 1))
    else
        # Ждём завершения любого процесса
        wait -n
        RUNNING=$((RUNNING - 1))
    fi
done

# Дождаться всех оставшихся
wait
