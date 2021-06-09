#!/bin/bash

# "/tmp/hostname"が無い場合にホスト名を設定
if ! cat /tmp/hostname 2> /dev/null ; then
	echo "http://<<hostname>>.local" && read -p "hostname? > " "hostname" ; echo "$hostname" > /tmp/hostname
else
	: # 何もしない
fi

# pingで疎通確認,成功時のみ入力を待つ
if ping -c 3 $(cat /tmp/hostname).local | grep ttl > /dev/null ; then

	# システム情報の表示,awkで"{"と"}"を削除
	echo -n -e "\n" && curl -s http://$(cat /tmp/hostname).local/api/v1/getSystemInfo | awk '{print substr($0, 2, length($0)-2)}' | sed 's/,/\n/g' && echo -n -e "\n"

	# apiを叩く関数
	curl_api () {
		curl -s http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=$1 > /dev/null && echo -n -e "\n"
	}

# コマンド一覧を表示
echo -n -e "\n" && echo "command list" 
echo "	playlist          -> [0]"
echo "	play/pause        -> [1]"
echo "	stop              -> [2]"
echo "	previous          -> [3]"
echo "	next              -> [4]"
echo "	repeat ON/OFF     -> [5]"
echo "	random ON/OFF     -> [6]"
echo "	system INFO       -> [7]"
echo "	change host       -> [C]"
echo "	exit              -> [Q]" && echo -n -e "\n"

# "shift+q"キーを入力で終了,それ以外で一覧に表示されたコマンドを入力で実行
while :
do
	read -p "command? > " "command"
		case "$command" in
	# プレイリスト一覧を表示,sedで改行,echoで空白行の挿入
			[0])
				echo -n -e "\n" && curl -s http://$(cat /tmp/hostname).local/api/v1/listplaylists | sed -e 's/,/\n/g' -e 's/\[//g' -e 's/\]//g' && echo -e "\n"
			;;
	
			# 再生/一時停止
			[1])
				curl_api toggle
			;;
	
			# 停止
			[2])
				curl_api stop
			;;
	
			# 前の曲
			[3])
				curl_api prev
			;;
	
			# 次の曲
			[4])
				curl_api next
			;;

			# リピート 
			[5])
				curl_api repeat
			;;

			# ランダム
			[6])
				curl_api random
			;;

			# システム情報の表示
			[7])
				echo -n -e "\n" && curl -s  http://$(cat /tmp/hostname).local/api/v1/getSystemInfo | awk '{print substr($0, 2, length($0)-2)}' | sed 's/,/\n/g' && echo -n -e "\n"
			;;

			# ホスト名の再設定
			[C])
				echo "http://<<hostname>>.local" && read -p "hostname? > " "hostname" ; echo "$hostname" > /tmp/hostname && exit 0
			;;

			# 終了
			[Q])
				exit 0
			;;
		esac
done
else
	# ホストが見つからない場合は"/tmp/hostname"を削除
	rm /tmp/hostname
fi
