
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


#===========================================================================================================
# OPTIONS
#-----------------------------------------------------------------------------------------------------------
@options =
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


#===========================================================================================================
# CONSTRUCTOR
#-----------------------------------------------------------------------------------------------------------
@constructor = ( G, $ ) ->

  #=========================================================================================================
  # RULES
  #---------------------------------------------------------------------------------------------------------
  ### TAINT describe ###
  G.$_sq = ->
    return ƒ.or -> ƒ.string $[ 'single-quote' ]

  #---------------------------------------------------------------------------------------------------------
  ### TAINT `ƒ.or` is an expedient here ###
  G.$_dq = ->
    return ƒ.or -> ƒ.string $[ 'double-quote' ]

  #---------------------------------------------------------------------------------------------------------
  ### TAINT escapes on each call; no memoizing ###
  G.$_nosq = ->
    return ( ƒ.repeat -> ƒ.or ( -> G.$_escaped ), /// [^ #{BNP.escape_regex $[ 'single-quote' ]} ] /// )
    .onMatch ( match ) -> ( submatch[ 0 ] for submatch in match ).join ''

  #---------------------------------------------------------------------------------------------------------
  ### TAINT escapes on each call; no memoizing ###
  G.$_nodq = ->
    return ( ƒ.repeat -> ƒ.or ( -> G.$_escaped ), /// [^ #{BNP.escape_regex $[ 'double-quote' ]} ] /// )
    .onMatch ( match ) -> ( submatch[ 0 ] for submatch in match ).join ''

  #---------------------------------------------------------------------------------------------------------
  ### TAINT `ƒ.or` is an expedient here ###
  G.$_chr_escaper = ->
    return ƒ.or -> ƒ.string $[ 'chr-escaper' ]

  #---------------------------------------------------------------------------------------------------------
  ### TAINT `ƒ.or` is an expedient here ###
  G.$_unicode4_metachr = ->
    return ƒ.or -> ƒ.string $[ 'unicode4-metachr' ]

  #---------------------------------------------------------------------------------------------------------
  G.$_sq_literal = ->
    return ƒ.seq G.$_sq, G.$_nosq, G.$_sq

  #---------------------------------------------------------------------------------------------------------
  G.$_dq_literal = ->
    return ƒ.seq G.$_dq, G.$_nodq, G.$_dq

  #---------------------------------------------------------------------------------------------------------
  ### TAINT `ƒ.or` is an expedient here ###
  G.$_simple_escape = ->
    return ( ƒ.or -> ƒ.regex /[bfnrt]/ )
    .onMatch ( match ) -> $[ 'escape-table' ][ match[ 0 ] ]

  #---------------------------------------------------------------------------------------------------------
  ### TAINT String conversion method dubious; will fail outside of Unicode BMP ###
  ### TAINT use new ES6 String API for codepoints ###
  G.$_unicode_hex = ->
    return ( ƒ.seq ( -> G.$_unicode4_metachr ), /[0-9a-fA-F]{4}/ )
    .onMatch ( match ) -> String.fromCharCode '0x' + match[ 1 ][ 0 ]

  #---------------------------------------------------------------------------------------------------------
  G.$_escaped = ->
    return ( ƒ.seq ( -> G.$_chr_escaper ), ( ƒ.or ( -> G.$_simple_escape ), ( -> G.$_unicode_hex ), ( -> CHR.$chr ) ) )
    .onMatch ( match ) -> match[ 1 ]

  #---------------------------------------------------------------------------------------------------------
  ### TAINT maybe we should *not* un-escape anything; better for translation ###
  G.literal = ->
    return ( ƒ.or ( -> G.$_sq_literal ), ( -> G.$_dq_literal ) )
    .onMatch ( match, state ) ->
      [ ignore, value, ignore, ] = match
      return G.nodes.literal state, value

  #---------------------------------------------------------------------------------------------------------
  G.literal.as =
    coffee: ( node ) ->
      { value }   = node
      return target: rpr value

  #---------------------------------------------------------------------------------------------------------
  G.nodes.literal = ( state, value ) ->
      return ƒ.new._XXX_YYY_node G.literal.as, state, 'TEXT/literal',
        'value':    value


  #=========================================================================================================
  # TESTS
  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'quotes are single characters' ] = ( test ) ->
    TYPES = require 'coffeenode-types'
    test.ok TYPES.isa_text $[ 'single-quote' ]
    test.ok TYPES.isa_text $[ 'double-quote' ]
    test.ok $[ 'single-quote' ].length is 1
    test.ok $[ 'double-quote' ].length is 1

  #---------------------------------------------------------------------------------------------------------
  G.tests[ '$simple_escape: accepts and translates meta-chracters' ] = ( test ) ->
    probes_and_matchers = [
      [ 'b',                  '\b' ]
      [ 'f',                  '\f' ]
      [ 'n',                  '\n' ]
      [ 'r',                  '\r' ]
      [ 't',                  '\t' ] ]
    for [ probe, result, ] in probes_and_matchers
      test.eq ( G.$_simple_escape.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  G.tests[ '$escaped: accepts escaped chracters' ] = ( test ) ->
    escaper = $[ 'chr-escaper' ]
    probes_and_matchers = [
      [ "#{escaper}u4e01",     '丁' ]
      [ "#{escaper}b",         '\b' ]
      [ "#{escaper}f",         '\f' ]
      [ "#{escaper}n",         '\n' ]
      [ "#{escaper}r",         '\r' ]
      [ "#{escaper}t",         '\t' ] ]
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.$_escaped.run probe
      # debug ( rpr probe ), ( rpr matcher ), ( rpr result )
      test.eq ( G.$_escaped.run probe ), matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ '$nosq: accepts runs of chracters except unescaped single quote' ] = ( test ) ->
    escaper = $[ 'chr-escaper' ]
    probes_and_matchers = [
      [ '0',                  '0' ]
      [ 'qwertz',             'qwertz' ]
      # [ "qw+'ertz",          "qw'ertz" ]
      [ "#{escaper}t",        "\t" ]
      [ "qw#{escaper}nertz",  "qw\nertz" ]
      [ '中華人"民共和國"',    　'中華人"民共和國"' ] ]
    for [ probe, result, ] in probes_and_matchers
      # debug G.$_nosq.run probe
      test.eq ( G.$_nosq.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  G.tests[ '$nodq: accepts runs of chracters except unescaped double quote' ] = ( test ) ->
    probes_and_matchers = [
      [ '0',                  '0' ]
      [ 'qwertz',             'qwertz' ]
      [ "中華人'民共和國'",     　"中華人'民共和國'" ] ]
    for [ probe, result, ] in probes_and_matchers
      test.eq ( G.$_nodq.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  G.tests[ '$literal: accepts single and double quoted string literals' ] = ( test ) ->
    probes_and_matchers = [
      [ '"0"',           {"type":"TEXT/literal","value":"0"}, ]
      [ '"qwertz"',      {"type":"TEXT/literal","value":"qwertz"}, ]
      [ "'中華人民共和國'",     {"type":"TEXT/literal","value":"中華人民共和國"}, ]
      ]
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.literal.run probe
      # debug JSON.stringify result
      test.eq result, matcher


  #---------------------------------------------------------------------------------------------------------
  # G.tests[ 'as.coffee: render assignment as CoffeeScript' ] = ( test ) ->
  G.tests[ 'as.coffee: render text literal as CoffeeScript' ] = ( test ) ->
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


############################################################################################################
ƒ.new.consolidate @



