
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾experiments﴿'
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
### https://github.com/isaacs/node-glob ###
glob                      = require 'glob'
### https://github.com/loveencounterflow/coffeenode-packrattle,
forked from https://github.com/robey/packrattle ###
π                         = require 'coffeenode-packrattle'
#...........................................................................................................
@new                      = require './nodes'
A                         = require './main'

info A
info name for name of A



### TAINT translation routines should be
(1) independent from grammar, so we can translate to different targets;
(2) be modular and extensible, so new forms of expression can implement both new syntax
    and ways of translation to different targets.
Point (2) is not possible with a `switch`-dispatcher.
###
#-----------------------------------------------------------------------------------------------------------
@as_coffeescript = ( node ) ->
  ### TAINT makeshift for smooth transition to SpiderMonkey Parser API ###
  if ( type = node[ 'type' ] )?
    null
  else
    [ type, content... ] = node
  # debug node
  switch type
    #.......................................................................................................
    when 'assignment'
      unless content.length is 2
        throw new Error "expected identifier and expression node, got #{rpr content}"
      [ identifier_node, expression_node ] = content
      unless ( sub_type = identifier_node[ 0 ] ) is 'identifier'
        throw new Error "expected identifier node, got #{sub_type}"
      crumbs_node = [ 'crumbs', identifier_node[ 1 ], ]
      return "$v#{@as_coffeescript crumbs_node} = #{@as_coffeescript expression_node}"
    #.......................................................................................................
    when 'crumbs'
      ### TAINT must escape identifier ###
      ### TAINT shouldn't we also use variables in the target language? ###
      return ( "[ '#{crumb}' ]" for crumb in content ).join ''
    #.......................................................................................................
    when 'expression'
      ### TAINT how to join? ###
      return ( @as_coffeescript sub_expression for sub_expression in content ).join ' '
    #.......................................................................................................
    when 'Literal'
      ### TAINT better to use node[ 'raw' ]? ###
      return rpr node[ 'value' ]
    #.......................................................................................................
    when 'BinaryExpression'
      ### TAINT wrongly assumes operator has direct equivalent in target language ###
      { left, operator, right, } = node
      return "#{@as_coffeescript left} #{operator} #{@as_coffeescript right}"
    #.......................................................................................................
    when 'text'
      ### TAINT text literal should be kept intact ###
      return rpr content[ 1 ]
    #.......................................................................................................
    when 'symbol'
      return @as_coffeescript [ 'text', '"', content[ 0 ], '"' ]
    #.......................................................................................................
    when 'use'
      ### TAINT `use` statement not to be translated ###
      return """
        ### `use` statement ###
        use #{@as_coffeescript content[ 0 ]}"""
    #.......................................................................................................
    else
      warn "skipped #{type} #{rpr content}"
      return "???"


############################################################################################################
node = A.assignment.run 'xy: 20 + 3'
info @as_coffeescript node
node = A.assignment.run 'foo/bar: 20 + 3'
info @as_coffeescript node
# node = A.assignment.run 'foo/bar: gnu/cram'
# info @as_coffeescript node



info '\n' + rpr A.list.run '[ 3, 10, 200 ]'
info '\n' + rpr A.list.run '[]'

info '\n' + rpr A.assignment.run 'xy: 20 + 3'

info '\n' + rpr A.expression.run '3 + 10 + 200'
info '\n' + rpr A.expression.run '3 * 10 + 200'
info '\n' + rpr A.expression.run '3 + 10 * 200'
info '\n' + rpr A.expression.run '42'


info rpr A._single_quote.run  "'"
info rpr A._double_quote.run  '"'
info rpr A._chr_escaper.run   '\\'
info rpr A.simple_escape.run 'n'
info rpr A._unicode_hex.run   'u4e01'
info rpr A._escaped.run       '\\u4e01'
info rpr A._escaped.run       '\\n'
info rpr A._nosq.run          'abcdef'
info rpr A._nodq.run          'ioxuy'
info rpr A._dq_text_literal.run '"foo"'
info rpr A._sq_text_literal.run "'foo'"
info rpr node = A.text_literal.run  '"helo"'
debug '\n' + @as_coffeescript node
info rpr node = A.text_literal.run  "'helo'"
debug '\n' + @as_coffeescript node


info node = A.use_statement.run 'use 123'
debug '\n' + @as_coffeescript node
info node = A.use_statement.run 'use :foo'
debug '\n' + @as_coffeescript node
info node = A.use_statement.run 'use "foo\nbar"'
debug '\n' + @as_coffeescript node

# ESPRIMA                   = require 'esprima'
# ESCODEGEN                 = require 'escodegen'


# node = A.new.binary_expression '+', ( A.new.literal '3', 3 ), ( A.new.literal '4', 4 )

# info ESCODEGEN.generate node
# info ESPRIMA.parse 'var a = "3 + 4"'
