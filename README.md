# BBR For Debian 9

* Please note that this script is made for and tested on **Debian 9 (stretch) ONLY**.   
* Other Debian version (e.g. Debian 8 jessie) may work as well but I am not sure.   
* Other Linux system including *Ubuntu* and *CentOS* is **NOT Compatible**!  

## Install Guide

* Run the following script on your Debian 9 server with **ROOT user or sudo privilige**.

```
wget -N –no-check-certificate https://raw.githubusercontent.com/S8cloud/BBR/master/bbr.sh && bash bbr.sh install
```

* You may need to **reboot** the server and then run `bbr.sh` again to start BBR:

```
bash bbr.sh start
```

## Check Guide

If you want to know whether BBR runs well on your Debian 9 server, you can use `lsmod | grep tsunami` to check.
Receiving a message like the follow means you can enjoy BBR right now or you may have to run the bash again!

```
## Example Message ##

root@Debian:~# lsmod | grep tsunami
tcp_tsunami            16384  8
```
