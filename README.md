# BBR For Debian 9 ONLY
## Install Guide
```
wget https://raw.githubusercontent.com/S8cloud/BBR/master/bbr.sh && bash bbr.sh install
```
**You may need to REBOOT the server and then run `bbe.sh` again to start BBR:**
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
