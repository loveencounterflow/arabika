
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾0-unsorted﴿'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM
rainbow                   = TRM.rainbow.bind TRM
#...........................................................................................................
π                         = require 'coffeenode-packrattle'
CHR                       = require './3-chr'
NUMBER                    = require './4-number'
FLOWMATIC                 = require 'flowmatic'
$new                      = FLOWMATIC.new

@_ = ->

  #-----------------------------------------------------------------------------------------------------------
  @_operator_on_match  = ( match ) ->
    [ 'operator', match[ 0 ], ]
  #-----------------------------------------------------------------------------------------------------------
  @_operation_on_match = ( match ) ->
    left      = match[ 0 ]
    operator  = match[ 1 ][ 1 ]
    right     = match[ 2 ]
    # whisper [ left, operator, right ]
    return NEW.binary_expression operator, left, right
    # return [ match[ 1 ][ 0 ], match[ 1 ][ 1 ], match[ 0 ], match[ 2 ], ]

  #-----------------------------------------------------------------------------------------------------------
  @plus   = ( π.string '+' ).onMatch @_operator_on_match
  @times  = ( π.string '*' ).onMatch @_operator_on_match

  #-----------------------------------------------------------------------------------------------------------
  ###
  possible:
    addition    = π.seq ( -> expression ), ( -> lws ), ( -> plus ), ( -> lws ), ( -> expression )
  not possible:
    addition    = π.seq expression, lws, plus, lws, expression
  ###
  @addition        = ( π.seq ( => @expression ), CHR.ilws, @plus,  CHR.ilws, ( => @expression ) )
    .onMatch @_operation_on_match.bind @

  @multiplication  = ( π.seq ( => @expression ), CHR.ilws, @times, CHR.ilws, ( => @expression ) )
    .onMatch @_operation_on_match.bind @

  @sum             = π.alt @addition, NUMBER.digits
  @product         = π.alt @multiplication, NUMBER.digits
  @expression      = ( π.alt @sum, @product )
    .onMatch ( match ) => [ 'expression', match, ]




  @list_kernel = ( π.repeatSeparated ( => @expression ), π [ ',', CHR.ilws, ] )
    # .onMatch ( match ) -> [ 'long-sum', [ m for m in match when ( m[ 0 ] isnt 'operator' and m[ 1 ] isnt '+' ) ]..., ]
  @empty_list  = ( π.seq '[', ( π.optional CHR.ilws ), ']' )
    .onMatch ( match ) => [ 'list', ]
  @filled_list = ( π.seq '[', CHR.ilws, ( π.optional @list_kernel ), CHR.ilws, ']' )
    .onMatch ( match ) => [ 'list', match[ 1 ]... ]
  @list = π.alt @empty_list, @filled_list

  ### TAINT does not respected escaped slashes, interpolations ###
  @identifier = ( π.regex /^[^0-9][^\s:]*/ )
    .onMatch ( match ) => [ 'identifier', match[ 0 ].split '/', ]
  @assignment = ( π [ @identifier, ':', CHR.ilws, @expression, ] )
    .onMatch ( match ) => [ 'assignment', match[ 0 ], match[ 2 ], ]

