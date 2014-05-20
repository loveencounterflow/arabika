
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
π                         = require 'coffeenode-packrattle'
BNP                       = require 'coffeenode-bitsnpieces'
NEW                       = require './NEW'
CHR                       = require './3-chr'
XRE                       = require './9-xre'

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
### TAINT `π.alt` is an expedient here ###
@$_sq = π.alt => π.string @$_constants[ 'single-quote' ]

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@$_dq = π.alt => π.string @$_constants[ 'double-quote' ]

#-----------------------------------------------------------------------------------------------------------
### TAINT escapes on each call; no memoizing ###
@$_nosq = ( π.repeat => π.alt @$_escaped, /// [^ #{BNP.escape_regex @$_constants[ 'single-quote' ]} ] /// )
  .onMatch ( match ) -> ( submatch[ 0 ] for submatch in match ).join ''

#-----------------------------------------------------------------------------------------------------------
### TAINT escapes on each call; no memoizing ###
@$_nodq = ( π.repeat => π.alt @$_escaped, /// [^ #{BNP.escape_regex @$_constants[ 'double-quote' ]} ] /// )
  .onMatch ( match ) -> ( submatch[ 0 ] for submatch in match ).join ''

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@$_chr_escaper = π.alt => π.string @$_constants[ 'chr-escaper' ]

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@$_unicode4_metachr = π.alt => π.string @$_constants[ 'unicode4-metachr' ]

#-----------------------------------------------------------------------------------------------------------
@$_sq_literal = π.seq @$_sq, @$_nosq, @$_sq

#-----------------------------------------------------------------------------------------------------------
@$_dq_literal = π.seq @$_dq, @$_nodq, @$_dq

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@$_simple_escape = ( π.alt => π.regex /[bfnrt]/ )
  .onMatch ( match ) => @$_constants[ 'escape-table' ][ match[ 0 ] ]

#-----------------------------------------------------------------------------------------------------------
### TAINT String conversion method dubious; will fail outside of Unicode BMP ###
@$_unicode_hex = ( π.seq @$_unicode4_metachr, /[0-9a-fA-F]{4}/ )
  .onMatch ( match ) => String.fromCharCode '0x' + match[ 1 ]

#-----------------------------------------------------------------------------------------------------------
@$_escaped = ( π.seq @$_chr_escaper, ( π.alt @$_simple_escape, @$_unicode_hex, @_chr ) )
  .onMatch ( match ) => match[ 1 ]

#-----------------------------------------------------------------------------------------------------------
### TAINT maybe we should *not* un-escape anything; better for translation ###
@literal          = ( π.alt @$_sq_literal, @$_dq_literal )
  .onMatch ( match ) =>
    [ ignore, value, ignore, ] = match
    return NEW.literal 'text', ( match.join '' ), value


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
    probes_and_results = [
      [ 'b',                  '\b' ]
      [ 'f',                  '\f' ]
      [ 'n',                  '\n' ]
      [ 'r',                  '\r' ]
      [ 't',                  '\t' ] ]
    for [ probe, result, ] in probes_and_results
      test.eq ( @$_simple_escape.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$escaped: accepts escaped chracters': ( test ) ->
    escaper = @$_constants[ 'chr-escaper' ]
    probes_and_results = [
      [ '+u4e01',              '丁' ]
      [ "#{escaper}b",         '\b' ]
      [ "#{escaper}f",         '\f' ]
      [ "#{escaper}n",         '\n' ]
      [ "#{escaper}r",         '\r' ]
      [ "#{escaper}t",         '\t' ] ]
    for [ probe, result, ] in probes_and_results
      test.eq ( @$_escaped.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$nosq: accepts runs of chracters except unescaped single quote': ( test ) ->
    escaper = @$_constants[ 'chr-escaper' ]
    probes_and_results = [
      [ '0',                  '0' ]
      [ 'qwertz',             'qwertz' ]
      # [ "qw+'ertz",          "qw'ertz" ]
      [ "#{escaper}t",        "\t" ]
      [ "qw#{escaper}nertz",  "qw\nertz" ]
      [ '中華人"民共和國"',    　'中華人"民共和國"' ] ]
    for [ probe, result, ] in probes_and_results
      # debug @$_nosq.run probe
      test.eq ( @$_nosq.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$nodq: accepts runs of chracters except unescaped double quote': ( test ) ->
    probes_and_results = [
      [ '0',                  '0' ]
      [ 'qwertz',             'qwertz' ]
      [ "中華人'民共和國'",     　"中華人'民共和國'" ] ]
    for [ probe, result, ] in probes_and_results
      test.eq ( @$_nodq.run probe ), result


