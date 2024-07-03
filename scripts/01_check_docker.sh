#!/bin/bash

# -----------------------------------------------------------------------------
# 檢查 Docker 是否安裝
# -----------------------------------------------------------------------------

# 檢查操作系統並設置 OS 變量
detect_os() {
  if [ "$(uname)" = "Linux" ]; then
    OS="Linux"
  elif [ "$(uname)" = "Darwin" ]; then
    OS="Darwin"
  elif [ "$(uname -o 2>/dev/null)" = "Msys" ] || [ "$(uname -o 2>/dev/null)" = "Cygwin" ]; then
    OS="Windows"
  else
    OS=$(powershell -Command "if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') { Write-Output 'Windows' }")
  fi
  echo "檢測到的操作系統: $OS"
}

# 打印表格行
print_table_row() {
  printf "| %-20s | %-60s |\n" "$1" "$2"
}

# 打印表格邊框
print_table_separator() {
  printf "+----------------------+------------------------------------------------------------+\n"
}

# 檢查並打印 Docker 和 Docker Compose 信息
check_docker() {
  DOCKER_VERSION="未安裝"
  DOCKER_COMPOSE_VERSION="未安裝"

  if [ -x "$(command -v docker)" ]; then
    DOCKER_VERSION=$(docker --version)
  fi

  if [ -x "$(command -v docker-compose)" ]; then
    DOCKER_COMPOSE_VERSION=$(docker-compose --version)
  fi

  echo "檢查 Docker 和 Docker Compose 安裝情況..."
  print_table_separator
  print_table_row "軟件" "版本信息"
  print_table_separator
  print_table_row "Docker" "$DOCKER_VERSION"
  print_table_row "Docker Compose" "$DOCKER_COMPOSE_VERSION"
  print_table_separator

  case $OS in
    Linux)
      if [ "$DOCKER_VERSION" = "未安裝" ]; then
        read -p "Docker 未安裝。是否要自動安裝 Docker？(y/n): " choice
        case "$choice" in
          y|Y )
            echo "自動安裝 Docker..."
            curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
            if [ $? -ne 0 ]; then
              echo "Docker 安裝失敗。"
              exit 1
            fi
            ;;
          n|N )
            echo "請自行安裝 Docker。"
            exit 1
            ;;
          * )
            echo "無效的選擇，腳本終止。"
            exit 1
            ;;
        esac
      else
        echo "Docker 已安裝。版本信息: $DOCKER_VERSION"
      fi

      if [ "$DOCKER_COMPOSE_VERSION" = "未安裝" ]; then
        read -p "Docker Compose 未安裝。是否要自動安裝 Docker Compose？(y/n): " choice
        case "$choice" in
          y|Y )
            echo "自動安裝 Docker Compose..."
            sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            if [ $? -ne 0 ]; then
              echo "Docker Compose 安裝失敗。"
              exit 1
            fi
            ;;
          n|N )
            echo "請自行安裝 Docker Compose。"
            exit 1
            ;;
          * )
            echo "無效的選擇，腳本終止。"
            exit 1
            ;;
        esac
      else
        echo "Docker Compose 已安裝。版本信息: $DOCKER_COMPOSE_VERSION"
      fi
      ;;
    Darwin)
      if [ "$DOCKER_VERSION" = "未安裝" ]; then
        echo "Error: Docker is not installed. 請訪問以下官方鏈接安裝 Docker："
        echo "https://docs.docker.com/desktop/mac/install/"
        exit 1
      else
        echo "Docker 已安裝。版本信息: $DOCKER_VERSION"
      fi
      if [ "$DOCKER_COMPOSE_VERSION" = "未安裝" ]; then
        echo "Error: Docker Compose is not installed. 請訪問以下官方鏈接安裝 Docker Compose："
        echo "https://docs.docker.com/compose/install/"
        exit 1
      else
        echo "Docker Compose 已安裝。版本信息: $DOCKER_COMPOSE_VERSION"
      fi
      ;;
    Windows)
      if [ "$DOCKER_VERSION" = "未安裝" ]; then
        echo "Error: Docker is not installed. 請訪問以下鏈接安裝 Docker："
        echo "https://docs.docker.com/desktop/windows/install/"
        exit 1
      else
        echo "Docker 已安裝。版本信息: $DOCKER_VERSION"
      fi
      if [ "$DOCKER_COMPOSE_VERSION" = "未安裝" ]; then
        echo "Error: Docker Compose is not installed. 請訪問以下鏈接安裝 Docker Compose："
        echo "https://docs.docker.com/compose/install/"
        exit 1
      else
        echo "Docker Compose 已安裝。版本信息: $DOCKER_COMPOSE_VERSION"
      fi
      ;;
    *)
      echo "暫時不支持的操作系统."
      exit 1
      ;;
  esac
}

# 主函數
main() {
  echo "開始檢查 Docker 和 Docker Compose 安裝情況..."
  detect_os
  check_docker
  echo "檢查完成。"
}

main