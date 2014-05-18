
############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾0-bracketed-expressions﴿'
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
# BNP                       = require 'coffeenode-bitsnpieces'
NEW                       = require './NEW'
XRE                       = require './9-xre'


#-----------------------------------------------------------------------------------------------------------
@$ =
  'opener':             '⟦'
  'connector':          '∿'
  'closer':             '⟧'


# #-----------------------------------------------------------------------------------------------------------
# # @phrase = ( π.alt => whisper 'phrase'; π.regex /// [^ ( | ) ]+ /// )
# @phrase = ( π.regex /// [^ ( | ) ]+ /// )
#   .onMatch ( match ) ->
#     R = [ 'phrase', match[ 0 ] ]
#     # whisper R
#     return R
#   .describe "one or more non-meta characters"

# #-----------------------------------------------------------------------------------------------------------
# @phrases = ( π.repeatSeparated @phrase, /\|/ )
#   .onMatch ( match ) ->
#     # whisper match
#     return [ 'phrases', match... ]

# #-----------------------------------------------------------------------------------------------------------
# # @bracketed = ( π.alt => whisper 'bracketed'; π.seq '(', ( π.repeat @expression ), ')' )
# @bracketed = ( π.seq '(', ( π.repeat => @expression ), ')' )
#   .onMatch ( match ) ->
#     R = [ 'bracketed', match[ 0 ], match[ 1 ], match[ 2 ], ]
#     # whisper R
#     return R


#-----------------------------------------------------------------------------------------------------------
@expression = ( π.alt @bracketed, @phrases )

