#!/bin/bash

echo "http://<<hostname>>.local"
read -p "hostname? " "hostname"
# 入力されたホスト名を保存
echo "$hostname" > /tmp/hostname &&

# プレイリスト一覧を表示,sedで改行,echoで空白行の挿入
curl http://$(cat /tmp/hostname).local/api/v1/listplaylists | sed 's/,/\n/g' && echo -e "\n" 

echo "playback -> [p]"
echo "pause -> [P]"
echo "stop  -> [s]"
echo "exit  -> [q]"
echo -n -e "\n"

# "q"キーを入力で終了,それ以外で一覧に表示されたコマンドを入力で実行
while :
do
	read -p "command? > " "command"
		case "$command" in
			# 再生
			[p])
			curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=play
			;;
	
			# 一時停止
			[P])
			curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=pause
			;;
			
			# 停止
			[s])
			curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=stop
			;;
	
			# 終了
			[q])
			exit 0
			;;
		esac
done
