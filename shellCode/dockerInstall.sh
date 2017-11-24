#!/bin/bash
#===========================================================================================
#install docker environment
sudo apt-get install apt-transport-https
sudo apt-get install ca-certificates
sudo apt-get install gnupg2
sudo apt-get install curl
sudo apt-get install software-properties-common
sudo apt-get install lsb-release
#===========================================================================================
# add Docker repo gpg key(官方源)
sudo chmod +x /etc/apt/sources.list
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo "google" | sudo -S su -c "echo 'deb https://download.docker.com/linux/debian stretch stable' >> /etc/apt/sources.list"
#===========================================================================================
#删除重复内容
echo "google" | sudo -S sed -r -i ':1;N;s/^(.+)((\n.*)*)\n\1$/\1\2/M;$!b1' /etc/apt/sources.list 
#===========================================================================================
sudo apt-get update
#$?:命令执行成功会返回 0，失败返回 1
if [ $? -ne 0 ];then
	while :
	do
	    sudo apt-get --fix-missing update
	done
else
    echo "update succeed"
fi
#===========================================================================================
#install docker-ce
sudo apt-get install docker-ce -y
#===========================================================================================
#删除包含指定的内容的行(-i∶直接修改读取的文件内容)
sudo sed -i '/download.docker.com/d' /etc/apt/sources.list
#===========================================================================================
# manage Docker as a non-root user,建立docker组并将当前用户加入docker组:
sudo groupadd docker
sudo usermod -aG docker $USER
sudo usermod -aG docker google
#===========================================================================================
# configure Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker
#===========================================================================================
#删除包含指定的内容的行
#sudo sed -i '/ExecStart=\/usr\/bin\/dockerd/d' /etc/systemd/system/multi-user.target.wants/docker.service
sudo sed -i '/ExecStart=\/usr\/bin\/dockerd/d' /lib/systemd/system/docker.service
sudo sed -i '/ExecReload=\/bin\/kill/i\ExecStart=/usr/bin/dockerd' /lib/systemd/system/docker.service
#===========================================================================================
#在指定文件的指定位置前面添加内容
#匹配行前加用i，匹配行后加a
#sudo sed -i '/ExecReload=\/bin\/kill/i\ExecStart=/usr/bin/dockerd -H tcp://127.0.0.1:2375 \
#                           -H unix:///var/run/docker.sock \
#                           --insecure-registry registry.gozap.com \
#			   --storage-driver=overlay2 \
#			   --graph=/data/docker \
#			   --log-driver json-file \
#			   --log-opt max-size=50m \
#			   --log-opt max-file=3 \
#                           --registry-mirror=https://registry.docker-cn.com \' /lib/systemd/system/docker.service
#-H : 指定docker的监听地址(docker API),一般默认为127.0.0.1
#—graph : 指定docker把数据存储到指定目录
#—storage-driver=overlay2 指定docker使用overlay2存储驱动，提升存储性能
#log的设置 : json-file 表示输出日志格式为 json
#max-size 指定最大的单个日志文件大小
#max-file 指定单个容器最多能有几个文件
#两者加一起也就意味着 单个容器 最大只能产生 50*3  150MB 的日志,防止容器无限产生日志，把磁盘沾满了
#===========================================================================================
#重载守护进程，重启docker
sudo systemctl daemon-reload && sudo systemctl restart docker
sudo ps -ef | grep dockerd
#===========================================================================================
#install docker-compose
sudo pip install -U docker-compose
#===========================================================================================
# 检查是否安装好docker
sudo docker info && sudo docker version && docker-compose version
if [ $? -eq 0 ];then
# -eq ：判断$?返回值是否和0相等
    echo "==============="
    echo "install succeed"
    echo "==============="
else
    echo "============"
    echo "install fail"
    echo "============"
fi

