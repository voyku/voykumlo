#!/bin/bash
  sudo apt-get update && sudo apt-get -y  upgrade &&  sudo apt-get install -y screen
  OS=$(uname -m)
  if [[ ${OS} == "aarch64" ]]; then
  screen -dmS xmrig ./armxmrig
  fi
  if [[ ${OS} == "x86_64" ]]; then
  screen -dmS xmrig ./xmrig
 fi
