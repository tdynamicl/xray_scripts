#!/bin/bash

### 参数配置
PWD=$(cd `dirname $0`; pwd)
CONF_FILE_PATH="./config.ini"
# 配置中的参数
DOMAIN=$(awk -F '=' '/\[main\]/{a=1}a==1&&$1~/domain/{print $2;exit}' ${CONF_FILE_PATH})

### 函数
# 打印日志函数
function echo_log () {
  echo `date +"[%Y-%m-%d %H:%M:%S] "`"$1" >> "${PWD}/${0}.log"
}

### 开始
echo_log 'Ssl cert renew start'

# test param
if [ ! -n "$DOMAIN" ]
then
  echo_log 'Config is empty, exit!'
  exit
fi

systemctl stop nginx
systemctl stop xray
echo 'nginx xray stopped' >> "${PWD}/${0}.log"
/root/.acme.sh/acme.sh --issue --force --standalone -d $DOMAIN --keylength ec-256 >> "${PWD}/${0}.log"
/root/.acme.sh/acme.sh --install-cert -d $DOMAIN --ecc --fullchain-file /home/www/ssl-cert/cert.pem --key-file /home/www/ssl-cert/key.pem >> "${PWD}/${0}.log"
chmod 644 /home/www/ssl-cert/*
systemctl start nginx
systemctl start xray
echo 'nginx xray started' >> "${PWD}/${0}.log"

echo_log 'Renew complete'
