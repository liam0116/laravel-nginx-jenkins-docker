#!/bin/bash

# -----------------------------------------------------------------------------
# 檢查 Composer 是否安裝
# -----------------------------------------------------------------------------

# 打印表格行
print_table_row() {
  printf "| %-20s | %-60s |\n" "$1" "$2"
}

# 打印表格邊框
print_table_separator() {
  printf "+----------------------+------------------------------------------------------------+\n"
}

# 檢查並打印 Composer 信息
check_composer() {
  COMPOSER_VERSION="未安裝"

  if [ -x "$(command -v composer)" ]; then
    COMPOSER_VERSION=$(composer --version | head -n 1)
  fi

  echo "檢查 Composer 安裝情況..."
  print_table_separator
  print_table_row "軟件" "版本信息"
  print_table_separator
  print_table_row "Composer" "$COMPOSER_VERSION"
  print_table_separator

  if [ "$COMPOSER_VERSION" = "未安裝" ]; then
    read -p "Composer 未安裝。是否要自動安裝 Composer？(y/n): " choice
    case "$choice" in
      y|Y )
        echo "自動安裝 Composer..."
        curl -sS https://getcomposer.org/installer | php
        sudo mv composer.phar /usr/local/bin/composer
        if [ $? -ne 0 ]; then
          echo "Composer 安裝失敗。"
          exit 1
        fi
        ;;
      n|N )
        echo "請自行安裝 Composer。"
        exit 1
        ;;
      * )
        echo "無效的選擇，腳本終止。"
        exit 1
        ;;
    esac
  else
    echo "Composer 已安裝。版本信息: $COMPOSER_VERSION"
  fi
}

# 切換到 src 目錄並執行 composer install
install_dependencies() {
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
  SRC_DIR="$PROJECT_DIR/src"

  if [ ! -d "$SRC_DIR" ]; then
    echo "src 目錄不存在。"
    exit 1
  fi

  if [ ! -f "$SRC_DIR/composer.json" ]; then
    echo "composer.json 文件不存在於 src 目錄。"
    exit 1
  fi

  echo "切換到 src 目錄並執行 composer install..."
  cd "$SRC_DIR"
  composer install -v -n
  if [ $? -ne 0 ]; then
    echo "composer install 失敗。"
    exit 1
  fi
  echo "composer install 完成。"
}

# 主函數
main() {
  echo "開始檢查 Composer 安裝情況..."
  check_composer
  install_dependencies
  echo "檢查完成。"
}

main