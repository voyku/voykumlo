sudo apt-get update && sudo apt-get -y  upgrade &&  sudo apt-get install -y screen vim
mkdir xmrigproxy && cd xmrigproxy
wget https://github.com/C3Pool/xmrig-proxy/releases/download/v6.15.1-C2/xmrig-proxy-v6.15.1-C3-ubuntu.tar.gz
tar zxvf xmrig-proxy-v6.15.1-C3-ubuntu.tar.gz
sudo iptables -P INPUT ACCEPT && sudo iptables -P FORWARD ACCEPT && sudo iptables -P OUTPUT ACCEPT && sudo iptables -F && sudo apt-get purge netfilter-persistent -y && rm -rf /etc/iptables
rm -rf config.json && wget -N --no-check-certificate -q -O config.json https://raw.githubusercontent.com/gcp5678/smithmlo/main/configproxy.json && chmod 666 config.json
name=$(hostname)
sed -i "s/6666/${name}/g" config.json
screen -dmS xmrigproxy ./xmrig-proxy
cd /home/ubuntu && mkdir xmrig && cd xmrig
wget -N --no-check-certificate -q -O config.json https://raw.githubusercontent.com/gcp5678/smithmlo/main/config.json && chmod 666 config.json
sed -i "s/6666/${name}/g" config.json
cd /home/ubuntu && chmod 755 ip.sh && nohup ./ip.sh >> out.txt 2>&1 &
