#!/bin/bash


# Проверка валидности имени хоста
is_valid_hostname() {
    local host="$1"
    if [[ ! "$host" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        return 1
    fi
}

# Проверка валидности IP-адреса
is_valid_ip() {
    local ip="$1"
    if [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 1
    fi
}

# Пути к файлам
CONFIG_FILE="dns_addresses.conf"
TEMPLATE_FILE="db.local.template"
DB_FILE="db.local"

# Проверка существования файла
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Конфигурационный файл не найден: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Шаблон файла не найден: $TEMPLATE_FILE"
    exit 1
fi

# Создание временного файла
TEMP_FILE=$(mktemp) || exit 1

# Копирование шаблона во временный файл
cp "$TEMPLATE_FILE" "$TEMP_FILE"

# Перебор строк в конфигурационном файле
while IFS= read -r line; do
    # Игнорировать пустые строки и комментарии
    if [[ -z "$line" ]]; then
        continue
    fi

    # Добавление DNS записей
    read -r hostname ip_address <<< "$line"

    # Проверяем валидность имени хоста
    if ! is_valid_hostname "$hostname"; then
        echo "Ошибка: Неверный формат хоста: $line" >&2
        exit 1
    fi

    # Проверяем валидность IP-адреса
    if ! is_valid_ip "$ip_address"; then
        echo "Ошибка: Неверный формат ip: $line" >&2
        exit 1
    fi

    echo "$hostname IN A $ip_address" >> "$TEMP_FILE"
    echo "Добавлена DNS запись: $hostname -> $ip_address"
done < "$CONFIG_FILE"

# Замена db.local на временный файл
mv "$TEMP_FILE" "$DB_FILE"

echo "Файл $DB_FILE успешно заполнен и обновлен."

# Создание контейнера
docker build -t my-dns-server .

# Удаление временного файла
rm "$DB_FILE"

echo "Файл $DB_FILE успешно удалён после сборки контейнера."

# Запуск контейнера
docker run --rm --name dns-server my-dns-server
