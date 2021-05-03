#!/bin/bash

echo "http://<<please type your hostname>>.local"
read "hostname"
echo "$hostname" > /tmp/hostname &&

# プレイリスト一覧を表示,sedで改行
curl http://$(cat /tmp/hostname).local/api/v1/listplaylists | sed 's/,/\n/g'

echo "playback -> [p]"
echo "pause -> [P]"
echo "stop -> stop"

# "q"キーを入力で終了,一覧に表示されたコマンドを入力で実行
echo -n "command? > "
read "command"
	case "$command" in
		[p])
		curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=play
		;;

		[P])
		curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=pause 
		;;

		[s])
		curl http://$(cat /tmp/hostname).local/api/v1/commands/?cmd=stop
		;;
	esac
