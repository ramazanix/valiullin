#!/bin/bash

# =====================================
# Игра "Пятнашки" (15 Puzzle)
# =====================================

# Инициализация
SIZE=4
MOVE_COUNT=0

# Генерация случайного поля
generate_field() {
  local numbers=($(shuf -i 1-15))
  for ((i=0; i<15; i++)); do
    field[$i]=${numbers[$i]}
  done
  field[15]=" "
}

# Отрисовка игрового поля
print_field() {
  echo "+-------------------+"
  for ((i=0; i<$SIZE; i++)); do
    line="|"
    for ((j=0; j<$SIZE; j++)); do
      idx=$((i*SIZE + j))
      printf -v cell "%-3s" "${field[$idx]}"
      line+=" $cell|"
    done
    echo "$line"
    if [ $i -lt $((SIZE-1)) ]; then
      echo "|-------------------|"
    fi
  done
  echo "+-------------------+"
}

# Проверка, собрано ли поле
is_solved() {
  for ((i=0; i<15; i++)); do
    if [ "${field[$i]}" != "$((i+1))" ]; then
      return 1
    fi
  done
  return 0
}

# Поиск индекса пустой ячейки
find_empty() {
  for ((i=0; i<16; i++)); do
    if [ "${field[$i]}" == " " ]; then
      echo $i
      return
    fi
  done
}

# Получить список допустимых ходов
valid_moves() {
  local empty=$(find_empty)
  local moves=()
  local row=$((empty / SIZE))
  local col=$((empty % SIZE))

  [[ $row -gt 0 ]] && moves+=("${field[$((empty - SIZE))]}")   # вверх
  [[ $row -lt $((SIZE-1)) ]] && moves+=("${field[$((empty + SIZE))]}") # вниз
  [[ $col -gt 0 ]] && moves+=("${field[$((empty - 1))]}")      # влево
  [[ $col -lt $((SIZE-1)) ]] && moves+=("${field[$((empty + 1))]}")   # вправо

  echo "${moves[@]}"
}

# Перемещение костяшки
move_tile() {
  local tile=$1
  local empty=$(find_empty)
  local row=$((empty / SIZE))
  local col=$((empty % SIZE))
  local newpos=-1

  [[ $row -gt 0 && "${field[$((empty - SIZE))]}" == "$tile" ]] && newpos=$((empty - SIZE))
  [[ $row -lt $((SIZE-1)) && "${field[$((empty + SIZE))]}" == "$tile" ]] && newpos=$((empty + SIZE))
  [[ $col -gt 0 && "${field[$((empty - 1))]}" == "$tile" ]] && newpos=$((empty - 1))
  [[ $col -lt $((SIZE-1)) && "${field[$((empty + 1))]}" == "$tile" ]] && newpos=$((empty + 1))

  if [ $newpos -ne -1 ]; then
    field[$empty]=${field[$newpos]}
    field[$newpos]=" "
    return 0
  else
    return 1
  fi
}

# =============================
# Основной цикл игры
# =============================

generate_field

while true; do
  echo "Ход № $((MOVE_COUNT+1))"
  print_field

  echo -n "Ваш ход (q - выход): "
  read input

  # Проверка выхода
  if [[ "$input" =~ ^[Qq]$ ]]; then
    echo "Вы вышли из игры."
    exit 0
  fi

  # Проверка корректности ввода
  if [[ ! "$input" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: нужно ввести номер костяшки (1–15) или q для выхода."
    continue
  fi

  # Проверка, можно ли двигать эту костяшку
  if move_tile "$input"; then
    ((MOVE_COUNT++))
  else
    moves=$(valid_moves)
    echo "Неверный ход!"
    echo "Невозможно костяшку $input передвинуть на пустую ячейку."
    echo "Можно выбрать: $moves"
    continue
  fi

  # Проверка на победу
  if is_solved; then
    echo "Вы собрали головоломку за $MOVE_COUNT ходов."
    print_field
    exit 0
  fi
done
