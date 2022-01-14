#!/usr/bin/env bash

# /***************************
# @File        : golang_install.sh
# @Time        : 2021/12/15 15:13:53
# @AUTHOR      : small_ant
# @Email       : xms.chnb@gmail.com
# @Desc        : 通过shell脚本安装golang
# ****************************/

#wget https://storage.googleapis.com/golang/go1.7.linux-amd64.tar.gz go1.7.tar.gz
goroot="/usr/local/go"
gopath="/root/go"
etcProfile="/etc/profile"
exportGoroot="export GOROOT=$goroot"
exportGopath="export GOPATH=$gopath"

function download() {
    wget -c https://dl.google.com/go/go1.17.5.linux-amd64.tar.gz -O - | tar -xz -C /usr/local
}

function install() {
    download
    addenv
}

function info() {
    echo -e "\033[1;34m$1 \033[0m"
}

function warn() {
    echo -e "\033[0;33m$1 \033[0m"
}

function error() {
    echo -e "\033[0;31m$1 \033[0m"
}

function usage() {
    info "install golang for 1.17.5"
    info "USAGE:"
    info " ./upgrade.sh tar_file gopath"
    info " tar_file specify where is the tar file of go binary file"
    info " gopath specify where is the go workspace, include src, bin, pkg folder"
}

function addenv() {
    echo "$exportGoroot" | tee -a $etcProfile
    echo "$exportGopath" | tee -a $etcProfile
    source $etcProfile
    echo "export PATH=$GOROOT/bin:$GOPATH/bin:$PATH" | tee -a $etcProfile
    go env -w GO111MODULE=on
    go env -w GOPROXY=https://goproxy.cn,direct
    source $etcProfile
    info "golang 1.17.5 安装完毕"
}

function removeGoroot() {
    rm -r $goroot
    rm -r $gopath
}

function createGoPath() {
    if [ ! -d $gopath ]; then
        mkdir -p $gopath
    fi
    if [ ! -d "$gopath/src" ]; then
        mkdir "$gopath/src"
    fi
    if [ ! -d "$gopath/bin" ]; then
        mkdir "$gopath/bin"
    fi
    if [ ! -d "$gopath/pkg" ]; then
        mkdir "$gopath/pkg"
    fi
}

info 检测是否存在golang环境
v=$(go version)

if [ -z $v ]; then
    info "当前未找到golang环境,是否下载golang1.17.5 for ubuntu[y/n]"
    read -p "[y/n]" isDownload
    if [ "$isDownload" = "y" ]; then
        install
    fi
else
    info "当前版本为${v}"
    info "是否删除当前下载golang1.17.5 for ubuntu[y/n]"
    read -p "[y/n]" isDownload
    if [ "$isDownload" = "y" ]; then
        removeGoroot
        install
    fi
fi
