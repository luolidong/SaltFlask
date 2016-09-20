#!/usr/bin/env bash

channel=""
cur_dir=/data/

function _help()
{
	echo "Usage $0 serverId-server_Id|serverId,serverId s|l|r|q kill"
}

function show()
{
	local cur_path=$(pwd)
	echo "$cur_path $1"
}

function _show_info()
{
	cat config | grep -E "server_id|Time|server_type"
}

function _check()
{
	cat msg.log | grep -c "Lost"
}

function _copy()
{
	cp msg.log msg.log.bak-$(date "+%Y-%m-%d-%H:%M:%S")
}

function _list_lost()
{
	pwd
    for file in `ls msg*`
    do
        ls -lh $file
        cat $file | grep -c "Lost"
    done
}

function _operate()
{
	local op=$1
	local serverid=$2
	local confName=""
	local hqgName=hqg_$(printf "%02d" $serverId)

	if test `echo $op | grep -c "conf-"` -ne 0 ; then
		confName=${op##*-}
		op=${op%-*}
	fi

	case $op in
		kill)
			show kill
			./kill.sh
			;;
		start)
			show start
			./start.sh
			;;
		wget)
			show wget
			./wget.sh
			;;
		lua)
			./get_lua.sh
			;;
		info)
			_show_info
			;;
		check)
			_check
			;;
		copy)
			_copy
			;;
		msg)
			tail -n 10 msg.log
			;;
		lost)
			_list_lost
			;;
		conf)
			cat config | grep $confName
			;;
		checkprocess)
			ps -ef| grep $hqgName | grep -v grep
			;;
		*)
			;;
	esac
}

function _update()
{
	local file_name=$1
	local file_base=${file_name%\.*}
	local file_path=/tmp/${file_name}

	if [ -f $file_path ]; then
		cp $file_path .
		if [[ $channel == "TAIWAN" ]]; then
			enca -L zh_CN -x utf-8 $file_name
		fi
		./jhman -n ${file_base}	
	else
		echo "$file_path not found"
	fi
}

function _modify()
{
	local time=$1
	local arr=(${time//-/ })  
	local year=$(printf %d ${arr[0]})
	local mon=$(printf %d ${arr[1]})
	local day=$(printf %d ${arr[2]})

	local mon2=$(printf %02d ${arr[1]})
	local day2=$(printf %02d ${arr[2]})
	sed -i "s/\(beginTime_Year=\).*/\1${year}/g" config
	sed -i "s/\(beginTime_Month=\).*/\1${mon}/g" config
	sed -i "s/\(beginTime_Day=\).*/\1${day}/g" config
	sed -i "s/\(DropExItemStartTime=\).*/\1\'${year}-${mon2}-${day2}\'/g" config
}

function _server_operate()
{
	local stype=$1
	local op=$2
	local serverId=$3
	local name=""

	case $stype in
		s|ks)
			if [[ $stype == "s" ]]; then
				name="hqg_"
			else
				name="hqg_kf"
			fi

			dir_path=${cur_dir}${name}$(printf "%02d" $serverId)/script
			if [[ -d $dir_path ]]; then
				cd $dir_path
				_operate $op $serverId
			else
				echo "not found $dir_path"
			fi
			;;
		m)
			name="hqg_"
			dir_path=${cur_dir}${name}$(printf "%02d" $serverId)/script
			if [[ -d $dir_path ]]; then
				cd $dir_path
				_modify $op
			else
				echo "not found $dir_path"
			fi
			
			;;
		l|kl)
			if [[ $stype == "l" ]]; then
				name="hqg_"
			else
				name="hqg_kf"
			fi
			dir_path=${cur_dir}${name}$(printf "%02d" $serverId)/script/long
			if [[ -d $dir_path ]]; then
				cd $dir_path
				_operate $op $serverId
			else
				echo "not found $dir_path"
			fi
			;;
		r|kr)
			if [[ $stype == "r" ]]; then
				name="hqg_"
			else
				name="hqg_kf"
			fi
			dir_path=${cur_dir}${name}$(printf "%02d" $serverId)/script/rank
			if [[ -d $dir_path ]]; then
				cd $dir_path
				_operate $op $serverId
			else
				echo "not found $dir_path"
			fi
			;;
		q|kq)
			if [[ $stype == "q" ]]; then
				name="hqg_"
			else
				name="hqg_kf"
			fi
			dir_path=${cur_dir}${name}$(printf "%02d" $serverId)/script/queue
			if [[ -d $dir_path ]]; then
				cd $dir_path
				_operate $op $serverId
			else
				echo "not found $dir_path"
			fi
			;;
		u|ku)
			if [[ $stype == "u" ]]; then
				name="hqg_"
			else
				name="hqg_kf"
			fi
			dir_path=${cur_dir}${name}$(printf "%02d" $serverId)/script
			if [[ -d $dir_path ]]; then
				cd $dir_path
				_update $op
			else
				echo "not found $dir_path"
			fi
			;;
		*)
			_help
			;;
	esac
}

function _despath()
{
	local serverId=$1
	local serverType=$2
	local op=$3

	_server_operate $serverType $op $serverId
}

if [[ $# -ne 3 ]]; then
	_help
	exit 1
fi

serverId=$1
serverType=$2
op=$3

if test `echo $serverId | grep -c "-"` -ne 0 ; then
	if test `echo $serverId | grep -c ","` -ne 0 ; then
		_help
		exit 1
	fi

	first=${serverId%%-*}
	end=${serverId##*-}
	while test $first -le $end
	do
		_despath $first $serverType $op
		first=$(expr $first + 1)
	done
elif test `echo $serverId | grep -c ","` -ne 0 ; then
	if test `echo $serverId | grep -c "-"` -ne 0 ; then
		_help
		exit 1
	fi

	oldIFS=$IFS
	IFS=","
	for server in $serverId
	do
		oldIFS2=$IFS
		IFS=" "
		_despath $server $serverType $op
		IFS=${oldIFS2}
	done
	IFS=${oldIFS}
else
	_despath $serverId $serverType $op
fi
