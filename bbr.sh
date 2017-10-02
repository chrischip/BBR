#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

bit=`uname -m`
dir=`pwd`

installbbr(){
	rm /etc/apt/sources.list
	wget -O /etc/apt/sources.list -N --no-check-certificate https://raw.githubusercontent.com/S8Cloud/BBR/master/sources.list
	apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
	apt-get autoremove && apt-get autoclean
	apt-get install build-essential libssl1.0.0 make linux-image-4.9.0-3-amd64 linux-image-amd64 linux-headers-4.9.0-3-amd64 automake curl vim git sudo unzip apt-transport-https screen lsb-release ca-certificates python python-pip -y
	echo 3 > /proc/sys/net/ipv4/tcp_fastopen
	echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
	update-grub
	
	echo -e "Please run ./bbr.sh start after restart"
	read -p "Need restart, Restart Now? [Y/n]:" yn
	[ -z "${yn}" ] && yn="y"
		if [[ $yn == [Yy] ]]; then
			echo -e "Rebooting..."
			reboot
		fi
}

startbbr(){
	mkdir -p $dir/tsunami && cd $dir/tsunami
	wget -O ./tcp_tsunami.c -N --no-check-certificate https://raw.githubusercontent.com/S8Cloud/BBR/master/tcp_tsunami.c
	echo "obj-m:=tcp_tsunami.o" > Makefile
	make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc-6
	insmod tcp_tsunami.ko
	cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
	depmod -a
	modprobe tcp_tsunami
	rm -rf /etc/sysctl.conf
	wget -O /etc/sysctl.conf -N --no-check-certificate https://raw.githubusercontent.com/S8Cloud/BBR/master/sysctl.conf
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
