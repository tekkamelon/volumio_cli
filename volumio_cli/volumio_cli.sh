#!/bin/sh 

# キーボードの入力を読み取りホスト名またはIPアドレスを設定
read_hostname () {
	echo "http://<<hostname or IP_adress>>" && echo 'hostname > ' | tr "\n" " " && read hostname ; echo "$hostname" > /tmp/hostname && echo "" && export MPD_HOST=$(cat /tmp/hostname)
}

# "/tmp/hostname"が無い場合にホスト名を設定
test -e /tmp/hostname || read_hostname

# wgetで疎通確認,成功時のみ入力を待つ
if export MPD_HOST=$(cat /tmp/hostname) && wget -q -O - $MPD_HOST > /dev/null ; then

	# apiを叩く
	hit_apt () {
		wget -q -O - http://$MPD_HOST/api/v1/commands/?cmd=$1 > /dev/null ; echo ""
	}

	# システム情報の表示,改行
	sys_info () {
		wget -q -O - http://$MPD_HOST/api/v1/getSystemInfo | sed -e 's/,/\n/g' -e 's/{//g' -e 's/\"//g' | grep status | cut -d\: -f 2- && echo ""
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

			# プレイリスト一覧を表示,trで改行,cutで抽出,echoで空白行の挿入
			[0])
				echo "" && wget -q -O - http://$MPD_HOST/api/v1/listplaylists | tr "," "\n" | cut -d\" -f 2 && echo ""
			;;
	
			# 再生/一時停止
			[1])
				hit_apt toggle && sys_info

			;;
	
			# 停止
			[2])
				hit_apt stop && sys_info

			;;
	
			# 前の曲
			[3])
				hit_apt prev && sys_info

			;;
	
			# 次の曲
			[4])
				hit_apt next && sys_info

			;;

			# リピート 
			[5])
				hit_apt repeat && sys_info

			;;

			# ランダム
			[6])
				hit_apt random && sys_info

			;;

			# システム情報の表示
			[7])
				echo "" && wget -q -O - http://$MPD_HOST/api/v1/getSystemInfo | sed -e 's/,/\n/g' -e 's/{//g' -e 's/\}//g' -e 's/\"//g'  | cut -d\: -f 2- && echo ""
			;;

			# 音量の調整
			[8])
				echo "" && echo 'volume? >' | tr "\n" " " && read volume

				# echoでシングルクォート付きのURLをxargs経由でwgetに渡し,volumeを表示
				echo "" && echo " 'http://$MPD_HOST/api/v1/commands/?cmd=volume&volume=$volume'" | xargs wget -q -O - > /dev/null ; sys_info | grep volume && echo "" 
			;;

			[H])
				echo "" && commands_list
			;;
			 
			# ホスト名の再設定
			[C])
				echo "http://<<hostname or IP_adress>> or localhost" && echo 'hostname? > ' | tr "\n" " " && read hostname ; export MPD_HOST=$hostname && echo "$MPD_HOST" | tee /tmp/hostname && echo ""
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

