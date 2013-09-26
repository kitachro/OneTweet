#! /usr/local/bin/ruby
# -*- coding: utf-8 -*-
#
# * このコードはRuby 2.x / Ruby-GNOME2 2.x 用です。
#
#  Copyright(c): 2013 chrono
#  License: The MIT license

require './onetweet_glade'
require './cmdlineargs'

class Onetweet < OnetweetGlade
  include CmdlineArgs
  
  OPT_LONG_XPOS = '--xpos'
  OPT_LONG_YPOS = '--ypos'
  OPT_LONG_WIDTH = '--width'
  OPT_LONG_FONTSIZE = '--fontsize'
  OPT_LONG_TWEETCONSOLE = '--tweetconsole'
  OPT_LONG_INTERVALSHOW = '--intervalshow'
  OPT_LONG_INTERVALUPDATE = '--intervalupdate'
  LABEL_MODE_PLAY = '|>'
  LABEL_MODE_PAUSE = '||'
    
  def initialize( path_or_data, root = nil, domain = nil, localedir = nil )
    super
    regopt_with_arg( '-x', OPT_LONG_XPOS )
    regopt_with_arg( '-y', OPT_LONG_YPOS )
    regopt_with_arg( '-w', OPT_LONG_WIDTH )
    regopt_with_arg( '-f', OPT_LONG_FONTSIZE )
    regopt_with_arg( '-t', OPT_LONG_TWEETCONSOLE )
    regopt_with_arg( '-i', OPT_LONG_INTERVALSHOW )
    regopt_with_arg( '-I', OPT_LONG_INTERVALUPDATE )
    parse_cmdline!
    
    @interval_show = ( $args[ OPT_LONG_INTERVALSHOW ] || 10 ).to_i
    @interval_update = ( $args[ OPT_LONG_INTERVALUPDATE ] || 120 ).to_i
    @interval_update = 120 if @interval_update < 120
  
    initialize_gui( OPT_LONG_XPOS => $args[ OPT_LONG_XPOS ], 
                    OPT_LONG_YPOS => $args[ OPT_LONG_YPOS ], 
                    OPT_LONG_WIDTH => $args[ OPT_LONG_WIDTH ], 
                    OPT_LONG_FONTSIZE => $args[ OPT_LONG_FONTSIZE ] )
    initialize_timeline
  end
  
  # signal handlers #

  def on_window_main_destroy(widget, *args)
    quit_app
  end

  def on_window_main_delete_event(widget, *args)
    false
  end
  
  def on_eventbox_label_mode_button_press_event(widget, *args)
    if args[ 0 ].button == 3 # 右ボタン
      @menu_app_commands.popup( nil, nil, 3, 0 )
    end
  end

  def on_checkmenuitem_pause_toggled(widget, *args)
    if @checkmenuitem_pause.active?
      @label_mode.text = LABEL_MODE_PAUSE
    else
      @label_mode.text = LABEL_MODE_PLAY
    end
  end

  def on_menuitem_show_prev_tweet_activate(widget, *args)
    show_prev_tweet
  end

  def on_menuitem_show_next_tweet_activate(widget, *args)
    show_next_tweet
  end

  def on_menuitem_quit_activate(widget, *args)
    quit_app
  end

  # subroutines #
  
  def initialize_gui( args )
    accelgroup = Gtk::AccelGroup.new
    accelgroup.connect( Gdk::Keyval::GDK_space, nil, Gtk::ACCEL_VISIBLE ) do
      @checkmenuitem_pause.active = !@checkmenuitem_pause.active?
    end
    accelgroup.connect( Gdk::Keyval::GDK_Page_Up, nil, Gtk::ACCEL_VISIBLE ) do
      show_prev_tweet
    end
    accelgroup.connect( Gdk::Keyval::GDK_Page_Down, nil, Gtk::ACCEL_VISIBLE ) do
      show_next_tweet
    end
    accelgroup.connect( Gdk::Keyval::GDK_Q, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE ) do
      quit_app
    end
    @window_main.add_accel_group( accelgroup )
    
    if args[ OPT_LONG_XPOS ] && args[ OPT_LONG_YPOS ]
      @window_main.move( args[ OPT_LONG_XPOS ].to_i, args[ OPT_LONG_YPOS ].to_i )
    end
    if args[ OPT_LONG_WIDTH ]
      @window_main.resize( args[ OPT_LONG_WIDTH ].to_i, @window_main.size[ 1 ] )
    end
    
    @label_mode.text = LABEL_MODE_PLAY

    size = args[ OPT_LONG_FONTSIZE ] || '10'
    @entry_tweet.modify_font( Pango::FontDescription.new( size ) ) 
  end
  
  def initialize_timeline
    case RUBY_PLATFORM
    when /(mingw|win)/ # Windows
      client = TweetConsole
    else
      client = Earthquake
    end
    @timeline = Timeline.new( client, Timeline::TYPE_HOME, @interval_update )
    @index_current_tweet = -1
    
    show_next_tweet
    GLib::Timeout.add_seconds( @interval_show ) do
      Thread.new do
        unless @checkmenuitem_pause.active?
          show_next_tweet
        end
      end
      true
    end
  end
  
  def show_next_tweet
    return if @index_current_tweet >= ( @timeline.count - 1 )
    @index_current_tweet = @index_current_tweet + 1
    show_current_tweet
  end
  
  def show_prev_tweet
    return if @index_current_tweet <= 0
    @index_current_tweet = @index_current_tweet - 1
    show_current_tweet
  end

  def show_current_tweet
    @entry_tweet.text = "[#{@index_current_tweet + 1}/#{@timeline.count}] " + 
                        @timeline[ @index_current_tweet ].userid + ' ' + 
                        @timeline[ @index_current_tweet ].date + ' ' + 
                        @timeline[ @index_current_tweet ].body
  end
  
  def quit_app
    Gtk::main_quit
  end
  
  class Timeline
    TYPE_HOME = 0

    include Enumerable
    def each
      @tweets.each do |tweet|
        yield tweet
      end
    end

    def initialize( client, type, interval_update )
      @client = client
      @type = type
      @interval_update = interval_update
      @tweets = Array.new

      Thread.new { update }
      GLib::Timeout.add_seconds( @interval_update ) do
        Thread.new { update }
        true
      end
    end
    
    def []( index )
      return @tweets[ index ]
    end
    
    private
    
    def update
      tweets = Array.new

      case @type
      when TYPE_HOME
        tweets = @client.home_timeline
      end
      tweets.sort! do |a, b|
        a.date <=> b.date
      end
          
      # 重複チェックしながら表示用タイムラインに追加
      tweets.each do |tweet|
        unless include?( tweet )
          @tweets << tweet
        end
      end
    end
    
    def include?( tweet )
      @tweets.reverse_each do |member|
        return true if tweet === member
      end
      false
    end
  end#class Timeline
  
  class Tweet
    attr_accessor :userid, :date, :body

    def initialize( items )
      @userid, @date, @body = items
      @userid ||= ""
      @date ||= ""
      @body ||= ""
    end
    
    def ===( other )
      return false unless @userid == other.userid
      return false unless @date == other.date
      return false unless @body == other.body
      true
    end
  end#class Tweet

  class TweetConsole
    def self.home_timeline( count = 20 )
      lines = ''
      IO.popen( $args[ OPT_LONG_TWEETCONSOLE ] + " /ra #{count}", 'r' ) { |io|
        lines = io.readlines
      }
      lines_to_tweets( lines )
    end

    def self.lines_to_tweets( lines )
      # 取得したデータをTweetの配列に変換
      tweet = nil
      tweets = Array.new
      lines.each do |line|
        # ツイートヘッダなら
        if line.encode( 'utf-8' ) =~ /\w+:\d{4}年\d{1,2}月\d{1,2}日\((日|月|火|水|木|金|土)\)\d{1,2}時\d{1,2}分/#
          tweets << tweet if tweet
          tweet = Tweet.new( line.chomp.split( ':', 2 ) )
        else
          tweet.body << line
        end
      end
      if lines.length > 0 # 最後のツイートも忘れずに
        tweets << tweet if tweet
      end
      return tweets
    end
  end#class TweetConsole

  class Earthquake
    def self.home_timeline( count = 20 )
      lines = ''
      IO.popen( 'earthquake --no-logo --command=:recent', 'r' ) { |io|
        lines = io.readlines
      }
      lines_to_tweets( lines )
    end

    def self.lines_to_tweets( lines )
      # 取得したデータをTweetの配列に変換
      tweet = Tweet.new
      tweets = Array.new
      lines.each do |line|
        line.chomp!
        if line == '---this-is-a-delimiter-for-earthquake-tweets---'
          tweets << tweet
          tweet = Tweet.new
          next
        elsif tweet.userid == ""
          tweet.userid = line
        elsif tweet.date == ""
          tweet.date = line
        else
          tweet.body << line
        end
      end
      return tweets
    end
  end#class Earthquake
end#class Onetweet

# Main program
if __FILE__ == $0
  PROG_PATH = "onetweet.glade"
  PROG_NAME = "onetweet"
  Onetweet.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
