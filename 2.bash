#!/bin/bash
# =============================
# Игра "Быки и коровы"
# =============================

# Генерация случайного 4-значного числа с неповторяющимися цифрами
generate_secret() {
  local digits=(0 1 2 3 4 5 6 7 8 9)
  local secret=""
  while [ ${#secret} -lt 4 ]; do
    idx=$((RANDOM % ${#digits[@]}))
    secret+="${digits[$idx]}"
    unset 'digits[$idx]'
    digits=("${digits[@]}") # обновляем массив
  done
  echo "$secret"
}

# Обработка Ctrl+C (SIGINT)
trap 'echo -e "\nЧтобы выйти, введите q или Q, а не Ctrl+C."; continue' SIGINT

# Генерация загаданного числа
secret=$(generate_secret)

# Приветствие
cat <<'INTRO'
********************************************************************************
* Я загадал 4-значное число с неповторяющимися цифрами. На каждом ходу делайте *
* попытку отгадать загаданное число. Попытка - это 4-значное число с           *
* неповторяющимися цифрами.                                                    *
********************************************************************************
INTRO

# Переменные
attempt=1
declare -a history

# Основной цикл
while true; do
  echo -n "Попытка $attempt: "
  read input

  # Проверка выхода
  if [[ "$input" =~ ^[Qq]$ ]]; then
    echo "Вы вышли из игры."
    exit 1
  fi

  # Проверка корректности ввода
  if [[ ! "$input" =~ ^[0-9]{4}$ ]]; then
    echo "Ошибка: нужно ввести 4-значное число."
    continue
  fi

  # Проверка на уникальность цифр
  if [[ $(echo "$input" | grep -o . | sort -u | tr -d '\n' | wc -c) -ne 4 ]]; then
    echo "Ошибка: цифры не должны повторяться."
    continue
  fi

  # Подсчёт "быков" и "коров"
  bulls=0
  cows=0
  for ((i=0; i<4; i++)); do
    user_digit="${input:i:1}"
    secret_digit="${secret:i:1}"
    if [[ "$user_digit" == "$secret_digit" ]]; then
      ((bulls++))
    elif [[ "$secret" == *"$user_digit"* ]]; then
      ((cows++))
    fi
  done

  echo "Коров - $cows, Быков - $bulls"
  history+=("$attempt. $input (Коров - $cows Быков - $bulls)")

  echo -e "\nИстория ходов:"
  for line in "${history[@]}"; do
    echo "$line"
  done
  echo

  # Проверка на победу
  if [ "$bulls" -eq 4 ]; then
    echo "Поздравляю! Вы угадали число $secret за $attempt попыток!"
    exit 0
  fi

  ((attempt++))
done
