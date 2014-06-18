
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾2-text﴿'
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
BNP                       = require 'coffeenode-bitsnpieces'
ƒ                         = require 'flowmatic'
$new                      = ƒ.new
CHR                       = require './3-chr'
XRE                       = require './XRE'

#-----------------------------------------------------------------------------------------------------------
@$_constants =
  'single-quote':     "'"
  'double-quote':     '"'
  # 'chr-escaper':      '\\'
  'chr-escaper':      '+'
  'unicode4-metachr': 'u'
  'escape-table':
    b: '\b'
    f: '\f'
    n: '\n'
    r: '\r'
    t: '\t'


#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
### TAINT describe ###
@$_sq = ƒ.or => ƒ.string @$_constants[ 'single-quote' ]

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$_dq = ƒ.or => ƒ.string @$_constants[ 'double-quote' ]

#-----------------------------------------------------------------------------------------------------------
### TAINT escapes on each call; no memoizing ###
@$_nosq = ( ƒ.repeat => ƒ.or ( => @$_escaped ), /// [^ #{BNP.escape_regex @$_constants[ 'single-quote' ]} ] /// )
  .onMatch ( match ) => ( submatch[ 0 ] for submatch in match ).join ''

#-----------------------------------------------------------------------------------------------------------
### TAINT escapes on each call; no memoizing ###
@$_nodq = ( ƒ.repeat => ƒ.or ( => @$_escaped ), /// [^ #{BNP.escape_regex @$_constants[ 'double-quote' ]} ] /// )
  .onMatch ( match ) => ( submatch[ 0 ] for submatch in match ).join ''

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$_chr_escaper = ƒ.or => ƒ.string @$_constants[ 'chr-escaper' ]

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$_unicode4_metachr = ƒ.or => ƒ.string @$_constants[ 'unicode4-metachr' ]

#-----------------------------------------------------------------------------------------------------------
@$_sq_literal = ƒ.seq @$_sq, @$_nosq, @$_sq

#-----------------------------------------------------------------------------------------------------------
@$_dq_literal = ƒ.seq @$_dq, @$_nodq, @$_dq

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$_simple_escape = ( ƒ.or => ƒ.regex /[bfnrt]/ )
  .onMatch ( match ) => @$_constants[ 'escape-table' ][ match[ 0 ] ]

#-----------------------------------------------------------------------------------------------------------
### TAINT String conversion method dubious; will fail outside of Unicode BMP ###
### TAINT use new ES6 String API for codepoints ###
@$_unicode_hex = ( ƒ.seq ( => @$_unicode4_metachr ), /[0-9a-fA-F]{4}/ )
  .onMatch ( match ) => String.fromCharCode '0x' + match[ 1 ][ 0 ]

#-----------------------------------------------------------------------------------------------------------
@$_escaped = ( ƒ.seq ( => @$_chr_escaper ), ( ƒ.or ( => @$_simple_escape ), ( => @$_unicode_hex ), ( => CHR.$chr ) ) )
  .onMatch ( match ) => match[ 1 ]

#-----------------------------------------------------------------------------------------------------------
### TAINT maybe we should *not* un-escape anything; better for translation ###
@literal = ( ƒ.or ( => @$_sq_literal ), ( => @$_dq_literal ) )
@literal = @literal.onMatch ( match, state ) =>
  [ ignore, value, ignore, ] = match
  return @nodes.literal state, value

#-----------------------------------------------------------------------------------------------------------
@literal.as =
  coffee: ( node ) ->
    { value }   = node
    return target: rpr value

#-----------------------------------------------------------------------------------------------------------
G = @
@nodes = {}
@nodes.literal = ( state, value ) ->
    return ƒ.new._XXX_YYY_node G.literal.as, state, 'TEXT/literal',
      'value':    value


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  'quotes are single characters': ( test ) ->
    TYPES = require 'coffeenode-types'
    test.ok TYPES.isa_text @$_constants[ 'single-quote' ]
    test.ok TYPES.isa_text @$_constants[ 'double-quote' ]
    test.ok @$_constants[ 'single-quote' ].length is 1
    test.ok @$_constants[ 'double-quote' ].length is 1

  #---------------------------------------------------------------------------------------------------------
  '$simple_escape: accepts and translates meta-chracters': ( test ) ->
    probes_and_matchers = [
      [ 'b',                  '\b' ]
      [ 'f',                  '\f' ]
      [ 'n',                  '\n' ]
      [ 'r',                  '\r' ]
      [ 't',                  '\t' ] ]
    for [ probe, result, ] in probes_and_matchers
      test.eq ( @$_simple_escape.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$escaped: accepts escaped chracters': ( test ) ->
    escaper = @$_constants[ 'chr-escaper' ]
    probes_and_matchers = [
      [ "#{escaper}u4e01",     '丁' ]
      [ "#{escaper}b",         '\b' ]
      [ "#{escaper}f",         '\f' ]
      [ "#{escaper}n",         '\n' ]
      [ "#{escaper}r",         '\r' ]
      [ "#{escaper}t",         '\t' ] ]
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references @$_escaped.run probe
      # debug ( rpr probe ), ( rpr matcher ), ( rpr result )
      test.eq ( @$_escaped.run probe ), matcher

  #---------------------------------------------------------------------------------------------------------
  '$nosq: accepts runs of chracters except unescaped single quote': ( test ) ->
    escaper = @$_constants[ 'chr-escaper' ]
    probes_and_matchers = [
      [ '0',                  '0' ]
      [ 'qwertz',             'qwertz' ]
      # [ "qw+'ertz",          "qw'ertz" ]
      [ "#{escaper}t",        "\t" ]
      [ "qw#{escaper}nertz",  "qw\nertz" ]
      [ '中華人"民共和國"',    　'中華人"民共和國"' ] ]
    for [ probe, result, ] in probes_and_matchers
      # debug @$_nosq.run probe
      test.eq ( @$_nosq.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$nodq: accepts runs of chracters except unescaped double quote': ( test ) ->
    probes_and_matchers = [
      [ '0',                  '0' ]
      [ 'qwertz',             'qwertz' ]
      [ "中華人'民共和國'",     　"中華人'民共和國'" ] ]
    for [ probe, result, ] in probes_and_matchers
      test.eq ( @$_nodq.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$literal: accepts single and double quoted string literals': ( test ) ->
    probes_and_matchers = [
      [ '"0"',           {"type":"TEXT/literal","value":"0"}, ]
      [ '"qwertz"',      {"type":"TEXT/literal","value":"qwertz"}, ]
      [ "'中華人民共和國'",     {"type":"TEXT/literal","value":"中華人民共和國"}, ]
      ]
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references @literal.run probe
      # debug JSON.stringify result
      test.eq result, matcher


  #---------------------------------------------------------------------------------------------------------
  # G.tests[ 'as.coffee: render assignment as CoffeeScript' ] = ( test ) ->
  'as.coffee: render text literal as CoffeeScript': ( test ) ->
    G       = @
    probes_and_matchers  = [
      [ '"0"',           "'0'", ]
      [ '"qwertz"',      "'qwertz'", ]
      [ "'中華人民共和國'",     "'中華人民共和國'", ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      node        = G.literal.run probe
      # debug JSON.stringify ƒ.new._delete_grammar_references G.literal.run probe
      translation = G.literal.as.coffee node
      result      = ƒ.as.coffee.target translation
      # debug JSON.stringify result
      # debug JSON.stringify result
      # debug '\n' + result
      test.eq result, matcher




