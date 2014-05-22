
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾0-experiments﴿'
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
A                         = require './main'


@_ = ->
  # info A
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

  f = ->
    node = A.UNSORTED.assignment.run 'xy: 20 + 3'
    info @as_coffeescript node
    node = A.UNSORTED.assignment.run 'foo/bar: 20 + 3'
    info @as_coffeescript node
    # node = A.UNSORTED.assignment.run 'foo/bar: gnu/cram'
    # info @as_coffeescript node



    info '\n' + rpr A.UNSORTED.list.run '[ 3, 10, 200 ]'
    info '\n' + rpr A.UNSORTED.list.run '[]'

    info '\n' + rpr A.UNSORTED.assignment.run 'xy: 20 + 3'

    info '\n' + rpr A.UNSORTED.expression.run '3 + 10 + 200'
    info '\n' + rpr A.UNSORTED.expression.run '3 * 10 + 200'
    info '\n' + rpr A.UNSORTED.expression.run '3 + 10 * 200'
    info '\n' + rpr A.UNSORTED.expression.run '42'


    info rpr A.TEXT._single_quote.run  "'"
    info rpr A.TEXT._double_quote.run  '"'
    info rpr A.TEXT._chr_escaper.run   '\\'
    info rpr A.TEXT.simple_escape.run 'n'
    info rpr A.TEXT._unicode_hex.run   'u4e01'
    info rpr A.TEXT._escaped.run       '\\u4e01'
    info rpr A.TEXT._escaped.run       '\\n'
    info rpr A.TEXT._nosq.run          'abcdef'
    info rpr A.TEXT._nodq.run          'ioxuy'
    info rpr A.TEXT._dq_text_literal.run '"foo"'
    info rpr A.TEXT._sq_text_literal.run "'foo'"
    info rpr node = A.TEXT.literal.run  '"helo"'
    debug '\n' + @as_coffeescript node
    info rpr node = A.TEXT.literal.run  "'helo'"
    debug '\n' + @as_coffeescript node


    info node = A.BASE.use_statement.run 'use 123'
    debug '\n' + @as_coffeescript node
    info node = A.BASE.use_statement.run 'use :foo'
    debug '\n' + @as_coffeescript node
    info node = A.BASE.use_statement.run 'use "foo\nbar"'
    debug '\n' + @as_coffeescript node

    # ESPRIMA                   = require 'esprima'
    # ESCODEGEN                 = require 'escodegen'


    # node = A.new.binary_expression '+', ( A.new.literal '3', 3 ), ( A.new.literal '4', 4 )

    # info ESCODEGEN.generate node
    # info ESPRIMA.parse 'var a = "3 + 4"'

  rv = π.consume A.TEXT.literal, '"+n"', debugGraph: true
  njs_fs.writeFileSync '/tmp/test2.dot', rv.state.debugGraphToDot()

#-----------------------------------------------------------------------------------------------------------
check_nws = ->
  CHR   = require './3-chr'
  test  = ( require './test' ).test
  @$ =
    'start-of-material':  CHR.nws
  material = '\thelo'
  material = 'helo'
  parser = π.alt $[ 'start-of-material' ]
  parser = parser.onMatch ( match ) ->
    debug rpr match
    throw new Error "xxx"
    return match
  # debug parser.run material[ 0 ]
  debug test.throws ( -> parser.run material[ 0 ] ), /xxx/
  # debug test.throws ( -> parser.run material[ 0 ] ), /wrong/ # ok
  # try

#-----------------------------------------------------------------------------------------------------------
try_splice = ->
  splice = ( me, you, idx = 0 ) ->
    ### TAINT `splice` is not too good a name for this functionality i guess ###
    ### thx to http://stackoverflow.com/a/12190006/256361 ###
    Array::splice.apply me, [ idx, 0, ].concat you
    return me
  d = [ 'a', 'b', 'c', ]
  e = [ '1', '2', '3', ]
  splice d, e, 1
  log d

