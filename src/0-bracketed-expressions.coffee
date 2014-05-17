
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾8-character﴿'
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
BNP                       = require 'coffeenode-bitsnpieces'
NEW                       = require './NEW'
XRE                       = require './9-xre'


write = ( route, content ) -> njs_fs.writeFileSync route, content

#-----------------------------------------------------------------------------------------------------------
@phrase = ( π.alt => whisper 'phrase'; π.regex /// [^ ( | ) ]+ /// )
  .onMatch ( match ) ->
    R = [ 'phrase', match[ 0 ] ]
    whisper R
    return R

#-----------------------------------------------------------------------------------------------------------
# @bracketed = ( π.seq '(', π.repeat @expression, ')' )
# @bracketed = ( π.alt => whisper 'bracketed'; π.seq '(', @phrase, ')' )
@bracketed = ( π.alt => whisper 'bracketed'; π.seq '(', ( π.repeat @expression ), ')' )
  .onMatch ( match ) ->
    R = [ 'bracketed', match[ 0 ], match[ 1 ], match[ 2 ], ]
    whisper R
    return R

#-----------------------------------------------------------------------------------------------------------
@expression = ( π.alt => whisper 'expression'; π.alt ( => @bracketed ), ( => @phrase ) )
  # .onMatch ( match ) ->
  #   R = [ 'expression', match... ]
  #   whisper R
  #   return R

#-----------------------------------------------------------------------------------------------------------
source  = """(xxx)"""
source  = """(A(B)C)"""
source  = """(xxx(yyy(zzz))aaa)"""
# info bracketed.run source

#-----------------------------------------------------------------------------------------------------------
@main = ->
  parse_info = π.parse @expression, source, debugGraph: true
  # parse_info = π.parse @bracketed, source, debugGraph: true
  if parse_info[ 'ok' ]
    info parse_info[ 'match' ]
  else
    warn parse_info[ 'message' ] + '\n' + parse_info[ 'state' ].toSquiggles().join '\n'
    write "/tmp/process.dot", parse_info[ 'state' ].debugGraphToDot()

#-----------------------------------------------------------------------------------------------------------
@_write_graphs = ->
  for name in 'expression phrase bracketed'.split /\s+/
    grammar = @[ name ]
    # info ( name for name of grammar )
    write "/tmp/#{name}.dot", grammar.toDot()
    # write "/tmp/#{name}.dot",

@main()



