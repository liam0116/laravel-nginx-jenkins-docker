FROM php:8.3-fpm

# 設置主要參數
ARG APP_TIMEZONE
ARG APP_HOME
ARG APP_NAME

USER root

# 驗證參數是否有值
RUN echo "APP_TIMEZONE=${APP_TIMEZONE}" && \
    echo "APP_HOME=${APP_HOME}" && \
    echo "APP_NAME=${APP_NAME}"

# 安裝必要依賴並啟用 PHP 模塊
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
      procps \
      nano \
      git \
      unzip \
      libicu-dev \
      zlib1g-dev \
      libxml2 \
      libxml2-dev \
      libreadline-dev \
      supervisor \
      cron \
      sudo \
      libzip-dev \
      curl \
      libpng-dev \
      libonig-dev \
      libxml2-dev \
      libjpeg-dev \
      libfreetype6-dev \
      libwebp-dev \
      tzdata \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
      pdo_mysql \
      sockets \
      intl \
      opcache \
      zip \
      gd \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


# 設置時區
RUN ln -snf /usr/share/zoneinfo/${APP_TIMEZONE} /etc/localtime && echo ${APP_TIMEZONE} > /etc/timezone

# 設置工作目錄 cd到工作目錄的意思
WORKDIR ${APP_HOME}/${APP_NAME}

# 創建必要的目錄並設置適當的權限
RUN mkdir -p storage && \
    chmod -R 755 storage && \
    mkdir -p bootstrap/cache && \
    chmod -R 755 bootstrap/cache

# 创建必要的目录并设置适当的权限 跟 PHP/www.conf 里面的 user 和 group 有关
RUN mkdir -p storage bootstrap/cache && \
chown -R www-data:www-data storage bootstrap/cache && \
chmod -R 775 storage bootstrap/cache

# 切换到非 root 用户
USER www-data

# 容器啟動時執行的命令
CMD ["php-fpm"]
