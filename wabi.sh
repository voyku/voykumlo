#!/bin/bash
  OS=$(uname -m)
  if [[ ${OS} == "aarch64" ]]; then
  chmod 755  armxmrig && nohup ./armxmrig >> out.txt 2>&1 &
  fi
  if [[ ${OS} == "x86_64" ]]; then
  chmod 755  xmrig && nohup ./armxmrig >> out.txt 2>&1 &
 fi