#-----------------------------------------------------------------------------------------------------------
@$new = ( options, target ) ->
  options        ?= {}
  options[ name ]?= value for name, value of @$
  R               = target ? {}
  R[ '$' ]        = options
  #.........................................................................................................
  for rule_name, get_rule of @$new
    whisper rule_name
    R[ rule_name ] = get_rule options
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.bracketed = ( $ ) ->
  R = ( π.seq $[ 'opener' ], ( π.repeat => @expression ), $[ 'closer' ] )
    .onMatch ( match ) -> [ 'bracketed', match[ 0 ], match[ 1 ], match[ 2 ], ]
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.phrases = ( $ ) ->
  R = ( π.repeatSeparated @phrase, /// #{XRE.$_esc $[ 'connector' ]} /// )
    .onMatch ( match ) -> [ 'phrases', match... ]
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.phrase = ( $ ) ->
  metachrs  = XRE.$_esc $[ 'opener' ] + $[ 'connector' ] + $[ 'closer' ]
  R         = ( π.regex /// [^ #{metachrs} ]+ /// )
    .onMatch ( match ) ->
      R = [ 'phrase', match[ 0 ] ]
      # whisper R
      return R
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
do ( self = @ ) ->
  for name, value of self.$new null, self
    # self[ name ] = if value.bind? then value.bind self else value
    self[ name ] = value

#-----------------------------------------------------------------------------------------------------------
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  '$new: returns new grammar': ( test ) ->
    info @$new()

  # #---------------------------------------------------------------------------------------------------------
  # 'bracketed: parses simple bracketed phrase': ( test ) ->
  #   source  = """(xxx)"""
  #   # info JSON.stringify @bracketed.run source
  #   test.eq ( @bracketed.run source ), ["bracketed","(",[["phrases",["phrase","xxx"]]],")"]

  # #---------------------------------------------------------------------------------------------------------
  # 'bracketed: parses nested bracketed phrase': ( test ) ->
  #   source  = """(A(B)C)"""
  #   # info JSON.stringify @bracketed.run source
  #   test.eq ( @bracketed.run source ), ["bracketed","(",[["phrases",["phrase","A"]],["bracketed","(",[["phrases",["phrase","B"]]],")"],["phrases",["phrase","C"]]],")"]

  # #---------------------------------------------------------------------------------------------------------
  # 'bracketed: parses multiply nested bracketed phrase': ( test ) ->
  #   source  = """(xxx(yyy(zzz))aaa)"""
  #   # info JSON.stringify @bracketed.run source
  #   test.eq ( @bracketed.run source ), ["bracketed","(",[["phrases",["phrase","xxx"]],["bracketed","(",[["phrases",["phrase","yyy"]],["bracketed","(",[["phrases",["phrase","zzz"]]],")"]],")"],["phrases",["phrase","aaa"]]],")"]

  # #---------------------------------------------------------------------------------------------------------
  # 'bracketed: parses multiply nested bracketed phrase with connectors': ( test ) ->
  #   source  = """(xxx|www|333(yyy(zzz))aaa)"""
  #   # info JSON.stringify @bracketed.run source
  #   test.eq ( @bracketed.run source ), ["bracketed","(",[["phrases",["phrase","xxx"],["phrase","www"],["phrase","333"]],["bracketed","(",[["phrases",["phrase","yyy"]],["bracketed","(",[["phrases",["phrase","zzz"]]],")"]],")"],["phrases",["phrase","aaa"]]],")"]

  # #---------------------------------------------------------------------------------------------------------
  # 'expression: parses simple bracketed phrase': ( test ) ->
  #   source  = """(xxx)"""
  #   # info JSON.stringify @expression.run source
  #   test.eq ( @expression.run source ), ["bracketed","(",[["phrases",["phrase","xxx"]]],")"]

  # #---------------------------------------------------------------------------------------------------------
  # 'expression: parses nested bracketed phrase': ( test ) ->
  #   source  = """(A(B)C)"""
  #   # info JSON.stringify @expression.run source
  #   test.eq ( @expression.run source ), ["bracketed","(",[["phrases",["phrase","A"]],["bracketed","(",[["phrases",["phrase","B"]]],")"],["phrases",["phrase","C"]]],")"]

  # #---------------------------------------------------------------------------------------------------------
  # 'expression: parses multiply nested bracketed phrase': ( test ) ->
  #   source  = """(xxx(yyy(zzz))aaa)"""
  #   # info JSON.stringify @expression.run source
  #   test.eq ( @expression.run source ), ["bracketed","(",[["phrases",["phrase","xxx"]],["bracketed","(",[["phrases",["phrase","yyy"]],["bracketed","(",[["phrases",["phrase","zzz"]]],")"]],")"],["phrases",["phrase","aaa"]]],")"]

  # #---------------------------------------------------------------------------------------------------------
  # 'expression: parses multiply nested bracketed phrase with connectors': ( test ) ->
  #   source  = """(xxx|www|333(yyy(zzz))aaa)"""
  #   # info JSON.stringify @expression.run source
  #   test.eq ( @expression.run source ), ["bracketed","(",[["phrases",["phrase","xxx"],["phrase","www"],["phrase","333"]],["bracketed","(",[["phrases",["phrase","yyy"]],["bracketed","(",[["phrases",["phrase","zzz"]]],")"]],")"],["phrases",["phrase","aaa"]]],")"]


#-----------------------------------------------------------------------------------------------------------
@_ = ->
  njs_fs  = require 'fs'
  write   = ( route, content ) -> njs_fs.writeFileSync route, content
  parse_info = π.parse @expression, source, debugGraph: true
  # parse_info = π.parse @bracketed, source, debugGraph: true
  if parse_info[ 'ok' ]
    info parse_info[ 'match' ]
  else
    warn parse_info[ 'message' ] + '\n' + parse_info[ 'state' ].toSquiggles().join '\n'
    write "/tmp/process.dot", parse_info[ 'state' ].debugGraphToDot()

#-----------------------------------------------------------------------------------------------------------
@_write_graphs = ->
  njs_fs  = require 'fs'
  write   = ( route, content ) -> njs_fs.writeFileSync route, content
  for name in 'expression phrase bracketed'.split /\s+/
    grammar = @[ name ]
    # info ( name for name of grammar )
    write "/tmp/#{name}.dot", grammar.toDot()
    # write "/tmp/#{name}.dot",


############################################################################################################
unless module.parent?
  @_()
  @_write_graphs()



