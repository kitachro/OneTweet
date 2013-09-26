#! ruby
# -*- coding: utf-8 -*-
#  This code is for Ruby 2.x and Ruby-GNOME2 2.x.
#
#  Copyright(c): 2013 chrono
#  License: The MIT license

require 'gtk2'
#require 'gettext' # uncomment if you use GetText gem.

class OnetweetGlade
#  include GetText # uncomment if you use GetText gem.

  def initialize(path_or_data, root = nil, domain = nil, localedir = nil)
#    bindtextdomain(domain, localedir, nil, "UTF-8") # uncomment if you use GetText gem.
    @glade = Gtk::Builder.new
    @glade.add(path_or_data)
    @glade.connect_signals {|handler_name| method(:"#{handler_name}")}

    @window_main = @glade['window_main']
    @hbox = @glade['hbox']
    @eventbox_label_mode = @glade['eventbox_label_mode']
    @label_mode = @glade['label_mode']
    @entry_tweet = @glade['entry_tweet']
    @menu_app_commands = @glade['menu_app_commands']
    @checkmenuitem_pause = @glade['checkmenuitem_pause']
    @menuitem_show_prev_tweet = @glade['menuitem_show_prev_tweet']
    @menuitem_show_next_tweet = @glade['menuitem_show_next_tweet']
    @menuitem_quit = @glade['menuitem_quit']
    @window_main.show_all
#    replace 'window_main' with your name of main(primary) window.
  end

  def on_window_main_destroy(widget, *args)
    puts 'on_window_main_destroy'
  end

  def on_window_main_delete_event(widget, *args)
    puts 'on_window_main_delete_event'
  end

  def on_eventbox_label_mode_button_press_event(widget, *args)
    puts 'on_eventbox_label_mode_button_press_event'
  end

  def on_checkmenuitem_pause_toggled(widget, *args)
    puts 'on_checkmenuitem_pause_toggled'
  end

  def on_menuitem_show_prev_tweet_activate(widget, *args)
    puts 'on_menuitem_show_prev_tweet_activate'
  end

  def on_menuitem_show_next_tweet_activate(widget, *args)
    puts 'on_menuitem_show_next_tweet_activate'
  end

  def on_menuitem_quit_activate(widget, *args)
    puts 'on_menuitem_quit_activate'
  end

end#class

# Main program
if __FILE__ == $0
  PROG_PATH = "onetweet.glade"
  PROG_NAME = "onetweet"
  OnetweetGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
