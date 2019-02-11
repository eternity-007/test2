#! /bin/bash
# unset any variable which system may be using
# clear the screen


# 5个参数：-i(安装)，-v(版本信息),-m(内存)，-d(磁盘)，-h(帮助信息)
while getopts ivh name
do
        case $name in
          i)iopt=1;;
          v)vopt=1;;
          h)hopt=1;;
         *)echo "Invalid arg";;
        esac
done



# -i(安装): 将脚本添加到环境的目录里
if [[ ! -z $iopt ]]
then
{
wd=$(pwd)

# basename：去掉路径；test -L:判断是否为符号链接； readlink：找出符号链接所指向的位置
# 符号链接(软连接)相当于windows中的快捷方式
basename "$(test -L "$0" && readlink "$0" || echo "$0")" > /tmp/scriptname

# scriptname就是脚本的地址
scriptname=$(echo -e -n $wd/ && cat /tmp/scriptname)
su -c "cp $scriptname /usr/bin/monitor" root && echo "Congratulations! Script Installed, now run monitor Command" || echo "Installation failed"
}
fi


# -v(版本信息)：打印版本信息
if [[ ! -z $vopt ]]
then
{
echo -e "tecmint_monitor version 0.1\nDesigned by Tecmint.com\nReleased Under Apache 2.0 License"
}
fi
if [[ ! -z $hopt ]]
then
{
echo -e " -i                                Install script"
echo -e " -v                                Print version information and exit"
echo -e " -h                                Print help (this information) and exit"
}
fi

if [[ $# -eq 0 ]]
then
{
clear

unset tecreset os architecture kernelrelease internalip externalip nameserver loadaverage

# Define Variable tecreset   ##定义变量tecreset
# tput: 创建自定义输出，如移动或更改光标，更改文本属性，更改字体颜色等
# tput sgr0: 正常输出
tecreset=$(tput sgr0)


# Check if connected to Internet or not
# \E[32m: 将字体颜色改变为绿色，\033[32m 同样可以
ping -c 1 www.baidu.com &> /dev/null && echo -e '\E[32m'"Internet: $tecreset Connected" || echo -e '\E[32m'"Internet: $tecreset Disconnected"

# Check OS Type  // 查看系统类型
os=$(uname -o)
echo -e '\E[32m'"Operating System Type :" $tecreset $os


###########################################################
# Check OS Release Version and Name  //查看系统版本和名称
# uname: 获取电脑和操作系统的相关信息
OS=`uname -s`
REV=`uname -r`
MACH=`uname -m`

GetVersionFromFile()
{
    VERSION=`cat $1 | tr "\n" ' ' | sed s/.*VERSION.*=\ // `
}

if [ "${OS}" = "SunOS" ] ; then
    OS=Solaris
    ARCH=`uname -p`
    OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
elif [ "${OS}" = "AIX" ] ; then
    OSSTR="${OS} `oslevel` (`oslevel -r`)"
elif [ "${OS}" = "Linux" ] ; then
    KERNEL=`uname -r`
    if [ -f /etc/redhat-release ] ; then
        DIST='RedHat'
        PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
        REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/SuSE-release ] ; then
        DIST=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
        REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    elif [ -f /etc/mandrake-release ] ; then
        DIST='Mandrake'
        PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
        REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/debian_version ] ; then
        DIST="Debian `cat /etc/debian_version`"
        REV=""

    fi
    if ${OSSTR} [ -f /etc/UnitedLinux-release ] ; then
        DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
    fi

    OSSTR="${OS} ${DIST} ${REV}(${PSUEDONAME} ${KERNEL} ${MACH})"

fi

##################################
#cat /etc/os-release | grep 'NAME\|VERSION' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME' > /tmp/osrelease
#echo -n -e '\E[32m'"OS Name :" $tecreset  && cat /tmp/osrelease | grep -v "VERSION" | grep -v CPE_NAME | cut -f2 -d\"
#echo -n -e '\E[32m'"OS Version :" $tecreset && cat /tmp/osrelease | grep -v "NAME" | grep -v CT_VERSION | cut -f2 -d\"
echo -e '\E[32m'"OS Version :" $tecreset $OSSTR 

# 查看系统架构
architecture=$(uname -m)
echo -e '\E[32m'"Architecture :" $tecreset $architecture


# 查看内核版本
kernelrelease=$(uname -r)
echo -e '\E[32m'"Kernel Release :" $tecreset $kernelrelease


# 查看主机名
echo -e '\E[32m'"Hostname :" $tecreset $HOSTNAME


# 查看内网IP
internalip=$(hostname -I)
echo -e '\E[32m'"Internal IP :" $tecreset $internalip


# 查看外网IP
externalip=$(curl -s ipecho.net/plain;echo)
echo -e '\E[32m'"External IP : $tecreset "$externalip


# 查看域名服务器
nameservers=$(cat /etc/resolv.conf | sed '1 d' | awk '{print $2}')
echo -e '\E[32m'"Name Servers :" $tecreset $nameservers 


# 查看登陆用户
who>/tmp/who
echo -e '\E[32m'"Logged In users :" $tecreset && cat /tmp/who 


# 查看内存
free -h | grep -v + > /tmp/ramcache
echo -e '\E[32m'"Ram Usages :" $tecreset
cat /tmp/ramcache | grep -v "Swap"
echo -e '\E[32m'"Swap Usages :" $tecreset
cat /tmp/ramcache | grep -v "Mem"


# 查看磁盘
df -h| grep 'Filesystem\|/dev/sda*' > /tmp/diskusage
echo -e '\E[32m'"Disk Usages :" $tecreset 
cat /tmp/diskusage


# 查看负载
loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $10 $11 $12}')
echo -e '\E[32m'"Load Average :" $tecreset $loadaverage


# 查看系统运行时间
tecuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
echo -e '\E[32m'"System Uptime Days/(HH:MM) :" $tecreset $tecuptime


# 删除变量，释放资源
unset tecreset os architecture kernelrelease internalip externalip nameserver loadaverage

# 删除临时文件
rm /tmp/who /tmp/ramcache /tmp/diskusage
}
fi
shift $(($OPTIND -1))

# shift命令用于对参数的移动(左移)。可以查看http://blog.csdn.net/zhu_xun/article/details/24796235
