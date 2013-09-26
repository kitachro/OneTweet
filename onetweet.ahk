SetTitleMatchMode,3
IfWinNotExist, OneTweet
{
	Run, C:\ruby\bin\ruby.exe C:\Users\hoge\onetweet_gtk\onetweet.rb --xpos=1366 --ypos=0 --width=1366 --tweetconsole="c:\Users\hoge\TweetConsole\twtcnsl.exe", C:\Users\hoge\onetweet_gtk
	WinWait, C:\ruby\bin\ruby.exe
	WinHide, C:\ruby\bin\ruby.exe
}
Exit
