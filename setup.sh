#!/bin/sh

# -----------------------------------------------------------------------------
# QROH 安裝腳本
# -----------------------------------------------------------------------------

set -e

readonly SCRIPT_VERSION="1.0.0"
readonly AUTHOR="liam"
readonly EMAIL="liam460116@gmail.com"

# 獲取當前時間
get_time() {
  DATE=$(date '+%Y-%m-%d %H:%M:%S')
}

# 顯示專案名稱和 logo, 可以使用以下網站生成 ASCII Art：
# https://www.ascii-generator.com/
# https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Red%20Phoenix&text=Your%20text%20here%20
# https://www.patorjk.com/software/taag/#p=display&f=Standard&t=QROH%20
show_logo() {
  clear
  echo "============================"
  echo "   ___  ____   ___  _   _   "                                 
  echo "  / _ \|  _ \ / _ \| | | |  " 
  echo " | | | | |_) | | | | |_| |  "
  echo " | |_| |  _ <| |_| |  _  |  "
  echo "  \__\_\_| \_\\___/|_| |_|  " 
  echo "============================"
  echo "作者: $AUTHOR"
  echo "郵件: $EMAIL"
  echo "版本號: $SCRIPT_VERSION"
  echo "執行時間: $DATE"
  echo "============================"
}

# 設置腳本路徑
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)/scripts"

# 執行各個設置步驟
run_setup_steps() {
  get_time
  
  echo "步驟 1: 檢查 Docker..."
  sh "$SCRIPTS_DIR/01_check_docker.sh"

  echo "步驟 2: 設置目錄權限..."
  sh "$SCRIPTS_DIR/02_set_directory_permissions.sh"

  echo "步驟 3: 檢查 Composer..."
  sh "$SCRIPTS_DIR/03_check_composer.sh"

  echo "步驟 4: 檢查 Docker 容器..."
  sh "$SCRIPTS_DIR/04_check_running_containers.sh"

  echo "步驟 5: 檢查 env..."
  sh "$SCRIPTS_DIR/05_setup_env.sh"

  echo "步驟 6: 啟動 Docker 容器..."
  sh "$SCRIPTS_DIR/06_start_docker_containers.sh"

  echo "步驟 7: 等待 MySQL 容器啟動..."
  sh "$SCRIPTS_DIR/07_wait_for_mysql.sh"

  echo "步驟 8: 檢查 APP_KEY..."
  sh "$SCRIPTS_DIR/08_check_app_key.sh"

  echo "步驟 9: 遷移數據庫..."
  sh "$SCRIPTS_DIR/09_migrate_database.sh"

  echo "環境設置完成！"
}

# 主函數
main() {
  show_logo
  run_setup_steps
}

main