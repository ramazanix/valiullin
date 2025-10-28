#!/usr/bin/env bash
trap 'echo -e "\nЧтобы выйти, введите q или Q\n"; continue' SIGINT

A=(8 7 6 5 4 3 2 1)
B=()
C=()

move_count=1

print_stacks() {
  clear
  echo
  max_height=8
  for ((i=max_height-1; i>=0; i--)); do
    printf "|%-2s|  |%-2s|  |%-2s|\n" \
      "${A[i]:- }" "${B[i]:- }" "${C[i]:- }"
  done
  echo "+--+  +--+  +--+"
  echo " A     B     C "
  echo
}

check_victory() {
  local stack=("$@")
  local correct=(8 7 6 5 4 3 2 1)
  [[ "${stack[*]}" == "${correct[*]}" ]]
}

while true; do
  print_stacks
  echo -n "Ход № ${move_count} (откуда, куда): "
  read -r input

  [[ "${input,,}" == "q" ]] && echo "Выход из игры." && exit 1

  if [[ ! "${input,,}" =~ ^[abc][[:space:]]*[abc]$ ]]; then
    echo "Ошибка: нужно ввести два имени стеков (например: ab, a c, BC)"
    sleep 1
    continue
  fi

  from=${input:0:1}
  to=${input: -1}

  if [[ "$from" == "$to" ]]; then
    echo "Ошибка: начальный и конечный стеки совпадают."
    sleep 1
    continue
  fi

  from_stack_name=${from^^}
  to_stack_name=${to^^}

  eval "len_from=\${#${from_stack_name}[@]}"
  if (( len_from == 0 )); then
    echo "Ошибка: стек ${from_stack_name} пуст!"
    sleep 1
    continue
  fi

  eval "disk_from=\${${from_stack_name}[-1]}"
  eval "len_to=\${#${to_stack_name}[@]}"
  if (( len_to > 0 )); then
    eval "disk_to=\${${to_stack_name}[-1]}"
  else
    disk_to=0
  fi

  if (( disk_to != 0 && disk_from > disk_to )); then
    echo "Такое перемещение запрещено!"
    sleep 1
    continue
  fi

  eval "unset ${from_stack_name}[-1]"
  eval "${to_stack_name}+=(\$disk_from)"
  ((move_count++))

  if check_victory "${B[@]}" || check_victory "${C[@]}"; then
    print_stacks
    echo "Поздравляем! Вы собрали башню за $((move_count-1)) ходов!"
    exit 0
  fi
done
