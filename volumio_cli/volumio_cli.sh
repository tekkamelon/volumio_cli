#!/bin/bash

# ホスト名の設定
if ! cat /tmp/hostname ; then
	echo "http://<<hostname>>.local" && read -p "hostname? > " "hostname" ; echo "$hostname" > /tmp/hostname
else
	:
fi

# pingで疎通確認,成功時のみ入力を待つ
if ping -c 3 $(cat /tmp/hostname).local | grep ttl ; then
	# プレイリスト一覧を表示,sedで改行,echoで空白行の挿入
	curl http://$(cat /tmp/hostname).local/api/v1/listplaylists | sed 's/,/\n/g' && echo -e "\n" 

# コマンド一覧
echo "command list" 
echo "	playback          -> [1]"
echo "	pause             -> [2]"
echo "	stop              -> [3]"
echo "	change host       -> [C]"
echo "	exit              -> [Q]"
echo -n -e "\n"

# "shift+q"キーを入力で終了,それ以外で一覧に表示されたコマンドを入力で実行
while :
do
	read -p "command? > " "command"
		case "$command" in
			# 再生
			[1])
				curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=play && echo -n -e "\n"
			;;
	
			# 一時停止
			[2])
				curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=pause && echo -n -e "\n"
			;;
			
			# 停止
			[3])
				curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=stop && echo -n -e "\n"
			;;
	
			# ホスト名の再設定
			[C])
				echo "http://<<hostname>>.local" && read -p "hostname? > " "hostname" ; echo "$hostname" > /tmp/hostname ; exit 0
			;;

			# 終了
			[Q])
				exit 0
			;;
		esac
done
else
	rm /tmp/hostname
fi
