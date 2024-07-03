#!/bin/bash

# -----------------------------------------------------------------------------
# 設置目錄權限
# -----------------------------------------------------------------------------

# 檢查操作系統
check_os() {
  OS="$(uname)"
}

# 設置目錄權限
set_directory_permissions() {
  case "$OS" in
    Linux|Darwin)
      echo "設置 storage 目錄權限..."
      chmod -R 777 src/storage
      if [ $? -ne 0 ]; then
        echo "設置 storage 目錄權限失敗。"
        exit 1
      fi
      
      echo "設置 bootstrap/cache 目錄權限..."
      chmod -R 777 src/bootstrap/cache
      if [ $? -ne 0 ]; then
        echo "設置 bootstrap/cache 目錄權限失敗。"
        exit 1
      fi
      ;;
    *)
      echo "非 Linux 或 MacOS 系統，跳過目錄權限設置。"
      ;;
  esac
}

# 主函數
main() {
  check_os
  set_directory_permissions
}

main