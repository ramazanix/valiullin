#!/usr/bin/env bash
# Скрипт mkarch — создание самораспаковывающегося архива

# Проверка аргументов
while getopts "d:n:" opt; do
  case "$opt" in
    d) dir_path="$OPTARG" ;;
    n) name="$OPTARG" ;;
    *) echo "Использование: $0 -d <путь_к_каталогу> -n <имя_архива>"; exit 1 ;;
  esac
done

# Проверка обязательных параметров
if [[ -z "$dir_path" || -z "$name" ]]; then
  echo "Ошибка: оба параметра -d и -n обязательны."
  echo "Пример: $0 -d /var/log -n logarch01"
  exit 1
fi

# Проверка существования каталога
if [[ ! -d "$dir_path" ]]; then
  echo "Ошибка: каталог '$dir_path' не существует."
  exit 1
fi

# Создаём временные файлы
tmp_tar=$(mktemp /tmp/mkarchXXXXXX.tar)
tmp_gz="${tmp_tar}.gz"

# Создание tar.gz архива
tar -czf "$tmp_gz" -C "$(dirname "$dir_path")" "$(basename "$dir_path")" || {
  echo "Ошибка при создании архива."
  exit 1
}

# Создаём новый bash-файл с самораспаковывающимся кодом
cat > "$name" <<'EOF'
#!/usr/bin/env bash
# Самораспаковывающийся архив

usage() {
  echo "Использование: $0 [-o каталог_распаковки]"
  exit 1
}

while getopts "o:" opt; do
  case "$opt" in
    o) outdir="$OPTARG" ;;
    *) usage ;;
  esac
done

outdir="${outdir:-.}"

if [[ ! -d "$outdir" ]]; then
  mkdir -p "$outdir" || { echo "Ошибка: не удалось создать каталог '$outdir'."; exit 1; }
fi

ARCHIVE_LINE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0")

tail -n +$ARCHIVE_LINE "$0" | base64 -d | tar -xzf - -C "$outdir"

echo "Архив успешно распакован в: $outdir"
exit 0

__ARCHIVE_BELOW__
EOF

# Вставляем кодированный архив в конец файла
base64 "$tmp_gz" >> "$name"

# Делаем исполняемым
chmod +x "$name"

# Удаляем временные файлы
rm -f "$tmp_tar" "$tmp_gz"

echo "Самораспаковывающийся архив успешно создан: ./$name"
