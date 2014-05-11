
############################################################################################################
π                         = require 'coffeenode-packrattle'
WS                        = require './3-ws'
NUMBER                    = require './4-number'
TEXT                      = require './2-text'
NEW                       = require './new'


#-----------------------------------------------------------------------------------------------------------
@_symbol_sigil    = π.string ':'
@symbol           = ( π.seq @_symbol_sigil, WS.nws )
  .onMatch ( match ) => [ 'symbol', match[ 1 ][ 1 ] ]
@_use_keyword     = π.string 'use'
@use_argument     = π.alt @symbol, NUMBER.digits, TEXT.text_literal
@use_statement    = π.seq @_use_keyword, WS.ilws, @use_argument


