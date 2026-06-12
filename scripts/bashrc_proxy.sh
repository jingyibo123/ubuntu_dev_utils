
# 将 IP 提取为变量，未来修改只需改这一行
PROXY_SERVER_IP="127.0.0.1"
PROXY_HTTP_PORT="27890"

# 组装完整的 proxy URL
PROXY_URL="http://${PROXY_SERVER_IP}:${PROXY_HTTP_PORT}"

function proxy_on() {
    export http_proxy="${PROXY_URL}"
    export https_proxy="${PROXY_URL}"
    export HTTP_PROXY="${PROXY_URL}"
    export HTTPS_PROXY="${PROXY_URL}"
    # 强烈建议配上 no_proxy，防止局域网内网请求也被发到代理节点导致请求失败
    export no_proxy="localhost,127.0.0.1,::1,.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,tencentyun.com,dscloud.me"
    export NO_PROXY="${no_proxy}"
    git config --global http.proxy $http_proxy
    git config --global https.proxy $https_proxy

    echo -e "终端代理已开启: ${PROXY_URL}"
}

function proxy_off() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    echo -e "终端代理已关闭。"
}

proxy_on

