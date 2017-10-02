#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

bit=`uname -m`
dir=`pwd`

installbbr(){
	#Install GCC
	apt-get update
	apt-get install linux-image-4.9.0-3-amd64 linux-image-amd64 linux-headers-4.9.0-3-amd64 -y
	apt-get install build-essential make gcc -y
	update-grub
	echo -e "\033[42;37m[注意]\033[0m 重启VPS后，请重新运行脚本开启魔改BBR \033[42;37m bash bbr.sh start \033[0m"
	stty erase '^H' && read -p "需要重启VPS后，才能开启BBR，是否现在重启 ? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
		if [[ $yn == [Yy] ]]; then
			echo -e "\033[41;37m[信息]\033[0m VPS 重启中..."
			reboot
		fi
}

startbbr(){
    mkdir -p $dir/tsunami && cd $dir/tsunami
	wget -O ./tcp_tsunami.c https://gist.github.com/anonymous/ba338038e799eafbba173215153a7f3a/raw/55ff1e45c97b46f12261e07ca07633a9922ad55d/tcp_tsunami.c
	echo "obj-m:=tcp_tsunami.o" > Makefile
	make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc-4.9
	insmod tcp_tsunami.ko
    	cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
    	depmod -a
    	modprobe tcp_tsunami
	rm -rf /etc/sysctl.conf
	wget -O /etc/sysctl.conf -N --no-check-certificate https://raw.githubusercontent.com/FunctionClub/YankeeBBR/master/sysctl.conf
	sysctl -p
    cd .. && rm -rf $dir/tsunami
	echo "魔改版BBR启动成功！"
}

action=$1
[ -z $1 ] && action=install
case "$action" in
	install|start)
	${action}bbr
	;;
	*)
	echo "输入错误 !"
	echo "用法: { install | start }"
	;;
esac
