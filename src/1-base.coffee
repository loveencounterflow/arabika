
############################################################################################################
π                         = require 'coffeenode-packrattle'
WS                        = require './3-whitespace'
TXT                       = require './2-text'
NUM                       = require './4-numbers'
A                         = require './main'






@_symbol_sigil    = π.string ':'
@symbol           = ( π.seq @_symbol_sigil, WS.nws )
  .onMatch ( match ) => [ 'symbol', match[ 1 ][ 1 ] ]
@_use_keyword     = π.string 'use'
@use_argument     = π.alt @symbol, NUM.digits, TXT.text_literal
@use_statement    = π.seq @_use_keyword, WS.ilws, @use_argument


