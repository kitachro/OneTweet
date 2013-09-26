# OneTweetとは

Ruby/GTK2で作ったタイムライン閲覧専用Twitterクライアントです。今のところ本当にツイートを見ること
しかできません。

横長の細長いスペースに、一度にひとつずつ自分のタイムラインのツイートを表示します。

このプログラムはexeファイルではなくRubyスクリプトなので、使うにはまずRubyとRuby/GTK2をインストール
する必要があります。

またTwitterとやりとりする部分の仕事は既存のCUIのクライアントプログラムに丸投げしてますので、そちら
のプログラムもインストールする必要があります。

Windows 7とUbuntu 12.04で動作確認してます。


# ライセンス

このプログラムのすべての関連ファイルにMITライセンスを適用します。ライセンス本文はLICENSE_ja.txt
にあります。


# 動作環境詳細

まずすべての環境で以下のプログラムをインストールする必要があります。

* Ruby 2.0 http://www.ruby-lang.org/ja/downloads/
* Ruby/GTK2 http://ruby-gnome2.sourceforge.jp/ja/

またOSごとに以下のプログラムが必要です。

## Windows
* TweetConsole（t_higashiさん作）
 http://www.vector.co.jp/soft/dl/win95/net/se483315.html
 
## Linux
* earthquake（jugyoさん作。gemとしてインストールできます）
 https://github.com/jugyo/earthquake


# プログラムを起動するには（インストール）

onetweet.rbが入っているフォルダ（ディレクトリ）を好きな場所に移動して（自分がいつもインストール
不要なソフトを置いている所など。Ubuntuであれば~/binがおすすめ）、必要があればフォルダ名を変更
して、onetweet.rbをrubyで実行してください。

## コマンドラインオプション

* --tweetconsole=??? : TweetConsoleの実行ファイルパス。Windowsで使う場合必須。パス
に半角スペースが含まれているときは""で囲んでください。
* --xpos=???     : ウィンドウの表示位置（X座標）
* --ypos=???     : ウィンドウの表示位置（Y座標）
* --width=???    : ウィンドウの横幅（ビクセル）
* --fontsize=??? : フォントサイズ。デフォルトは10なのでそれを目安に指定してください。
* --intervalshow=??? : ツイートの表示を切り替える間隔。秒数を表す数字で指定してください。
デフォルトは10秒。
* --intervalupdate=??? : 新着ツイートをチェックする間隔。秒数を表す数字で指定してください。
デフォルトは120秒。120秒未満にはできません。チェックごとに新着ツイートを20個取得して、未保存のもののみ表示用のタイムラインに追加します。


# プログラムを起動する時の注意

起動時の作業フォルダ（カレントディレクトリ）がonetweet.rbがあるフォルダになっている必要があります。
バッチファイルやシェルスクリプトを使うと比較的簡単にできます。同梱のファイルを参考にしてください。

* onetweet.bat : Windows用。起動用バッチファイル。中身はonetweet.ahkを実行しているだけです。
* onetweet.ahk : Windows用。下の方のAutoHotkey_Lの説明を見てください。
* onetweet.sh  : Linux用。パスが通っているディレクトリに置いて使ってください。

中身のファイルパスや数値は適宜書き換えてください。Linuxでは実行権限も適宜設定してください。


# 使い方

ウィンドウ左側の小さいエリアには現在の動作モードが表示されます。

* |> : ツイート表示自動切り替えモード = ひとつのツイートを10秒（またはコマンドラインオプションで
指定した時間）表示すると次のツイートに自動で切り替わります。デフォルトのモードです。

* || : ツイート表示手動切り替えモード = ツイートの表示を切り替えるのに「Show Prev Tweet」
（前のツイートを表示）または「Show Next Tweet」（次のツイートを表示）コマンドを実行する必要があり
ます。各コマンドは、モード表示エリアを右クリックするかまたはキーボードショートカットから実行できます。

## コマンド一覧

* Pause - [Space] キー : 実行する度に動作モードが反転します。
* Show Prev Tweet - [Page Up] キー : 動作モードにかかわらずタイムラインのひとつ前のツイー
トを表示します。
* Show Next Tweet - [Page Down] キー : 動作モードにかかわらずタイムラインの次のツイート
を表示します。
* Quit - [Ctrl + Q] キー : プログラムを終了します。普通に[Alt + F4]でもOKです。


# 以下のプログラムがあると、Windowsでより便利に使えます。

* AutoHotkey_L http://l.autohotkey.net/

AutoHotkey_Lはアーカイブに入っているonetweet.ahkを実行するのに必要です。onetweet.ahkは
必要に応じてスクリプト内のパスや数値を書き換えて使って下さい。onetweet.ahkは起動時の作業フォ
ルダを指定するのと、コンソールウィンドウを隠すのに使っています。


# このプログラムのGUI部分はGladeで作りました。GladeとRuby/GTK2を組み合わせたプログラミングの
やり方については、チュートリアル程度ですが以下のページに情報があります。

* http://ruby-gnome2.sourceforge.jp/ja/hiki.cgi?libglade2-tut
　古いバージョンについての情報ですが参考にはなると思います。
* http://lldev.jp/ruby/gtk_gnome/create_glade3_app_template/index.html
　gladeファイルからRubyプログラムを生成するプログラムの入手先。Windows用。
* http://sourceforge.jp/projects/sfnet_gladewin32/
　Glade入手先。


# 作者について
chrono
https://twitter.com/kitachro
http://lldev.jp