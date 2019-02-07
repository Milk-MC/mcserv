#!/bin/bash
####################################
###########     信息      ##########
####################################
#version 1.0.0 2019-2-7
#By MilkMC-Hailay
#日志参考“二进制-程序猿“https://blog.csdn.net/wylfengyujiancheng/article/details/50019299 

####################################
###########     设置      ##########
####################################
MCPATH='/mc'                #Minecraft目录SCREENNAME
LOGDIR=$MCPATH/MSL/log      #日志目录
DATE=`date "+%Y-%m-%d"`     #日志名称：YYYYMMDD
SCREENNAME='minecraft_server'						#显示名
HISTORY=1024                #screen -h <行数> 　指定视窗的缓冲区行数
SCREENNAME='milktown'       #screen名字
MAXHEAP=512				#最大内存
MINHEAP=512				#最小内存
CPU_COUNT=1					#CPU核数
SERVICE='minecraft_server.jar'	#服务端核心名字
OPTIONS='nogui'				#java选项
INVOCATION="java -Xmx${MAXHEAP}M -Xms${MINHEAP}M -XX:+UseConcMarkSweepGC \
 -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts \
 -jar $SERVICE $OPTIONS" 	#服务端启动参数

####################################
###########     日志      ##########
####################################
DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
TIME=`date "+%H:%M:%S"`
USER_N=`whoami`
                               #启动输出头
echo -e "\033[34m[${DATE_N}]用户${USER_N}启动脚本 \033[0m" | sudo tee -a $LOGDIR/$DATE.log

function log_info ()
{
if [ ! -d $LOGDIR  ]
    then
        sudo mkdir -p $LOGDIR 
    elif [ ! -f "$LOGDIR" ];then
        sudo touch $LOGDIR/$DATE.log
fi
    echo "[${TIME} INFO]$@" |sudo tee -a $LOGDIR/$DATE.log #执行成功日志打印路径
}

function log_error ()
{
echo -e "\033[41;37m[${TIME} ERROR]$@ \033[0m"  |sudo tee -a $LOGDIR/$DATE.log #执行失败日志打印路径

}

function fn_log ()  {
if [  $? -eq 0  ]
then
    log_info "$@ sucessed."
    echo -e "\033[32m $@ sucessed. \033[0m"
else
    log_error "$@ failed."
    echo -e "\033[41;37m $@ failed. \033[0m"
    exit 1
fi
}
trap 'fn_log "DO NOT SEND CTR + C WHEN EXECUTE SCRIPT !!!! "'  2

####################################
###########     启动      ##########
####################################

mc_start(){
    if [ ! -f "$MCPATH/MSL/screen-ls.temp" ];then
        sudo touch $MCPATH/MSL/screen-ls.temp 
    fi
    sudo screen -ls > $MCPATH/MSL/screen-ls.temp
    if pgrep -f $SERVICE > /dev/null 
        then 
        log_info "服务器已在运行,无需再次启动" && exit 1
        elif ((  ` grep -o 'milktowm' screen-ls |wc -l` >= 1  ))
            then
            log_info "服务器screen已在运行,无需再次启动" && exit 1
            else 
            log_info "服务器不在运行，可启动服务器"
    fi
    log_info "准备启动服务器"
    sudo touch $MCPATH/MSL/start.sh && sudo chmod 777 $MCPATH/MSL/start.sh
    log_info "启动参数为：$INVOCATION"
    echo $INVOCATION > $MCPATH/MSL/start.sh
    log_info "完成启动脚本输出到$MCPATH/MSL/start.sh"    

    screen -dmS $SCREENNAME
    log_info "开启窗口$SCREENNAME" 
    screen -x milktowm -X stuff "$MCPATH/MSL/start.sh\n"
    log_info "窗口启动完成，开服指令下达"
    sleep 5
    if pgrep -f $SERVICE > /dev/null 
        then 
        log_info "服务器运行成功"
        else
        log_error "服务器启动失败"
    fi

}

mc-status(){
    if pgrep -f $SERVICE > /dev/null 
        then 
        log_info "服务器已在运行"
        else
        log_info "服务器不在运行，可启动服务器"
    fi
}




####################################
###########     选项      ##########
####################################
case "$1" in
    start)
    mc_start
    ;;
    useradd)
        log_info "添加用户$2"
        sudo useradd -s /bin/bash -d $MCPATH -m $2 && sudo passwd $2
    ;;
    status)
    mc-status
    ;;
    *)
    echo "可用选项: $0 {start|stop|update|backup|status|restart|useradd|command \"服务器指令\"}"
    exit 1
    ;;
esac    

exit 0
