

###

# Demo: Parametrized Grammars

## Rationale

In this module, we want to explore how to parametrize grammars.

Let's say you've found a grammar `G` that parses nested lists, as in `[ 1, [ 2, 3, [ 4 ], 5 ]]`. Obviously,
if the grammar works for square brackets, it should not only work for pointy brackets, too, and for any pair
of distinct characters `( o, c )`. Likewise, the mark that separates elements could conceivably any old
character, as long as it fits into the general setup of the rest of the language. Finally, what is allowed
to appear as e single element in such a construct is a 'little language' (a grammar, a rule) in its own
right—it's easy to see that if this version works for list literals à la what's sketched aboved, it can,
mutatis mutandis, also serve to parse set literals like `{ 1, { 2, 3, { 4 }, 5 }}` and POD literals like
`{ a: 1, { b: 2, c: 3, { d: 4 }, e: 5 }}`.

## Naming Conventions

In non-parametrized ('direct', or 'constant') grammars, you bind all your rules to `@` (`this`) on the
module level. You should start all rules that are part of the grammar proper (i.e. those that produce
use the Arabika `new` module to produce AST nodes that are in line with the
[SpiderMonkey Parser API](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey/Parser_API))
with a lower case Latin letter (although nothing keeps you from using other scripts if you feel like it).

Grammar rules should generally be kept as short as possible—typically, they're one-liners (plus an
`.onMatch()` handler, also often on a single line). This is mainly because the `packrattle` parser is wont
to throw hard-to-interpret error messages that do not include references to the source code line that caused
the trouble; it is therefore of paramount importance to break down the parsing process into many small
pieces with focussed concerns, each of which should be individually tested in the `$TESTS` section (see
below); that way, it's easier to narrow down faulty grammar rules.

As a side effect of working with *lots* of very simple rules, it's not always convenient to have all rules
produce full-blown SM Parser API nodes; often, a simple list or a string is all the result you need. Also,
helper functions, options objects and data collections are sometimes needed to sort things out in an
organized fashion. To help consumers identify exactly which rules produce Parser API nodes, the convention
is to give all such methods names that start with a lower case Latin letter; all methods and other objects
that serve other purposes should start with a `$` (dollar sign).


###



############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾0-parametrized-grammars﴿'
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
### ###
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
### TAINT move to NEW ###
@$new = ( options, target ) ->
  options        ?= {}
  options[ name ]?= value for name, value of @$
  R               = target ? {}
  R[ '$' ]        = options
  R[ '$new' ]     = @$new
  #.........................................................................................................
  for rule_name, get_rule of @$new
    # whisper rule_name
    R[ rule_name ] = get_rule R, options
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.bracketed = ( G, $ ) ->
  R = π.seq $[ 'opener' ], ( π.repeat => G.expression ), $[ 'closer' ]
  R.onMatch ( match ) -> [ 'bracketed', match[ 0 ], match[ 1 ], match[ 2 ], ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.phrases = ( G, $ ) ->
  R = π.repeatSeparated G.phrase, /// #{XRE.$_esc $[ 'connector' ]} ///
  R.onMatch ( match ) -> [ 'phrases', match... ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.phrase = ( G, $ ) ->
  metachrs  = XRE.$_esc $[ 'opener' ] + $[ 'connector' ] + $[ 'closer' ]
  R         = π.regex /// [^ #{metachrs} ]+ ///
  R.onMatch ( match ) -> [ 'phrase', match[ 0 ] ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.expression = ( G, $ ) ->
  return π.alt G.bracketed, G.phrases

#-----------------------------------------------------------------------------------------------------------
@$new null, @

#-----------------------------------------------------------------------------------------------------------
@$TESTS =

  # #---------------------------------------------------------------------------------------------------------
  # '$new: returns new grammar': ( test ) ->
  #   ### TAINT move to NEW ###
  #   info name for name of @$new()

  #---------------------------------------------------------------------------------------------------------
  'bracketed: parses simple bracketed phrase': ( test ) ->
    G       = @$new opener: '(', connector: '|', closer: ')'
    source  = """(xxx)"""
    # info JSON.stringify @bracketed.run source
    test.eq ( G.bracketed.run source ), ["bracketed","(",[["phrases",["phrase","xxx"]]],")"]

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



