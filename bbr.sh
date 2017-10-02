#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

bit=`uname -m`
dir=`pwd`

installbbr(){
	#Install GCC
	apt-get update && apt-get upgrade -y
	apt-get install build-essential make linux-image-4.9.0-3-amd64 linux-image-amd64 linux-headers-4.9.0-3-amd64 -y
	update-grub
	echo -e "[ATTENTION!] After restart please run `bash bbr.sh start` to install BBR!"
	stty erase '^H' && read -p "Restart Now? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
		if [[ $yn == [Yy] ]]; then
			echo -e "Restarting..."
			reboot
		fi
}

startbbr(){
    mkdir -p $dir/tsunami && cd $dir/tsunami
	wget -O ./tcp_tsunami.c https://gist.github.com/anonymous/ba338038e799eafbba173215153a7f3a/raw/55ff1e45c97b46f12261e07ca07633a9922ad55d/tcp_tsunami.c
	echo "obj-m:=tcp_tsunami.o" > Makefile
	make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc-6
	insmod tcp_tsunami.ko
    	cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
    	depmod -a
    	modprobe tcp_tsunami
	rm -rf /etc/sysctl.conf
	wget -O /etc/sysctl.conf -N --no-check-certificate https://raw.githubusercontent.com/S8Cloud/YankeeBBR/master/sysctl.conf
	sysctl -p
	cd .. && rm -rf $dir/tsunami
	lsmod | grep tsunami
	echo "Install Success!"
}

action=$1
[ -z $1 ] && action=install
case "$action" in
	install|start)
	${action}bbr
	;;
	*)
	echo "Wrong Input"
	echo "Use: { install | start }"
	;;
esac
