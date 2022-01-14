#!/usr/bin/env bash

# /***************************
# @File        : etcd_install.sh
# @Time        : 2021/12/15 15:12:11
# @AUTHOR      : small_ant
# @Email       : xms.chnb@gmail.com
# @Desc        : 通过sh 脚本来安装etcd 并配置etcd
# ****************************/

etcdPath="/root"
etcdConf="/etc/etcd"
etcProfile="/etc/profile"
etcdDataDir="/var/lib/etcd"
etcdService="/var/lib/systemd"
LOCALIP=$(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:")
COMMONIP=$(curl ifconfig.me)
# 下载etcd3.5.0版本
function download() {
    git clone -b v3.5.0 https://github.com.cnpmjs.org/etcd-io/etcd.git
}

function createconf() {
    echo "创建etcd配置文件,当前机器网络状况,y公网,n局域网[y/n]"
    touch $etcdConf/etcd.conf
    echo "name: etcd" | tee -a $etcdConf/etcd.conf
    echo "data-dir: $etcdDataDir" | tee -a $etcdConf/etcd.conf

    read -p "[y/n]" isCommon
    if [ "$isCommon" = "y" ]; then
        echo "initial-advertise-peer-urls: http://$COMMONIP:2380" | tee -a $etcdConf/etcd.conf
        echo "listen-peer-urls: http://$COMMONIP:2380" | tee -a $etcdConf/etcd.conf
        echo "listen-client-urls: http://$COMMONIP:2379,http://127.0.0.1:2379" | tee -a $etcdConf/etcd.conf
        echo "advertise-client-urls: http://$COMMONIP:2379" | tee -a $etcdConf/etcd.conf

    else
        echo "initial-advertise-peer-urls: http://$LOCALIP:2380" | tee -a $etcdConf/etcd.conf
        echo "listen-peer-urls: http://$LOCALIP:2380" | tee -a $etcdConf/etcd.conf
        echo "listen-client-urls: http://$LOCALIP:2379,http://127.0.0.1:2379" | tee -a $etcdConf/etcd.conf
        echo "advertise-client-urls: http://$LOCALIP:2379" | tee -a $etcdConf/etcd.conf
    fi
    echo "discovery: https://discovery.etcd.io/" | tee -a $etcdConf/etcd.conf
    echo "election-timeout: 5000" | tee -a $etcdConf/etcd.conf
    echo "heartbeat-interval: 500" | tee -a $etcdConf/etcd.conf
}

function createService() {
    touch $etcdService/etcd.service
    echo "[Unit]" | tee -a $etcdService/etcd.service
    echo "Description=Etcd Server" | tee -a $etcdService/etcd.service
    echo "After=network.target" | tee -a $etcdService/etcd.service
    echo "After=network-online.target" | tee -a $etcdService/etcd.service
    echo "Wants=network-online.target" | tee -a $etcdService/etcd.service
    echo "[Service]" | tee -a $etcdService/etcd.service
    echo "Type=notify" | tee -a $etcdService/etcd.service
    echo "WorkingDirectory=/var/lib/etcd/" | tee -a $etcdService/etcd.service
    echo "ExecStart=/root/etcd/bin/etcd --config-file /etc/etcd/etcd.conf" | tee -a $etcdService/etcd.service
    echo "Restart=always" | tee -a $etcdService/etcd.service
    echo "ExecReload=/bin/kill -SIGHUP $MAINPID" | tee -a $etcdService/etcd.service
    echo "ExecStop=/bin/kill -SIGINT $MAINPID" | tee -a $etcdService/etcd.service
    echo "RestartSec=5" | tee -a $etcdService/etcd.service
    echo "[Install]" | tee -a $etcdService/etcd.service
    echo "WantedBy=deftault.target" | tee -a $etcdService/etcd.service
    echo "success config etcd.service,now you can start it as [systemctl start etcd.service]"
}

function addenv() {
    echo "export PATH=$PATH:$(pwd)/bin" | tee -a $etcProfile
    source $etcProfile
}

# 初始化安装路径
function init() {
    mkdir -p $etcdConf
    mkdir -p $etcdDataDir
    cd $etcdPath || exit
}

function removeEtcd() {
    rm -r $etcdPath
    rm -r $etcdConf
    rm -r /var/lib/etcd
    rm $etcdService/etcd.service
}

function install() {
    init
    download
    cd "etcd" || exit
    $(./build.sh)
    addenv
    echo "安装etcd成功"
    createconf
    createService
}

echo "检测当前是否存在etcd版本"
v=$(etcd --version)
if [ -z "$v" ]; then
    echo "当前未找到etcd版本是否下载etcd3.5.0 for you"
    read -p "[y/n]" isDownload
    if [ "$isDownload" = "y" ]; then
        install
    fi
else
    echo "当前版本为${v}"
    echo "是否删除当前版本下载3.5.0 for ubuntu[y/n]"
    read -p "[y/n]" isDownload
    if [ "$isDownload" = "y" ]; then
        removeEtcd
        install
    fi
fi
