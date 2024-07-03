#!/bin/bash

# -----------------------------------------------------------------------------
#  檢查是否有正在運行的容器
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
  for file in $COMPOSE_FILES; do
    print_table_row "$index" "$file"
    index=$((index + 1))
  done
}

# 打印表格標題
print_table_header() {
  printf "+-------+-------------------------------------------------------------+\n"
  printf "| 編號  | docker-compose 文件                                         |\n"
  printf "+-------+-------------------------------------------------------------+\n"
}

# 打印表格行
print_table_row() {
  printf "| %-5s | %-59s |\n" "$1" "$2"
  printf "+-------+-------------------------------------------------------------+\n"
}

# 檢查是否有正在運行的容器
check_running_containers() {
  for DOCKER_COMPOSE_FILE in $COMPOSE_FILES; do
    echo "檢查文件 $DOCKER_COMPOSE_FILE 中的容器..."
    
    # 檢查是否有正在運行的容器
    SERVICES=$(grep 'container_name:' "$DOCKER_COMPOSE_FILE" | awk '{print $2}')
    RUNNING_CONTAINERS=$(docker ps -q --filter "name=$(echo $SERVICES | tr '\n' '|')")

    if [ ! -z "$RUNNING_CONTAINERS" ]; then
      echo "已檢測到正在運行的容器："
      docker ps --filter "name=$(echo $SERVICES | tr '\n' '|')"
      read -p "選擇操作: 停止並刪除這些容器(d)，暫停這些容器(p)，查看容器詳細信息(v)，退出腳本(e) : " choice
      case "$choice" in
        d|D )
          confirm_action "你確定要停止並刪除這些容器嗎？" "docker-compose -f \"$DOCKER_COMPOSE_FILE\" down"
          ;;
        p|P )
          confirm_action "你確定要暫停這些容器嗎？" "docker-compose -f \"$DOCKER_COMPOSE_FILE\" stop"
          ;;
        v|V )
          view_container_details
          ;;
        e|E )
          echo "退出腳本。"
          exit 1
          ;;
        * )
          echo "無效的選擇，請手動處理這些容器。"
          exit 1
          ;;
      esac
    else
      echo "未檢測到運行的容器。"
    fi
  done
}

# 確認操作
confirm_action() {
  local message="$1"
  local command="$2"
  
  read -p "$message (y/n): " confirm
  case "$confirm" in
    y|Y )
      eval $command
      ;;
    n|N )
      echo "操作已取消。"
      exit 1
      ;;
    * )
      echo "無效的選擇，操作已取消。"
      exit 1
      ;;
  esac
}

# 查看容器詳細信息
view_container_details() {
  echo "容器詳細信息："
  docker inspect $(docker ps -q --filter "name=$(echo $SERVICES | tr '\n' '|')")
  exit 1
}

# 主函數
main() {
  echo "查找 docker-compose 文件..."
  find_compose_files

  echo "檢查是否有正在運行的容器..."
  read -p "選擇要檢查的容器 (輸入 '編號' 或 'all' 檢查全部, 'exit' 退出): " file_choice
  if [ "$file_choice" = "all" ]; then
    check_running_containers
  elif [ "$file_choice" = "exit" ]; then
    echo "終止檢查。"
    exit 1
  else
    index=1
    for file in $COMPOSE_FILES; do
      if [ "$index" -eq "$file_choice" ]; then
        COMPOSE_FILES=$file
        break
      fi
      index=$((index + 1))
    done
    check_running_containers
  fi
}

main