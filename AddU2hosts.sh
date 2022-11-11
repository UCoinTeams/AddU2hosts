#!/bin/bash

# --------------------------------------------------------------
#	项目: CloudflareSpeedTest 自动添加替换更新 U2 Hosts
#	版本: 0.0.1
#	项目: https://github.com/Ukenn2112/AddU2hosts/
# --------------------------------------------------------------

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Yellow_font_prefix="\033[33m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
# 可在此处自行替换proxy地址
web_proxy="https://ukenn.net/"

# 判断 root 用户
check_root() {
  if [ `whoami` != "root" ]; then
    echo -e "${Red_font_prefix}请使用 ROOT 权限执行脚本${Font_color_suffix}" && exit 1
  fi
}

# 欢迎
welcome()  {
  echo -e $Yellow_font_prefix'该脚本的作用为 解决Cloudflare CDN被污染导致无法直接登录动漫花园'$Font_color_suffix'\n'
  echo -e $Yellow_font_prefix'并使用 CloudflareST 测速后获取最快 IP 并替换 Hosts 中的 Cloudflare CDN IP。'$Font_color_suffix'\n'
}

# U2 默认 Host
default_host() {
  echo -e "\n# U2 Hosts Start\n104.25.26.31 u2.dmhy.org\n104.25.26.31 tracker.dmhy.org\n104.25.26.31 daydream.dmhy.best\n# Update time: $(date "+%Y-%m-%d %H:%M:%S")\n">> /etc/hosts
}

# CloudflareST 测试程序
cloudflare_st() {
  echo -e "${Green_font_prefix}> 正在下载 CloudflareST 测试程序${Font_color_suffix}";
  wget ${web_proxy}https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.1.0/CloudflareST_linux_amd64.tar.gz -O CloudflareST_linux_amd64.tar.gz
  tar -zxf CloudflareST_linux_amd64.tar.gz
  chmod +x CloudflareST
  echo "104.25.26.31" > nowip.txt
	echo -e "${Green_font_prefix}> 开始测速...${Font_color_suffix}";
	NOWIP=$(head -1 nowip.txt)
    # 可在 -url 后替换为你自建的或他人提供的其他测速点，避免Cloudflare限速
    # 自建方法详情请见 https://github.com/XIU2/CloudflareSpeedTest/issues/168
    # Cloudflare Workers 现已被 DNS 污染，不建议用其进行测速
    ./CloudflareST -url https://cloudflaremirrors.com/archlinux/iso/latest/arch/x86_64/airootfs.sfs
	BESTIP=$(sed -n "2,1p" result.csv | awk -F, '{print $1}')
	echo ${BESTIP} > nowip.txt
	echo -e "\n旧 IP 为 ${NOWIP}\n${Yellow_font_prefix}新 IP 为 ${BESTIP}${Font_color_suffix}\n"

	echo -e "${Green_font_prefix}> 开始备份 Hosts 文件 (/etc/hosts.bk)...${Font_color_suffix}";
	\cp -f /etc/hosts /etc/hosts.bk

	echo -e "${Green_font_prefix}> 开始替换...${Font_color_suffix}";
	sed -i 's/'${NOWIP}'/'${BESTIP}'/g' /etc/hosts
	echo -e "${Green_font_prefix}> 完成...${Font_color_suffix}";
  echo -e "${Green_font_prefix}> 清理 CloudflareST 测试程序${Font_color_suffix}";
  rm -rf *.txt cfst_hosts.sh result.csv CloudflareST*
}


# 检测root用户
check_root
# 欢迎
welcome
# 写入U2 默认 Host
default_host
# 运行 CloudflareST 测试程序
cloudflare_st
