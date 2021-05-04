#!/bin/bash

# "/tmp/hostnam"eが無い場合にホスト名を設定
if ! cat /tmp/hostname 2> /dev/null ; then
	echo "http://<<hostname>>.local" && read -p "hostname? > " "hostname" ; echo "$hostname" > /tmp/hostname
else
	:
fi

# pingで疎通確認,成功時のみ入力を待つ
if ping -c 3 $(cat /tmp/hostname).local | grep ttl > /dev/null ; then
	# プレイリスト一覧を表示,sedで改行,echoで空白行の挿入
	curl http://$(cat /tmp/hostname).local/api/v1/listplaylists | sed 's/,/\n/g' && echo -e "\n" 

# コマンド一覧
echo "command list" 
echo "	play/pause        -> [1]"
echo "	stop              -> [2]"
echo "	previous          -> [3]"
echo "	next              -> [4]"
echo "	repeat ON/OFF     -> [5]"
echo "	random ON/OFF     -> [6]"
echo "	change host       -> [C]"
echo "	exit              -> [Q]"
echo -n -e "\n"

# "shift+q"キーを入力で終了,それ以外で一覧に表示されたコマンドを入力で実行
while :
do
	read -p "command? > " "command"
		case "$command" in
			# 再生/一時停止
			[1])
				curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=toggle && echo -n -e "\n"
			;;
	
			# 停止
			[2])
				curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=stop && echo -n -e "\n"
			;;
	
			# 前の曲
			[3])
				curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=prev && echo -n -e "\n"
			;;
	
			# 次の曲
			[4])
				curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=next && echo -n -e "\n"
			;;

			# リピート 
			[5])
				curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=repeat && echo -n -e "\n"
			;;

			# ランダム
			[6])
				curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=random && echo -n -e "\n"
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
