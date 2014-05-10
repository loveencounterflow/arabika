
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'πx'
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

#-----------------------------------------------------------------------------------------------------------
@some_digits = ( π.regex /[0-9]+/ )
  .onMatch ( match ) -> [ 'number', match[ 0 ], ]

#-----------------------------------------------------------------------------------------------------------
### Linear WhiteSpace ###
@lws = ( π.regex /\x20+/ )
  .onMatch ( match ) -> [ 'lws', match[ 0 ], ]

#-----------------------------------------------------------------------------------------------------------
### invisible LWS ###
@ilws = π.drop π.regex /\x20+/

#-----------------------------------------------------------------------------------------------------------
@_operator_on_match  = ( match ) -> [ 'operator', match[ 0 ], ]
@_operation_on_match = ( match ) -> [ match[ 1 ][ 0 ], match[ 1 ][ 1 ], match[ 0 ], match[ 2 ], ]
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
@addition        = ( π.seq ( => @expression ), @ilws, @plus,  @ilws, ( => @expression ) )
  .onMatch @_operation_on_match

@multiplication  = ( π.seq ( => @expression ), @ilws, @times, @ilws, ( => @expression ) )
  .onMatch @_operation_on_match

@sum             = π.alt @addition, @some_digits
@product         = π.alt @multiplication, @some_digits
@expression      = ( π.alt @sum, @product )
  .onMatch ( match ) => [ 'expression', match, ]

info '\n' + rpr @expression.run '3 + 10 + 200'
info '\n' + rpr @expression.run '3 * 10 + 200'
info '\n' + rpr @expression.run '3 + 10 * 200'
info '\n' + rpr @expression.run '42'


# rv = π.consume expression, '3 + 10 * 200', debugGraph: true
# njs_fs.writeFileSync '/tmp/test.dot', rv.state.debugGraphToDot()


@list_kernel = ( π.repeatSeparated ( => @expression ), π [ ',', @ilws, ] )
  # .onMatch ( match ) -> [ 'long-sum', [ m for m in match when ( m[ 0 ] isnt 'operator' and m[ 1 ] isnt '+' ) ]..., ]
@empty_list  = ( π.seq '[', ( π.optional @ilws ), ']' )
  .onMatch ( match ) => [ 'list', ]
@filled_list = ( π.seq '[', @ilws, ( π.optional @list_kernel ), @ilws, ']' )
  .onMatch ( match ) => [ 'list', match[ 1 ]... ]
@list = π.alt @empty_list, @filled_list

info '\n' + rpr @list.run '[ 3, 10, 200 ]'
info '\n' + rpr @list.run '[]'

### TAINT does not respected escaped slashes, interpolations ###
@nws = ( π.regex /\S+/ )
  .onMatch ( match ) => [ 'nws', match[ 0 ], ]
@identifier = ( π.regex /^[^0-9][^\s:]*/ )
  .onMatch ( match ) => [ 'identifier', match[ 0 ].split '/', ]
@assignment = ( π [ @identifier, ':', @ilws, @expression, ] )
  .onMatch ( match ) => [ 'assignment', match[ 0 ], match[ 2 ], ]

info '\n' + rpr @assignment.run 'xy: 20 + 3'

### TAINT translation routines should be
(1) independent from grammar, so we can translate to different targets;
(2) be modular and extensible, so new forms of expression can implement both new syntax
    and ways of translation to different targets.
