#!/bin/bash

# 变量
WORK_PATH="/root/logs/SSLCheck" # 按照实际情况自行修改
LIST_FILE="$PWD/ssl_check_list" # 按照实际情况自行修改
CURL_LOG="$WORK_PATH/curl.log"
TMP_FILE="$WORK_PATH/tmp"
JSON_FILE="$PWD/result.json" # 按照实际情况自行修改
HTML_FILE="$PWD/index.html"  # 按照实际情况自行修改
HTML_TITLE="Cat Tom's SSL Check" # 按照实际情况自行修改
CURRENT_DATE="$(date)"
CURRENT_TIMESTAMP="$(date -d "$CURRENT_DATE" +%s)"

# 检查是否安装 curl
if ! [ -x "$(command -v curl)" ]; then
    sudo apt -y install curl
fi

# 检查 $1 是否为空
if [ -z "$1" ]; then
    echo "SSLCheck v1.0 Cat Tom <cattom@cattom.site>
    
Usage: ./ssl_check.sh [HTML/JSON]"
    exit 1
else
    # 选择模式
    Mode="$1"
fi

# 保证工作目录存在
mkdir -p "$WORK_PATH"

# 检查 SSL
Check() {
    curl https://"$Site" -k -v -s -o /dev/null 2>"$CURL_LOG"

    # Domain
    Domain=$(echo "$Site" | cut -d ":" -f1)

    # HTTP Version
    if [[ $(grep -c "HTTP/1.1" "$CURL_LOG") -ge "1" ]]; then
        HTTP_Version="HTTP/1.1"
    elif [[ $(grep -c "HTTP/2" "$CURL_LOG") -ge "1" ]]; then
        HTTP_Version="HTTP/2"
    fi

    # TLS/SSL Version
    if [[ $(grep -c "SSL connection using TLSv1.2" "$CURL_LOG") -ge "1" ]]; then
        TLS_Version="TLSv1.2"
    elif [[ $(grep -c "SSL connection using TLSv1.3" "$CURL_LOG") -ge "1" ]]; then
        TLS_Version="TLSv1.3"
    fi

    # Certificate information
    cat "$CURL_LOG" | grep 'subject: ' >"$TMP_FILE"
    cat "$CURL_LOG" | grep 'start date: ' >>"$TMP_FILE"
    cat "$CURL_LOG" | grep 'expire date: ' >>"$TMP_FILE"
    cat "$CURL_LOG" | grep 'issuer: ' >>"$TMP_FILE"
    cat "$CURL_LOG" | grep 'SSL certificate verify' >>"$TMP_FILE"

    sed -i "s|*  subject: ||" "$TMP_FILE"
    sed -i "s|*  start date: ||" "$TMP_FILE"
    sed -i "s|*  expire date: ||" "$TMP_FILE"
    sed -i "s|*  issuer: ||" "$TMP_FILE"
    sed -i "s|*  SSL certificate verify ||" "$TMP_FILE"

    Subject=$(sed -n '1p' "$TMP_FILE")
    Start_Date=$(sed -n '2p' "$TMP_FILE")
    Expire_Date=$(sed -n '3p' "$TMP_FILE")
    Issuer=$(sed -n '4p' "$TMP_FILE")
    Status_Origin=$(sed -n '5p' "$TMP_FILE")

    Expire_Timestamp=$(date -d "$Expire_Date" +%s)
    Remain=$(expr $((Expire_Timestamp - CURRENT_TIMESTAMP)) / 86400)

    if [ "$Expire_Timestamp" -lt "$CURRENT_TIMESTAMP" ]; then
        Status="Expired"
    elif [ "$Remain" -lt 30 ]; then
        Status="Soon Expired"
    elif [ "$Status_Origin" = "ok." ]; then
        Status="Valid"
    else
        Status="Invalid"
    fi
}

JSON() {
    echo "[" >"$JSON_FILE"

    while read -r Site; do
        Check

        echo "{" >>"$JSON_FILE"

        # Domain
        echo '"Domain": "'"$Domain"'",' >>"$JSON_FILE"

        # HTTP Version
        echo '"HTTP_Version": "'"$HTTP_Version"'",' >>"$JSON_FILE"

        # TLS/SSL Version

        echo '"TLS_Version": "'"$TLS_Version"'",' >>"$JSON_FILE"

        # Certificate information
        echo '"Subject": "'"$Subject"'",' >>"$JSON_FILE"
        echo '"Start_Date": "'"$Start_Date"'",' >>"$JSON_FILE"
        echo '"Expire_Date": "'"$Expire_Date"'",' >>"$JSON_FILE"
        echo '"Issuer": "'"$Issuer"'",' >>"$JSON_FILE"
        echo '"Status": "'"$Status"'",' >>"$JSON_FILE"
        echo '"Remain_Day": "'"$Remain"'",' >>"$JSON_FILE"
        echo '"Last_Check": "'"$CURRENT_DATE"'"' >>"$JSON_FILE"

        echo "}," >>"$JSON_FILE"

    done <"$LIST_FILE"

    echo "]" >>"$JSON_FILE"

    sed -i 'x; ${s|.*|}|;p;x}; 1d' "$JSON_FILE"
}

