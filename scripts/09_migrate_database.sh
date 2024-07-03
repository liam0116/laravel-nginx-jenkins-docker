#!/bin/bash

# -----------------------------------------------------------------------------
# 遷移數據庫
# -----------------------------------------------------------------------------

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
  read -p "選擇要進行數據遷移的容器 (輸入編號，輸入 'skip' 跳過): " choice

  if [ "$choice" = "skip" ]; then
    echo "跳過數據遷移。"
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
    exit 0
  fi

  echo "選擇的容器是: $TARGET_CONTAINER"
}

# 執行數據遷移
migrate_database() {
  echo "在容器 $TARGET_CONTAINER 中進行數據遷移..."
  docker-compose exec "$TARGET_CONTAINER" php artisan migrate
  if [ $? -ne 0 ]; then
    echo "數據遷移失敗。"
    exit 0
  else
    echo "數據遷移成功。"
  fi
}

# 主函數
main() {
  list_containers
  migrate_database
}

main