#-----------------------------------------------------------------------------------------------------------
try_escodegen = ->
  ESCODEGEN                 = require 'escodegen'
  ESPRIMA                   = require 'esprima'
  escodegen_options         = ( require '../options' )[ 'escodegen' ]
  node =
    'type':         'Literal'
    'x-subtype':    'phrase'
    'x-verbatim':   'for x in xs'
    'raw':          'for x in xs'
    'value':        'for x in xs'
  # info ESCODEGEN.generate node, escodegen_options
  node =
    'type':         'BlockStatement',
    'x-subtype':    'suite',
    'body':         [ node, ]
  # info ESCODEGEN.generate node, escodegen_options

  source = """
    for( i = f(); i++; i < 100 ){ x = g(); log( i ); }
  """
  # debug ESPRIMA.parse source

  `
  node = { type: 'BlockStatement',
            body:
             [ { type: 'ExpressionStatement',
                 expression:
                  { type: 'AssignmentExpression',
                    operator: '=',
                    left: { type: 'Identifier', name: 'x' },
                    right:
                     { type: 'CallExpression',
                       callee: { type: 'Identifier', name: 'g' },
                       arguments: [] } } },
               { type: 'ExpressionStatement',
                 expression:
                  { type: 'CallExpression',
                    callee: { type: 'Identifier', name: 'log' },
                    arguments: [ { type: 'Identifier', name: 'i' } ] } } ] }
  `
  # `
  # node = { type: 'BlockStatement',
  #           body:
  #            [ { type: 'AssignmentExpression',
  #                   operator: '=',
  #                   left: { type: 'Identifier', name: 'x' },
  #                   right:
  #                    { type: 'CallExpression',
  #                      callee: { type: 'Identifier', name: 'g' },
  #                      arguments: [] } },
  #              { type: 'ExpressionStatement',
  #                expression:
  #                 { type: 'CallExpression',
  #                   callee: { type: 'Identifier', name: 'log' },
  #                   arguments: [ { type: 'Identifier', name: 'i' } ] } } ] }
  # `
  `
  node = { type: 'BlockStatement',
  'x-subtype': 'suite',
  body:
   [ { type: 'ExpressionStatement',
       'x-subtype': 'auto',
       expression:
        { type: 'Literal',
          'x-subtype': 'phrase',
          'x-verbatim': 'if x > 0',
          raw: 'if x > 0',
          value: 'if x > 0' } },
     { type: 'BlockStatement',
       'x-subtype': 'suite',
       body:
        [ { type: 'ExpressionStatement',
            'x-subtype': 'auto',
            expression:
             { type: 'Literal',
               'x-subtype': 'phrase',
               'x-verbatim': 'log \'ok\'',
               raw: 'log \'ok\'',
               value: 'log \'ok\'' } } ] } ] }  `
  info ESCODEGEN.generate node, escodegen_options



# { type: 'BlockStatement',
#   'x-subtype': 'suite',
#   body:
#    [ { type: 'Literal',
#        'x-subtype': 'phrase',
#        'x-verbatim': 'f = ->',
#        raw: 'f = ->',
#        value: 'f = ->' },
#      ,
#      { type: 'BlockStatement',
#        'x-subtype': 'suite',
#        body:
#         [ { type: 'Literal',
#             'x-subtype': 'phrase',
#             'x-verbatim': 'for x in xs',
#             raw: 'for x in xs',
#             value: 'for x in xs' },
#           ,
#           { type: 'BlockStatement',
#             'x-subtype': 'suite',
#             body:
#              [ { type: 'Literal',
#                  'x-subtype': 'phrase',
#                  'x-verbatim': 'while x > 0',
#                  raw: 'while x > 0',
#                  value: 'while x > 0' },
#                ,
#                { type: 'BlockStatement',
#                  'x-subtype': 'suite',
#                  body:
#                   [ { type: 'Literal',
#                       'x-subtype': 'phrase',
#                       'x-verbatim': 'x -= 1',
#                       raw: 'x -= 1',
#                       value: 'x -= 1' },
#                     { type: 'Literal',
#                       'x-subtype': 'phrase',
#                       'x-verbatim': 'log x',
#                       raw: 'log x',
#                       value: 'log x' },
#                     { type: 'Literal',
#                       'x-subtype': 'phrase',
#                       'x-verbatim': 'g x',
#                       raw: 'g x',
#                       value: 'g x' },
#                      ] } ] },
#           { type: 'Literal',
#             'x-subtype': 'phrase',
#             'x-verbatim': 'log \'ok\'',
#             raw: 'log \'ok\'',
#             value: 'log \'ok\'' },
#           { type: 'Literal',
#             'x-subtype': 'phrase',
#             'x-verbatim': 'log \'over\'',
#             raw: 'log \'over\'',
#             value: 'log \'over\'' },
#            ] } ] }

#-----------------------------------------------------------------------------------------------------------
try_reduce = ->
  # ### Parses nested structures.
  # * **meta-characters** are `<`, `=`, `>` (easy to type, not special in RegExes);
  # * **material characters** are code points that are not meta-characters;
  # * **phrase**: a contiguous sequence of material characters;
  # * **suite**: a contiguous sequence of phrases;
  # * **stage**: suites with a common parent; may include nested stages
  # * **module**: the outermost stage of a given source.

  # # * **chunk**
  # # * **block**

  # Valid inputs include:

  # ````
  # <>
  # <1>
  # <1 = 2>
  # <1 = 2 <3>>
  # <1 = 2 <3 <4>>
  # <1 = 2 <3 <4 = 5>>
  # <1 = 2 <3 <4 = 5> 6>
  # <1 = 2 <3 <4 = 5> 6 = 7>
  # ````

  # ###
  # accumulator = null
  # reducer     = null

  # #---------------------------------------------------------------------------------------------------------
  # phrase      = π.alt /[^<=>]+/
  # phrase      = phrase.onMatch ( match ) -> match[ 0 ]

  # #---------------------------------------------------------------------------------------------------------
  # suite       = π.repeatSeparated phrase, /=/
  # suite       = suite.onMatch ( match ) -> [ 'suite', match... ]

  # #---------------------------------------------------------------------------------------------------------
  # chunk       = π.alt ( -> suite ), ( -> stage )
  # chunk       = chunk.onMatch ( match ) -> [ 'chunk', match... ]

  # #---------------------------------------------------------------------------------------------------------
  # stage       = π.seq /</, ( ), />/
  # #---------------------------------------------------------------------------------------------------------
  # debug suite.run "7,5,3"



############################################################################################################
unless module.parent?
  # check_nws()
  try_reduce()
  # try_splice()
  # try_escodegen()











