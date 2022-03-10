# volumio_cli
volumioを制御するシェルスクリプト

## install

```sh
# githubよりclone
$ git clone https://github.com/tekkamelon/volumio_cli

# スクリプトのあるディレクトリへ移動
$ cd volumio_cli/volumio_cli/

# 実行権限を付与
$ chmod 755 volumio_cli.sh
```

## hot to use

```sh
# スクリプトを起動
$ ./volumio_cli.sh
```

起動後にvolumioのホスト名を入力,疎通が確認できればシステム情報を表示  
コマンドの入力を待つ,疎通がなければ一時保存したホスト名を削除し終了
