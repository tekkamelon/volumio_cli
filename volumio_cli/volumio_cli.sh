#!/bin/bash

echo "http://<<please type your hostname>>.local"
read "hostname"

curl http://$hostname.local/api/v1/listplaylists | sed 's/,/\n/g'

# echo "\nplease type command" 
echo "playback -> play"
echo "pause -> pause"
echo "stop -> stop"
read -p "please type command" ; "command"
	case "$command" in
		[qQ]) echo "exit" ;;
		*) curl http://$hostname$http.local/api/v1/commands/?cmd=$command
	esac