Point (2) is not possible with a `switch`-dispatcher.
###
#-----------------------------------------------------------------------------------------------------------
@as_coffeescript = ( node ) ->
  [ type, content... ] = node
  # debug type, content
  switch type
    #.......................................................................................................
    when 'assignment'
      unless content.length is 2
        throw new Error "expected identifier and expression node, got #{rpr content}"
      [ identifier_node, expression_node ] = content
      unless ( sub_type = identifier_node[ 0 ] ) is 'identifier'
        throw new Error "expected identifier node, got #{sub_type}"
      crumbs = identifier_node[ 1 ]
      ### TAINT must escape identifier ###
      ### TAINT shouldn't we also use variables in the target language? ###
      crumbs_txt = ( "[ '#{crumb}' ]" for crumb in crumbs ).join ''
      return "$v#{crumbs_txt} = #{@as_coffeescript expression_node}"
    #.......................................................................................................
    when 'expression'
      ### TAINT how to join? ###
      return ( @as_coffeescript sub_expression for sub_expression in content ).join ' '
    #.......................................................................................................
    when 'number'
      return content[ 0 ]
    #.......................................................................................................
    when 'operator'
      ### TAINT wrongly assumes binary operator ###
      ### TAINT wrongly assumes operator has direct equivalent in target language ###
      return "#{@as_coffeescript content[ 1 ]} #{content[ 0 ]} #{@as_coffeescript content[ 2 ]}"
    #.......................................................................................................
    when 'text'
      ### TAINT text literal should be kept intact ###
      return rpr content[ 1 ]
    #.......................................................................................................
    when 'symbol'
      ### TAINT text literal should be kept intact ###
      whisper content
      return rpr content[ 1 ]
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
node = @assignment.run 'xy: 20 + 3'
info @as_coffeescript node
node = @assignment.run 'foo/bar: 20 + 3'
info @as_coffeescript node
# node = @assignment.run 'foo/bar: gnu/cram'
# info @as_coffeescript node



#-----------------------------------------------------------------------------------------------------------
@single_quote     = π.string "'"
@double_quote     = π.string '"'
@nosq             = ( π.alt ( => @escaped ), /[^']+/ )
  .onMatch ( match ) -> match[ 0 ]
@nodq             = ( π.alt ( => @escaped ), /[^"]+/ )
  .onMatch ( match ) -> match[ 0 ]
@chr_escaper      = π.string '\\'
@unicode4_escape  = π.string 'u'
@_sq_text_literal = π.seq @single_quote, @nosq, @single_quote
@_dq_text_literal = π.seq @double_quote, @nodq, @double_quote
### TAINT maybe we should *not* un-escape anything; better for translation ###
@text_literal     = ( π.alt @_sq_text_literal, @_dq_text_literal )
  .onMatch ( match ) => [ 'text', match..., ]


#-----------------------------------------------------------------------------------------------------------
@simple_escape = ( π.regex /[bfnrt]/ )
  .onMatch ( match ) => @escape_table[ match[ 0 ] ]

#-----------------------------------------------------------------------------------------------------------
@escape_table =
  b: '\b'
  f: '\f'
  n: '\n'
  r: '\r'
  t: '\t'

#-----------------------------------------------------------------------------------------------------------
### TAINT String conversion method dubious; will fail outside of Unicode BMP ###
@unicode_hex      = ( π.seq @unicode4_escape, /[0-9a-fA-F]{4}/ )
  .onMatch ( match ) => String.fromCharCode '0x' + match[ 1 ]

#-----------------------------------------------------------------------------------------------------------
@escaped      = ( π.seq @chr_escaper, ( π.alt @simple_escape, @unicode_hex, /./ ) )
  .onMatch ( match ) => match[ 1 ]

@_symbol_sigil    = π.string ':'
@symbol           = ( π.seq @_symbol_sigil, @nws )
  .onMatch ( match ) => [ 'symbol', match[ 1 ][ 1 ] ]
@_use_keyword     = π.string 'use'
@use_argument     = π.alt @symbol, @some_digits, @text_literal
@use_statement    = π.seq @_use_keyword, @ilws, @use_argument

info rpr @single_quote.run  "'"
info rpr @double_quote.run  '"'
info rpr @chr_escaper.run   '\\'
info rpr @simple_escape.run 'n'
info rpr @unicode_hex.run   'u4e01'
info rpr @escaped.run       '\\u4e01'
info rpr @escaped.run       '\\n'
info rpr @nosq.run          'abcdef'
info rpr @nodq.run          'ioxuy'
info rpr @text_literal.run  '"helo"'
info rpr @text_literal.run  "'helo'"
info rpr @_dq_text_literal.run '"foo"'
info rpr @_sq_text_literal.run "'foo'"

info node = @use_statement.run 'use 123'
debug @as_coffeescript node
info node = @use_statement.run 'use :foo'
debug @as_coffeescript node
info node = @use_statement.run 'use "foo\nbar"'
debug @as_coffeescript node



