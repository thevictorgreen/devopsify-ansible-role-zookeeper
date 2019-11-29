#!/bin/bash

# LOG OUTPUT TO A FILE
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/root/.zk_automate/log.out 2>&1

if [[ ! -f "/root/.zk_automate/init.cfg" ]]
then
  # download zookeeper to tmp directory
  curl -O http://apache.mirrors.pair.com/zookeeper/stable/apache-zookeeper-3.5.6-bin.tar.gz && mv $PWD/apache-zookeeper-3.5.6-bin.tar.gz /tmp
  # unpack zookeeper
  tar -xvf /tmp/apache-zookeeper-3.5.6-bin.tar.gz -C /usr/local
  # rename zookeeper directory
  mv /usr/local/apache-zookeeper-3.5.6-bin /usr/local/zookeeper
  # remove /tmp/apache-zookeeper-3.5.6-bin.tar.gz
  rm -rf /tmp/apache-zookeeper-3.5.6-bin.tar.gz
  # copy environment file
  cat /root/.zk_automate/environment > /etc/environment
  # source environment
  source /etc/environment
  # update myid
  name="$( hostname |cut -d. -f1 )"
  last="${name: -1}"
  if [[ "$last" == "0" ]]
  then
     echo 1 > /root/.zk_automate/myid
  elif [[ "$last" == "1" ]]
  then
    echo 2 > /root/.zk_automate/myid
  elif [[ "$last" == "2" ]]
  then
    echo 3 > /root/.zk_automate/myid
  fi
  # Copy zoo.cfg
  cp /root/.zk_automate/zoo.cfg /usr/local/zookeeper/conf
  # Copy myid
  cp /root/.zk_automate/myid /var/zookeeper/data
  # Copy zk.service
  cp /root/.zk_automate/zk.service /etc/systemd/system/
  # enable zookeeper
  systemctl daemon-reload
  systemctl enable zk
  # start zookeeper
  systemctl start zk
  # check zookeeper status
  systemctl status -l zk
  # Idempotentcy
  touch /root/.zk_automate/init.cfg
fi
