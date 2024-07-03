# QROH Laravel API

## 目錄結構
```
QROrderHub/
├── jenkins/           # Jenkins 項目文件
│ └── jenkins 項目文件
├── nginx/             # Nginx 配置文件
│ └── default.conf     # Nginx 伺服器配置文件
├── PHP/               # PHP 配置文件
│ └── php.ini          # PHP 配置文件
│ └── www.conf         # PHP-FPM 的 www 配置文件
├── scripts/           # 脚本文件
│ └── 安裝和管理腳本
├── supervisord/       # Supervisord 配置文件
│ └── cron             # Cron 配置文件，定義定時任務
│ └── supervisord.conf # Supervisord 主配置文件，定義和管理各個進程
├── src/               # Laravel 項目文件
│ └── Laravel 應用程式代碼和資源
├── .gitignore         # Git 忽略文件配置，定義哪些文件不應該提交到版本控制
├── .env.example       # 環境變量範例文件，用於創建 .env 文件
├── .env               # 環境變量文件，儲存應用的環境設置
├── .dockerignore      # Docker 忽略文件配置，定義哪些文件不應該包含在 Docker 鏡像中
├── docker-compose.yml # Docker Compose 配置文件，定義多個 Docker 容器的服務設置
├── Dockerfile         # Docker 構建文件，定義如何構建 Docker 容器
├── Dockerfile.nginx   # Nginx 的 Docker 構建文件，定義如何構建 Nginx 容器
├── README.md          # 項目說明文件，提供項目概述和說明
└── setup.sh           # 安裝腳本，用於初始設置和配置
```
## 簡介

這是一個使用 Laravel 框架構建的 API 項目，並使用 Docker 容器進行開發和部署。本文檔將介紹如何設置、運行和維護該項目。

## 簡單説明

### 啟動容器

1. 構建並啟動安裝脚本：
    ```sh
    sh ./setup.sh
    ```

## Dockerfile 和 docker-compose 指令

### docker-compose.yml

- 定義多個服務，包括 `nginx`, `backend`, `mysql`, `redis`, `jenkins` 和 `mail`。
- 設置容器的環境變量、端口映射和卷。
- 使用 `depends_on` 設置服務之間的依賴關係。

### 常用指令

- 構建並啟動容器：
    ```sh
    docker-compose up --build -d
    ```

- 停止並刪除容器：
    ```sh
    docker-compose down
    ```

- 查看容器日誌：
    ```sh
    docker-compose logs <service_name>
    ```

- 進入容器內部：
    ```sh
    docker-compose exec <service_name> /bin/sh
    ```

### 維護

- 定期檢查和更新依賴：
    ```sh
    docker-compose exec backend composer update
    ```

- 定期備份數據庫：
   ```sh
    docker-compose exec mysql mysqldump -u root -p\${DB_ROOT_PASSWORD} \${DB_DATABASE} > backup.sql
   ```

- 檢查容器狀態：
    ```sh
    docker-compose ps
    ```

### 訪問應用
- jenkins: http://localhost:8080/login?from=%2F
- laravel: http://localhost:80/
- mysql: localhost:3306 
  
### jenkins
需要打開log取得取得管理員密鑰如下範例
```
2024-07-02 23:52:17 2024-07-02 15:52:17.552+0000 [id=43]        INFO    jenkins.install.SetupWizard#init: 
2024-07-02 23:52:17 
2024-07-02 23:52:17 *************************************************************
2024-07-02 23:52:17 *************************************************************
2024-07-02 23:52:17 *************************************************************
2024-07-02 23:52:17 
2024-07-02 23:52:17 Jenkins initial setup is required. An admin user has been created and a password generated.
2024-07-02 23:52:17 Please use the following password to proceed to installation:
2024-07-02 23:52:17 
2024-07-02 23:52:17 xxxxxxxxfasfdfaszxxxxxxxxxxxxx
2024-07-02 23:52:17 
2024-07-02 23:52:17 This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
2024-07-02 23:52:17 
2024-07-02 23:52:17 *************************************************************
2024-07-02 23:52:17 *************************************************************
2024-07-02 23:52:17 *************************************************************
2024-07-02 23:52:17
```

### DBeaver 鏈接的時候記得設定

配置 JDBC 驅動參數：

- 點擊 "Edit Driver Settings" 按鈕（鉛筆圖標）。
- 在打開的窗口中，選擇 "Driver properties" 標籤。
- 找到或添加 allowPublicKeyRetrieval 屬性，將其值設置為 true。
- 如果找不到該屬性，可以手動添加：
  - 點擊 "Add new property" 按鈕。
  - 在 "Property" 欄位中輸入 allowPublicKeyRetrieval。
  - 在 "Value" 欄位中輸入 true。