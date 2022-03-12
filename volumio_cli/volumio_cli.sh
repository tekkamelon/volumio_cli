#!/bin/sh

# キーボードの入力を読み取りホスト名またはIPアドレスを設定
read_hostname () {
	echo "http://<<hostname or IP_adress>>" && echo 'hostname > ' | tr "\n" " " && read hostname ; echo "$hostname" > /tmp/hostname && echo ""
}

# "/tmp/hostname"が無い場合にホスト名を設定
test -e /tmp/hostname || read_hostname

# pingで疎通確認,成功時のみ入力を待つ
if ping -c 2 $(cat /tmp/hostname) | grep ttl > /dev/null ; then

	# apiを叩く
	curl_api () {
		curl -s http://$(cat /tmp/hostname)/api/v1/commands/?cmd=$1 > /dev/null ; echo ""
	}

	# システム情報の表示,改行
	sys_info () {
		echo "" && curl -s http://$(cat /tmp/hostname)/api/v1/getSystemInfo | sed -e 's/,/\n/g' -e 's/{//g' | awk -F\" '{print $2,$3,$4}' && echo ""
	}

# コマンド一覧を表示
commands_list () {
	cat << EOS
	command list
	  playlist        -> [0]
	  play/pause      -> [1]
	  stop            -> [2]
	  previous        -> [3]
	  next            -> [4]
	  repeat ON/OFF   -> [5]
	  random ON/OFF   -> [6]
	  system INFO     -> [7]
	  volume          -> [8]
	  help            -> [H]
	  change host     -> [C]
	  exit            -> [Q]
EOS
	echo ""
}

# コマンド一覧を表示
commands_list

# "shift+q"キーを入力で終了,それ以外で一覧に表示されたコマンドを入力で実行
while :
do
	# read -p "command? > " "command"
	echo 'command? > ' | tr "\n" " " && read command
		case "$command" in

	# プレイリスト一覧を表示,sedで改行,awk抽出,echoで空白行の挿入
			[0])
				echo "" && curl -s http://$(cat /tmp/hostname)/api/v1/listplaylists | sed -e 's/,/\n/g' | awk -F\" '{print $2}' && echo ""
			;;
	
			# 再生/一時停止
			[1])
				curl_api toggle && sleep 1; sys_info | grep state && echo ""
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
				sys_info		
			;;

			# 音量の調整
			[8])
				echo "" && echo 'volume? >' | tr "\n" " " && read volume

				# echoでシングルクォート付きのURLをxargs経由でcurlに渡し,volumeを表示
				echo " 'http://$(cat /tmp/hostname)/api/v1/commands/?cmd=volume&volume=$volume'" | xargs curl -s > /dev/null ; sys_info | grep volume 
			;;

			[H])
				echo "" && commands_list
			;;
			# ホスト名の再設定
			[C])
				echo "http://<<hostname>>" && echo 'hostname? > ' | tr "\n" " " && read hostname ; echo "$hostname" > /tmp/hostname && exit 0
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

