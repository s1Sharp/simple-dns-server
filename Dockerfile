FROM ubuntu:latest

# Установка DNS-сервера BIND
RUN apt-get update && \
    apt-get install -y bind9

# Копирование файлов конфигурации
COPY named.conf.options /etc/bind/named.conf.options
COPY named.conf.local /etc/bind/named.conf.local
COPY db.local /etc/bind/db.local

# Открытие портов DNS
EXPOSE 53/udp
EXPOSE 53/tcp

# Запуск DNS-сервера BIND
CMD ["named", "-g"]
