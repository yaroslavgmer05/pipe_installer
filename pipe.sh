#!/bin/bash
set -e

# Цвета
Y="\e[33m" C="\e[36m" B="\e[34m" G="\e[32m" R="\e[31m" P="\e[35m" NC="\e[0m"

# Обновление системы
sudo apt update -y && sudo apt upgrade -y

# Установка необходимых утилит
for pkg in figlet; do
    command -v $pkg &>/dev/null || sudo apt install -y $pkg
done

# Вывод приветствия
figlet -w 150 -f standard "CRYPTONODE"
echo -e "${P}by cryptofire8${NC}"
echo -e "${C}TG: https://t.me/cryptofire8${NC}\n"

install_deps() {
    echo -e "${G}Установка зависимостей...${NC}"
    sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen
}

install_node() {
    echo -e "${B}Установка ноды...${NC}"
    install_deps
    mkdir -p ~/pipe/download_cache && cd ~/pipe
    wget https://dl.pipecdn.app/v0.2.2/pop && chmod +x pop
    screen -S pipe2 -dm
    read -p "Solana pubkey: " SOLANA_PUB_KEY
    read -p "RAM (ГБ): " RAM
    read -p "Max disk (ГБ): " DISK
    screen -S pipe2 -X stuff "./pop --ram $RAM --max-disk $DISK --cache-dir ~/pipe/download_cache --pubKey $SOLANA_PUB_KEY\n"
    sleep 3
    screen -S pipe2 -X stuff "e4313e9d866ee3df\n"
    echo -e "${G}Нода установлена!${NC}"
}

check_status() { cd pipe && ./pop --status && cd ..; }
check_points() { cd pipe && ./pop --points && cd ..; }
remove_node() {
    echo -e "${B}Удаление ноды...${NC}"
    pkill -f pop && screen -S pipe2 -X quit && sudo rm -rf ~/pipe
    echo -e "${G}Удалено!${NC}"
}

while true; do
    echo -e "${Y}Выберите действие:${NC}"
    echo "1 - Установить ноду"
    echo "2 - Проверить статус"
    echo "3 - Проверить поинты"
    echo "4 - Удалить ноду"
    echo "5 - Выход"
    read -p "Введите номер: " CHOICE

    case $CHOICE in
        1) install_node ;;
        2) check_status ;;
        3) check_points ;;
        4) remove_node ;;
        5) exit 0 ;;
        *) echo -e "${R}Ошибка! Попробуйте снова.${NC}" ;;
    esac
done
