# -*- coding: utf-8 -*-
require 'optparse'
# コマンドライン解析機能モジュール - a module to parse command line
# （オプション引数はロングオプションにのみ指定可）
#
#  Copyright(c): 2013 chrono
#  License: The MIT license
#
# Usage
# :Require this file and include CmdlineArgs
#
# :Register specific short(-? type) and long(--?? type) options with regopt* method. 
#
#  Use "regopt" method if you want options without the argument valid.
#   "Short" parameter(string) must be passed if not needed. 
#   If "long" parameter(string) is omitted, '-' + short + '-long' is assigned.
#   "help" parameter(string) is the help message for the options.
#   
#  Use "regopt_with_arg" method if you want options that its argument is required valid.
#   "Short" parameter must be passed.
#   The argument of option is able to be assigned to the long option only.
#    
#  Use "regopt_with_optarg" mehtod if you want options that its argument is optional valid.
#   "Short" parameter must be passed.
#   The argument of option is valid with the long option only.
#   
# :Parse command line with "parse_cmdline" or "parse_cmdline!" method.
#
#  "parse_cmdline" calls OptionParser#parse and "parse_cmdline!" calls OptionParser#parse!.
#
# :Access to indivisual arguments as an element of the "$args" hash.
#
#   For example, "$args[1]" for the second in not-option arguments or "$args['--xpos']"
#   for the argument of "--xpos" option.
#   Use "$args.arg_exist?(hash_key)" method if you want to check existence of specific argument.
#
module CmdlineArgs
  $args = {}
  OPT_ARG_FALSE = 0
  OPT_ARG_TRUE  = 1
  OPT_ARG_OPT   = 2
  @@optparser = OptionParser.new
  
  def regopt( short, long = '', help = '' )
    _regopt( short, long, help )
  end
  
  def regopt_with_arg( short, long = '', help = '' )
    _regopt( short, long, help, OPT_ARG_TRUE )
  end
  
  def regopt_with_optarg( short, long = '', help = '' )
    _regopt( short, long, help, OPT_ARG_OPT )
  end
  
  def _regopt( short, long, help, optarg = OPT_ARG_FALSE )
    return unless short
    return if short == ''
    if long == ''
      long = '-' + short + '-long'
    end
    
    case optarg
      when OPT_ARG_TRUE
        long_val = "#{long}=VAL"
      when OPT_ARG_OPT
        long_val = "#{long}[=VAL]"
      else
        long_val = long
    end
    @@optparser.on( short, long_val, help ) do |arg|
      $args[ short ] = true
      $args[ long ]  = arg
    end
  end
  
  def parse_cmdline!
    @@optparser.parse!( ARGV ).each_with_index do |arg, idx|
      $args[ idx ] = arg
    end
  end
  
  def parse_cmdline
    @@optparser.parse( ARGV ).each_with_index do |arg, idx|
      $args[ idx ] = arg
    end
  end
  
  def reghelp( help )
    @@optparser.on( '-h', '--help' ) { |v| puts help }
  end
  
  def $args.arg_exist?( key_ )
    if self[ key_ ].nil? or self[ key_ ].empty?
      return false
    else
      return true
    end
  end
end
