#!/bin/bash

echo "http://<<please type your hostname>>.local"
read "hostname"

curl http://$hostname.local/api/v1/listplaylists

echo "\nplease type command"
echo "playback -> play"
echo "pause -> pause"
echo "stop -> stop"
read "command"

curl http://$hostname$http.local/api/v1/commands/?cmd=$command
