
declare -i counter=1
declare -a numbers
hit=0
miss=0
RED='\e[031m'
GREEN='\e[032m'
YELLOW='\e[033m'
RESET='\e[0m'



while :
  do
    random_int=${RANDOM: -1}
    echo "Попытка номер ${counter}"
    read -p "Введите число от 0 до 9 (q - выйти) " input

    case "${input}" in
      [0-9])
        if [[ "${input}" == "${random_int}" ]]
          then
            echo -e "${GREEN}Совпало!${RESET}"
            hit=$((hit+1))
            numbers+=("${GREEN}${input}${RESET}")
          else
            echo -e "${RED}Промах!${RESET}"
            miss=$((miss+1))
            numbers+=("${RED}${input}${RESET}")
        fi
        echo -e "${GREEN}Попадания: $((hit*100/counter))% ${RED}Промахи: $((miss*100/counter))%${RESET}"
        echo -e "${numbers[@]}\n"
	counter+=1      
;;
      q)
        break 1
      ;;
      *)
        echo -e "${YELLOW}Нужно ввести цифру от 0 до 9${RESET}\n"
      ;;
    esac
  done