HTML() {
    cat <<-EOF >"$HTML_FILE"
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" />
    <meta name="renderer" content="webkit" />
    <meta name="force-rendering" content="webkit" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <link href="https://static.cattom.site/image/icon/favicon.ico" rel="shortcut icon" type="image/x-icon" />
    <!-- MDUI CSS -->
    <link rel="stylesheet" href="https://unpkg.com/mdui@1.0.2/dist/css/mdui.min.css" />
    <title>$HTML_TITLE</title>
</head>

<body class="mdui-appbar-with-toolbar mdui-theme-primary-teal mdui-theme-accent-blue">

    <header class="appbar mdui-appbar mdui-appbar-fixed">
        <div class="mdui-toolbar mdui-color-theme">
            <a href="#" class="mdui-typo-title mdui-m-l-3">$HTML_TITLE</a>
            <div class="mdui-toolbar-spacer"></div>
            <a href="https://blog.cattom.site" target="_blank" class="mdui-btn mdui-btn-icon mdui-ripple"
                mdui-tooltip="{content: 'Blog'}">
                <i class="mdui-icon material-icons">home</i>
            </a>
            <a href="https://github.com/cattomgithub" target="_blank" class="mdui-btn mdui-btn-icon mdui-ripple"
                mdui-tooltip="{content: 'Github'}">
                <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg"
                    xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 36 36"
                    enable-background="new 0 0 36 36" xml:space="preserve" class="mdui-icon"
                    style="width: 24px;height:24px;">
                    <path fill-rule="evenodd" clip-rule="evenodd" fill="#ffffff"
                        d="M18,1.4C9,1.4,1.7,8.7,1.7,17.7c0,7.2,4.7,13.3,11.1,15.5c0.8,0.1,1.1-0.4,1.1-0.8c0-0.4,0-1.4,0-2.8c-4.5,1-5.5-2.2-5.5-2.2c-0.7-1.9-1.8-2.4-1.8-2.4c-1.5-1,0.1-1,0.1-1c1.6,0.1,2.5,1.7,2.5,1.7c1.5,2.5,3.8,1.8,4.7,1.4c0.1-1.1,0.6-1.8,1-2.2c-3.6-0.4-7.4-1.8-7.4-8.1c0-1.8,0.6-3.2,1.7-4.4c-0.2-0.4-0.7-2.1,0.2-4.3c0,0,1.4-0.4,4.5,1.7c1.3-0.4,2.7-0.5,4.1-0.5c1.4,0,2.8,0.2,4.1,0.5c3.1-2.1,4.5-1.7,4.5-1.7c0.9,2.2,0.3,3.9,0.2,4.3c1,1.1,1.7,2.6,1.7,4.4c0,6.3-3.8,7.6-7.4,8c0.6,0.5,1.1,1.5,1.1,3c0,2.2,0,3.9,0,4.5c0,0.4,0.3,0.9,1.1,0.8c6.5-2.2,11.1-8.3,11.1-15.5C34.3,8.7,27,1.4,18,1.4z">
                    </path>
                </svg>
            </a>
        </div>
    </header>

    <div class="mdui-container">
        <div class="mdui-row">
            <div class="mdui-col-md-8 mdui-col-offset-md-2">
                <div class="mdui-panel mdui-p-t-2" mdui-panel>
	EOF

    while read -r Site; do

        Check

        cat <<-EOF >>"$HTML_FILE"

<div class="mdui-panel-item">
                <div class="mdui-panel-item-header">
                    <div class="mdui-panel-item-title">$Domain</div>
                    <div class="mdui-panel-item-summary">$Remain Day</div>
	EOF

        if [ "$Status" = "Valid" ]; then
            echo "<div class='mdui-panel-item-summary mdui-text-color-green-a700'>Valid</div>" >>"$HTML_FILE"
        elif [ "$Status" = "Expired" ]; then
            echo "<div class='mdui-panel-item-summary mdui-text-color-red-a700'>Expired</div>" >>"$HTML_FILE"
        elif [ "$Status" = "Soon Expired" ]; then
            echo "<div class='mdui-panel-item-summary mdui-text-color-orange-a700'>Soon Expired</div>" >>"$HTML_FILE"
        else
            echo "<div class='mdui-panel-item-summary mdui-text-color-blue-grey-700'>Invalid</div>" >>"$HTML_FILE"
        fi

        cat <<-EOF >>"$HTML_FILE"
<i class="mdui-panel-item-arrow mdui-icon material-icons">keyboard_arrow_down</i>
                </div>
                <div class="mdui-panel-item-body">
                    <p><span class="mdui-text-color-grey-500">HTTP Version</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$HTTP_Version</p>
                    <p><span class="mdui-text-color-grey-500">TLS Version</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$TLS_Version</p>
                    <p><span class="mdui-text-color-grey-500">Start Date</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Start_Date</p>
                    <p><span class="mdui-text-color-grey-500">Expire Date</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Expire_Date</p>
                    <p><span class="mdui-text-color-grey-500">Issuer</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Issuer</p>
                    <p><span class="mdui-text-color-grey-500">Status</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Status</p>
                    <p><span class="mdui-text-color-grey-500">Remain</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Remain Day</p>
                    <p><span class="mdui-text-color-grey-500">Last Check</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$CURRENT_DATE</p>
                </div>
            </div>

	EOF

    done <"$LIST_FILE"

    cat <<-EOF >>"$HTML_FILE"
                </div>
            </div>
        </div>
    </div>

    <!-- MDUI JavaScript -->
    <script src="https://unpkg.com/mdui@1.0.2/dist/js/mdui.min.js"></script>
</body>

</html>
	EOF

}

$Mode
