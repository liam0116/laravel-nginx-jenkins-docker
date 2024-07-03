#!/bin/bash

# -----------------------------------------------------------------------------
# 檢查 APP_KEY
# -----------------------------------------------------------------------------

# 獲取腳本當前目錄
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 獲取專案根目錄
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_PATH="$PROJECT_DIR/.env"

# 列出所有容器並讓用戶選擇
list_containers() {
  echo "找到以下容器："
  CONTAINER_IDS=$(docker ps -q)
  if [ -z "$CONTAINER_IDS" ]; then
    echo "未找到運行中的容器。"
    exit 1
  fi

  index=1
  CONTAINER_MAP_KEYS=()
  CONTAINER_MAP_VALUES=()
  print_table_header
  for CONTAINER_ID in $CONTAINER_IDS; do
    CONTAINER_NAME=$(docker inspect --format='{{.Name}}' "$CONTAINER_ID" | sed 's/^\/\([^\/]*\).*/\1/')
    CONTAINER_MAP_KEYS+=("$index")
    CONTAINER_MAP_VALUES+=("$CONTAINER_NAME")
    print_table_row "$index" "$CONTAINER_NAME"
    index=$((index + 1))
  done

  echo
  read -p "選擇要進行操作的容器 (輸入編號，輸入 'skip' 跳過): " choice

  if [ "$choice" = "skip" ]; then
    echo "跳過操作。"
    exit 0
  fi

  valid_choice=false
  for i in "${!CONTAINER_MAP_KEYS[@]}"; do
    if [ "${CONTAINER_MAP_KEYS[$i]}" -eq "$choice" ]; then
      TARGET_CONTAINER=${CONTAINER_MAP_VALUES[$i]}
      valid_choice=true
      break
    fi
  done

  if [ "$valid_choice" = false ]; then
    echo "無效的選擇，請重試。"
    exit 1
  fi

  echo "選擇的容器是: $TARGET_CONTAINER"
}

# 打印表格標題
print_table_header() {
  printf "+-------+-------------------------+\n"
  printf "| 編號  | 容器名稱                 |\n"
  printf "+-------+-------------------------+\n"
}

# 打印表格行
print_table_row() {
  printf "| %-5s | %-23s |\n" "$1" "$2"
  printf "+-------+-------------------------+\n"
}

# 檢查 APP_KEY 是否存在
check_app_key() {
  if [ ! -f "$ENV_PATH" ]; then
    echo "未找到 .env 文件，請先設置環境變量。"
    exit 1
  fi

  . "$ENV_PATH"

  if [ -z "$APP_KEY" ]; then
    echo "生成 Laravel 應用密鑰..."
    docker-compose exec "$TARGET_CONTAINER" php artisan key:generate
    if [ $? -ne 0 ]; then
      echo "生成 Laravel 應用密鑰失敗。"
      exit 1
    else
      echo "生成 Laravel 應用密鑰成功。"
    fi
  else
    echo "APP_KEY 已存在，跳過生成。"
  fi
}

# 主函數
main() {
  list_containers
  check_app_key
}

main