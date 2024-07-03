#!/bin/bash

# -----------------------------------------------------------------------------
# 啟動 Docker 容器
# -----------------------------------------------------------------------------

# 查找所有可能的 docker-compose 文件
find_compose_files() {
  # 獲取腳本當前目錄
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # 獲取專案根目錄
  PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
  # 查找所有可能的 docker-compose 文件
  COMPOSE_FILES=$(find "$PROJECT_DIR" -maxdepth 1 -name "docker-compose*.yml")

  if [ -z "$COMPOSE_FILES" ]; then
    echo "未找到任何 docker-compose 文件。"
    exit 1
  fi

  echo "找到以下 docker-compose 文件："
  print_table_header
  index=1
  for COMPOSE_FILE in $COMPOSE_FILES; do
    print_table_row "$index" "$(basename "$COMPOSE_FILE")"
    index=$((index + 1))
  done

  echo
  echo "選擇要啟動的 docker-compose 文件 (輸入 '編號' 或 'all' 啟動全部, 'exit' 退出):"
  read choice

  if [ "$choice" = "all" ]; then
    for COMPOSE_FILE in $COMPOSE_FILES; do
      start_docker_containers "$COMPOSE_FILE"
    done
  elif [ "$choice" = "exit" ]; then
    echo "終止操作。"
    exit 0
  else
    index=1
    for COMPOSE_FILE in $COMPOSE_FILES; do
      if [ "$index" -eq "$choice" ]; then
        start_docker_containers "$COMPOSE_FILE"
        break
      fi
      index=$((index + 1))
    done
  fi
}

# 打印表格標題
print_table_header() {
  printf "+-------+---------------------------------+\n"
  printf "| 編號  | docker-compose 文件              |\n"
  printf "+-------+---------------------------------+\n"
}

# 打印表格行
print_table_row() {
  printf "| %-5s | %-31s |\n" "$1" "$2"
  printf "+-------+---------------------------------+\n"
}

# 啟動 Docker 容器
start_docker_containers() {
  COMPOSE_FILE=$1
  echo "正在啟動 docker-compose 文件: $COMPOSE_FILE"
  docker-compose -f "$COMPOSE_FILE" up --build -d
  if [ $? -ne 0 ]; then
    echo "啟動 docker-compose 文件失敗: $COMPOSE_FILE"
    exit 1
  else
    echo "成功啟動 docker-compose 文件: $COMPOSE_FILE"
  fi
}

# 主函數
main() {
  find_compose_files
}

main