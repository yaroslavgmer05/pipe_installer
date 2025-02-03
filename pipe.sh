#!/bin/bash

# Определяем цвета для вывода сообщений
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}Добро пожаловать в установщик ноды Hemi от Crypto Fire! Поддержите автора и подпишитесь на канал t.me/cryptofire8!${NC}"

# Функция установки ноды (скачивание бинарного файла, настройка параметров и запуск через screen)
install_node() {
  # Проверяем, существует ли объект $HOME/pipe и является ли он директорией
  if [ -e "$HOME/pipe" ] && [ ! -d "$HOME/pipe" ]; then
    echo -e "${RED}Ошибка: '$HOME/pipe' существует, но не является директорией. Удалите или переименуйте его и повторите попытку.${NC}"
    return 1
  fi

  if [ -d "$HOME/pipe" ]; then
    echo "Папка 'pipe' уже существует. Удалите ноду и установите заново. Выход..."
    return 0
  fi

  echo -e "${GREEN}Обновляем систему и устанавливаем необходимые пакеты...${NC}"
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install -y nano git gnupg lsb-release apt-transport-https jq screen ca-certificates curl wget lsof

  echo -e "${GREEN}Установка зависимостей завершена.${NC}"
  echo -e "Начинаем установку ноды Pipe...\n"

  # Создаём директорию для ноды и её кэша
  mkdir -p "$HOME/pipe/download_cache" || { echo -e "${RED}Не удалось создать директорию $HOME/pipe/download_cache${NC}"; return 1; }
  cd "$HOME/pipe" || { echo -e "${RED}Не удалось перейти в директорию $HOME/pipe${NC}"; return 1; }

  # Запрос параметров установки
  echo -e "${YELLOW}Введите значение RAM (ГБ):${NC}"
  read -r RAM
  echo -e "${YELLOW}Введите значение Max disk (ГБ):${NC}"
  read -r DISK

  echo -e "${YELLOW}Скачиваем бинарный файл ноды Pipe...${NC}"
  wget https://dl.pipecdn.app/v0.2.2/pop -O pop
  chmod +x pop

  # Создаём новую сессию screen для запуска ноды
  screen -dmS pipe

  echo -e "${YELLOW}Введите ваш публичный адрес Solana:${NC}"
  read -r SOLANA_PUB_KEY
  if [ -z "$SOLANA_PUB_KEY" ]; then
    echo -e "${RED}Публичный адрес не может быть пустым.${NC}"
    return 1
  fi

  echo -e "${GREEN}Запускаем ноду...${NC}"
  # Отправляем команду запуска в сессию screen (экранная сессия с именем pipe)
  screen -S pipe -X stuff "./pop --ram $RAM --max-disk $DISK --cache-dir \$HOME/pipe/download_cache --pubKey $SOLANA_PUB_KEY$(printf \\r)"
  sleep 3
  # Если требуется дополнительная команда (например, токен подтверждения), отправляем её
  screen -S pipe -X stuff "e4313e9d866ee3df$(printf \\r)"
  echo -e "${GREEN}Нода установлена!${NC}"
}

# Функция для проверки статуса ноды
check_status() {
  echo -e "${CYAN}Проверка статуса ноды...${NC}"
  if [ ! -d "$HOME/pipe" ]; then
    echo -e "${RED}Нода не установлена. Пожалуйста, установите ноду (пункт 1).${NC}"
    return 1
  fi
  cd "$HOME/pipe" || { echo -e "${RED}Не удалось перейти в директорию $HOME/pipe.${NC}"; return 1; }
  ./pop --status
  cd ~
}

# Функция для проверки поинтов ноды
check_points() {
  echo -e "${CYAN}Проверка поинтов ноды...${NC}"
  if [ ! -d "$HOME/pipe" ]; then
    echo -e "${RED}Нода не установлена. Пожалуйста, установите ноду (пункт 1).${NC}"
    return 1
  fi
  cd "$HOME/pipe" || { echo -e "${RED}Не удалось перейти в директорию $HOME/pipe.${NC}"; return 1; }
  ./pop --points
  cd ~
}

# Функция удаления ноды
delete_node() {
  echo -e "${YELLOW}Вы уверены, что хотите удалить ноду? (y/n):${NC}"
  read -r confirm
  if [ "$confirm" != "y" ]; then
    echo "Отмена удаления."
    return
  fi

  # Если есть запущенная сессия, останавливаем её
  if screen -list | grep -q "pipe"; then
    screen -S pipe -X quit
  fi
  rm -rf "$HOME/pipe"
  echo -e "${GREEN}Нода была удалена.${NC}"
}

# Главное меню
while true; do
  echo -e "\nВыберите действие:"
  echo "1 - Установить ноду"
  echo "2 - Проверить статус"
  echo "3 - Проверить поинты"
  echo "4 - Удалить ноду"
  echo "5 - Выход"
  read -p "Введите номер: " choice

  case $choice in
    1) install_node ;;
    2) check_status ;;
    3) check_points ;;
    4) delete_node ;;
    5) exit 0 ;;
    *) echo -e "${RED}Неверный пункт. Повторите ввод.${NC}" ;;
  esac
done
