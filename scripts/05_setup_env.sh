#!/bin/bash

# -----------------------------------------------------------------------------
# 設置 env 變量
# -----------------------------------------------------------------------------

# 環境變量目錄，可以在此處設定未來的環境變量目錄名稱
# ENV_DIR="env"  # 存放 .env 文件的目錄
# TEMPLATE_DIR="template"  # 存放 .env.example 文件的模板目錄

# 查找並設置所有 .env 文件及其模板文件
find_env_files() {
  # 獲取腳本當前目錄
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # 獲取專案根目錄
  PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

  # 如果設置了模板文件目錄，則在該目錄中查找
  if [ -n "$TEMPLATE_DIR" ]; then
    TEMPLATE_DIR_PATH="$PROJECT_DIR/$TEMPLATE_DIR"
    ENV_FILES=$(find "$TEMPLATE_DIR_PATH" -maxdepth 1 -name "*.example")
  else
    ENV_FILES=$(find "$PROJECT_DIR" -maxdepth 1 -name "*.example")
  fi

  # 檢查是否找到任何模板文件
  if [ -z "$ENV_FILES" ]; then
    echo "未找到任何 .env.example 文件。"
    exit 1
  fi

  # 建立對應的 .env 文件列表
  ENV_FILES_MAP_KEYS=()
  ENV_FILES_MAP_VALUES=()

  for TEMPLATE_FILE in $ENV_FILES; do
    ENV_FILE=$(basename "$TEMPLATE_FILE" .example)
    ENV_FILES_MAP_KEYS+=("$ENV_FILE")
    ENV_FILES_MAP_VALUES+=("$TEMPLATE_FILE")
  done

  echo "找到以下 .env 文件及其模板文件："
  print_table_header
  index=1
  for i in "${!ENV_FILES_MAP_KEYS[@]}"; do
    print_table_row "$index" "${ENV_FILES_MAP_KEYS[$i]}" "$(basename "${ENV_FILES_MAP_VALUES[$i]}")"
    index=$((index + 1))
  done

  echo
  echo "選擇要檢查的 .env 文件 (輸入 '編號' 或 'all' 檢查全部, 'exit' 退出):"
  read choice

  if [ "$choice" = "all" ]; then
    for i in "${!ENV_FILES_MAP_KEYS[@]}"; do
      process_env_file "${ENV_FILES_MAP_KEYS[$i]}" "${ENV_FILES_MAP_VALUES[$i]}"
    done
  elif [ "$choice" = "exit" ]; then
    echo "終止檢查。"
    exit 0
  else
    index=1
    for i in "${!ENV_FILES_MAP_KEYS[@]}"; do
      if [ "$index" -eq "$choice" ]; then
        process_env_file "${ENV_FILES_MAP_KEYS[$i]}" "${ENV_FILES_MAP_VALUES[$i]}"
        break
      fi
      index=$((index + 1))
    done
  fi
}

# 打印表格標題
print_table_header() {
  printf "+-------+-------------------------+-------------------------+\n"
  printf "| 編號  | .env 文件               | 模板文件                |\n"
  printf "+-------+-------------------------+-------------------------+\n"
}

# 打印表格行
print_table_row() {
  printf "| %-5s | %-23s | %-23s |\n" "$1" "$2" "$3"
  printf "+-------+-------------------------+-------------------------+\n"
}

# 檢查並設置環境變量的函數
set_env_variable() {
  local var_name=$1
  local prompt_message=$2
  local is_password=$3

  eval "local current_value=\$$var_name"

  if [ -z "$current_value" ]; then
    while true; do
      if [ "$is_password" = true ]; then
        read -sp "$prompt_message" new_value
        echo
      else
        read -p "$prompt_message" new_value
      fi

      if [ "$var_name" = "DB_USERNAME" ] && [ "$new_value" = "root" ];then
        echo "資料庫用戶名不能為 root，請重新輸入。"
      else
        break
      fi
    done
    sed -i "s/$var_name=.*/$var_name=${new_value}/" "$ENV_PATH"
  else
    echo "$var_name 已經設定。"
  fi
}

# 根據不同的 .env 文件檢查設置不同的環境變量
setup_env_variables() {
  case "$ENV_FILE" in
    ".env")
      set_env_variable "DB_HOST" "請輸入資料庫主機 (DB_HOST，填寫容器名稱如 mysql，除非有設定 ip):"
      set_env_variable "DB_PORT" "請輸入資料庫端口 (DB_PORT，例如 3306):"
      set_env_variable "DB_DATABASE" "請輸入資料庫名稱 (DB_DATABASE，例如 laravel):"
      set_env_variable "DB_USERNAME" "請輸入資料庫用戶名 (DB_USERNAME，例如 qroh):"
      set_env_variable "DB_PASSWORD" "請輸入資料庫密碼 (DB_PASSWORD):" true
      set_env_variable "DB_ROOT_PASSWORD" "請輸入資料庫根密碼 (DB_ROOT_PASSWORD):" true
      ;;
    ".env.payway")
      set_env_variable "PAYWAY_API_KEY" "請輸入支付接口金鑰 (PAYWAY_API_KEY):"
      set_env_variable "PAYWAY_SECRET" "請輸入支付接口密鑰 (PAYWAY_SECRET):" true
      ;;
    *)
      echo "未知的 .env 文件配置。"
      ;;
  esac
}

# 檢查 .env 文件是否存在，並詢問用戶輸入缺失的參數
setup_env() {
  if [ ! -f "$ENV_PATH" ];then
    cp "$ENV_EXAMPLE_PATH" "$ENV_PATH"
    echo "$ENV_PATH 文件已創建，請輸入以下參數："
  else
    echo "$ENV_PATH 文件已經存在，將檢查並設置缺失的參數。"
    . "$ENV_PATH"
  fi

  setup_env_variables
}

# 處理單個 .env 文件
process_env_file() {
  ENV_FILE=$1
  ENV_EXAMPLE_FILE=$2

  if [ -n "$ENV_DIR" ];then
    ENV_PATH="$PROJECT_DIR/$ENV_DIR/$ENV_FILE"
  else
    ENV_PATH="$PROJECT_DIR/$ENV_FILE"
  fi

  ENV_EXAMPLE_PATH="$ENV_EXAMPLE_FILE"

  if [ ! -f "$ENV_EXAMPLE_PATH" ];then
    echo "未找到 $ENV_EXAMPLE_PATH 文件，無法創建 $ENV_FILE。"
    return
  fi

  echo "正在處理 $ENV_FILE 文件..."
  setup_env
}

# 主函數
main() {
  find_env_files
}

main