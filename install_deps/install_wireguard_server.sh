#!/bin/bash -ex


WG_SUBNET="10.8.0"   # WireGuard 虚拟网段的前三个字节
WG_PORT="54321"       # 云主机监听端口

# 密钥文件路径定义
DIR_KEYS="./keys"
FILE_C_PRI="/etc/wireguard/privatekey"

FILE_TEMPLATE="../conf/wg0-server.conf.template"
FILE_OUTPUT="/etc/wireguard/wg0.conf"


sudo apt update && sudo apt install -y wireguard

sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sed -i 's/net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

sudo touch /etc/wireguard/wg0.conf

sudo bash -c "umask 077; wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey"
sudo chmod 600 /etc/wireguard/privatekey /etc/wireguard/publickey


# 2. 读取密钥内容并清理可能多余的换行/空格
C_PRI=$(sudo cat "$FILE_C_PRI" | tr -d '\n\r ')

# 3. 执行模板替换
sed -e "s#{{WG_SUBNET}}#${WG_SUBNET}#g" \
    -e "s#{{WG_PORT}}#${WG_PORT}#g" \
    -e "s#{{C_PRIVATE_KEY}}#${C_PRI}#g" \
    "$FILE_TEMPLATE" | sudo tee "$FILE_OUTPUT" > /dev/null

# 4. 锁定输出文件的权限
sudo chmod 600 "$FILE_OUTPUT"

echo "[成功] 配置文件已生成: $FILE_OUTPUT"

