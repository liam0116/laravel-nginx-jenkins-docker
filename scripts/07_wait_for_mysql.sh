#!/bin/bash

# -----------------------------------------------------------------------------
# 等待 MySQL 容器啟動
# -----------------------------------------------------------------------------

# 環境變量目錄，可以在此處設定未來的環境變量目錄名稱
ENV_DIR="env"  # 存放 .env 文件的目錄

# 打印表格標題
print_table_header() {
  printf "+-------+-------------------------+\n"
  printf "| 編號  | .env 文件               |\n"
  printf "+-------+-------------------------+\n"
}

# 打印表格行
print_table_row() {
  printf "| %-5s | %-23s |\n" "$1" "$2"
  printf "+-------+-------------------------+\n"
}

# 列出所有 .env 文件並讓用戶選擇
list_env_files() {
  echo "找到以下 .env 文件："

  if [ -n "$ENV_DIR" ] && [ -d "$PROJECT_DIR/$ENV_DIR" ]; then
    ENV_FILES=$(find "$PROJECT_DIR/$ENV_DIR" -maxdepth 1 -name "*.env")
  else
    ENV_FILES=$(find "$PROJECT_DIR" -maxdepth 1 -name "*.env")
  fi

  if [ -z "$ENV_FILES" ]; then
    echo "未找到任何 .env 文件。"
    exit 1
  fi

  index=1
  ENV_MAP_KEYS=()
  ENV_MAP_VALUES=()
  print_table_header
  for ENV_FILE in $ENV_FILES; do
    ENV_MAP_KEYS+=("$index")
    ENV_MAP_VALUES+=("$ENV_FILE")
    print_table_row "$index" "$(basename $ENV_FILE)"
    index=$((index + 1))
  done

  echo
  echo "請選擇要使用的 .env 文件，這些文件包含了檢查 MySQL 容器啟動所需的 DB_HOST 和 DB_PORT 配置。"
  read -p "選擇要使用的 .env 文件 (輸入編號): " choice

  valid_choice=false
  for i in "${!ENV_MAP_KEYS[@]}"; do
    if [ "${ENV_MAP_KEYS[$i]}" -eq "$choice" ]; then
      ENV_PATH=${ENV_MAP_VALUES[$i]}
      valid_choice=true
      break
    fi
  done

  if [ "$valid_choice" = false ]; then
    echo "無效的選擇，請重試。"
    exit 1
  fi

  echo "選擇的 .env 文件是: $(basename $ENV_PATH)"
}

# 讀取 .env 文件中的 DB_HOST 和 DB_PORT
load_env_variables() {
  if [ ! -f "$ENV_PATH" ]; then
    echo "未找到 .env 文件，請先設置環境變量。"
    exit 1
  fi

  . "$ENV_PATH"

  if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ]; then
    echo "未找到 DB_HOST 或 DB_PORT，請檢查 .env 文件。"
    exit 1
  fi
}

# 等待 MySQL 容器啟動
wait_for_mysql() {
  echo "檢查 MySQL 容器..."

  # 獲取 MySQL 容器名稱
  MYSQL_CONTAINER_NAME=$(docker-compose ps | grep 'mysql' | awk '{print $1}')

  if [ -z "$MYSQL_CONTAINER_NAME" ]; then
    read -p "未檢測到默認 MySQL 容器。您是否使用外部 MySQL 伺服器？(y/n): " use_external
    if [ "$use_external" = "y" ]; then
      echo "使用外部 MySQL 伺服器，退出啟動檢查。"
      exit 0
    else
      read -p "請輸入 MySQL 容器名稱: " custom_container_name
      MYSQL_CONTAINER_NAME=$custom_container_name
      # 再次檢查自定義的容器名稱是否存在
      if [ -z "$(docker-compose ps | grep "$MYSQL_CONTAINER_NAME")" ]; then
        echo "未檢測到 MySQL 容器 $MYSQL_CONTAINER_NAME。請檢查容器名稱並重試。"
        exit 1
      fi
    fi
  fi

  echo "等待 MySQL 容器 $MYSQL_CONTAINER_NAME 啟動..."
  sleep 10
  MAX_RETRIES=5 # 最大重試次數為5次
  RETRY_COUNT=0 # 初始重試次數為0
  while ! docker-compose exec "$MYSQL_CONTAINER_NAME" mysqladmin ping -h "${DB_HOST}" -P "${DB_PORT}" --silent; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
      echo "MySQL 容器啟動超時，請檢查容器日誌。"
      exit 1
    fi
    echo "MySQL 還未啟動，等待 10 秒..."
    sleep 10
  done
  echo "MySQL 已啟動."
}

# 主函數
main() {
  # 獲取腳本當前目錄
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # 獲取專案根目錄
  PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

  list_env_files
  load_env_variables
  wait_for_mysql
}

main