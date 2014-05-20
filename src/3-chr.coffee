
############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾3-chr﴿'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM
#...........................................................................................................
π                         = require 'coffeenode-packrattle'
BNP                       = require 'coffeenode-bitsnpieces'
NEW                       = require './NEW'
XRE                       = require './9-xre'


#-----------------------------------------------------------------------------------------------------------
@$_constants =
  'ascii-punctuation':  """-!"#%&'()*,./:;?@[\\]_{}"""
  ### Sigils may start and classify simple names: ###
  'sigils':
    # '@':        'attribute' # ??? used for `this`
    '.':        'hidden'
    '_':        'private'
    # '$':        'special' # used for interpolation!
    '%':        'cached'
    '!':        'attention'
    # '°':        ''
    # '^':        ''


#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
### TAINT no memoizing ###
@$_ascii_punctuation = π.alt =>
  π.regex XRE '[' + ( XRE.$esc @$_constants[ 'ascii-punctuation' ] ) + ']'

#-----------------------------------------------------------------------------------------------------------
@$_chr = ( π.regex XRE '.', 'Qs' )
  .onMatch ( match ) -> match[ 0 ]

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@chr =  ( π.alt @$_chr )
  .onMatch ( match ) -> NEW.literal 'chr', match, match


#===========================================================================================================
# WHITESPACE
#-----------------------------------------------------------------------------------------------------------
### Linear WhiteSpace ###
@lws = ( π.regex /\x20+/ )
  .onMatch ( match ) -> return NEW.literal 'lws', match[ 0 ], match[ 0 ]

#-----------------------------------------------------------------------------------------------------------
### invisible LWS ###
@ilws = π.drop π.regex /\x20+/

#-----------------------------------------------------------------------------------------------------------
### no WhiteSpace ###
@$nws = ( π.regex /[^\s\x85]+/ )
### TAINT better way to chain methods? ###
@nws = @$nws.onMatch ( match ) => NEW.literal 'nws', match[ 0 ], match[ 0 ]
@nws = @nws.describe "no-whitespace"

#-----------------------------------------------------------------------------------------------------------
### Unicode line endings: ###
@$nl_re = /// \r\n | [\n\v\f\r\x85\u2028\u2029] ///g
@$nl    = π.regex @$nl_re


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  '$chr: matches code points (instead of code units) and newlines': ( test ) ->
    test.eq ( @$_chr.run 'x' ), 'x'
    test.eq ( @$_chr.run '\r' ), '\r'
    test.eq ( @$_chr.run '\n' ), '\n'
    test.eq ( @$_chr.run '𠀝' ), '𠀝'

  #---------------------------------------------------------------------------------------------------------
  'chr: matches code points (instead of code units) and newlines': ( test ) ->
    test.eq ( @chr.run 'x'  ), NEW.literal 'chr', 'x', 'x'
    test.eq ( @chr.run '\r' ), NEW.literal 'chr', '\r', '\r'
    test.eq ( @chr.run '\n' ), NEW.literal 'chr', '\n', '\n'
    test.eq ( @chr.run '𠀝'  ), NEW.literal 'chr', '𠀝', '𠀝'

  #---------------------------------------------------------------------------------------------------------
  '$chr: accepts single character, be it one or two code units': ( test ) ->
    probes_and_results = [
      [ '0',                  '0' ]
      [ 'q',                  'q' ]
      [ '中',     　           '中' ]
      [ '𠀝',     　           '𠀝' ]
      ]
    for [ probe, result, ] in probes_and_results
      test.eq ( @$_chr.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$chr: rejects more than a single character': ( test ) ->
    probes = [ '01', 'qwertz', '中中', '𠀝x', ]
    for probe in probes
      test.throws ( => @$_chr.run probe ), /Expected end/

  #---------------------------------------------------------------------------------------------------------
  '$ascii_punctuation: rejects anything but ASCII punctuation': ( test ) ->
    probes = [ 'a', '', '中', '𠀁', ]
    for probe in probes
      # try
      #   debug rpr probe
      #   @$_ascii_punctuation.run probe
      # catch error
      #   debug error[ 'message' ]
      test.throws ( => @$_ascii_punctuation.run probe ), /Expected /


  #=========================================================================================================
  # WHITESPACE
  #---------------------------------------------------------------------------------------------------------
  'nws: rejects sequences defined as whitespace in Unicode 6.2': ( test ) ->
    errors  = []
    probes  = [
      '\u0009', '\u000A', '\u000B', '\u000C', '\u000D', '\u0020', '\u0085', '\u00A0', '\u1680', '\u2000',
      '\u2001', '\u2002', '\u2003', '\u2004', '\u2005', '\u2006', '\u2007', '\u2008', '\u2009', '\u200A',
      '\u2028', '\u2029', '\u202F', '\u205F', '\u3000', ]
    #.......................................................................................................
    for probe in probes
      try
        @nws.run probe
      catch error
        throw error unless error[ 'message' ] is 'Expected no-whitespace'
        continue
      errors.push probe
    #.......................................................................................................
    if errors.length isnt 0
      errors_txt = ( rpr text for text in errors ).join ', '
      throw new Error "wrongly recognized as non-whitespace: #{errors_txt}"

  #---------------------------------------------------------------------------------------------------------
  'nws: accepts sequences of non-whitespace characters': ( test ) ->
    probes = [
      "aeiou"
      "123/)zRT§"
      "中國皇帝🚂" ]
    #.......................................................................................................
    for probe in probes
      test.eq ( @nws.run probe ), ( NEW.literal 'nws', probe, probe )

  #---------------------------------------------------------------------------------------------------------
  'lws: accepts sequences of U+0020': ( test ) ->
    probes = [ ' ', '        ', ]
    for probe in probes
      test.eq ( @lws.run probe ), ( NEW.literal 'lws', probe, probe )

  #---------------------------------------------------------------------------------------------------------
  'ilws: accepts and drops sequences of U+0020': ( test ) ->
    probes = [ ' ', '        ', ]
    for probe in probes
      test.eq ( @ilws.run probe ), null

  #---------------------------------------------------------------------------------------------------------
  '$nl_re: splits string with Unicode line endings correctly': ( test ) ->
    test.eq ( '1\r\n2\n3\v4\f5\r6\x857\u20288\u20299'.split @$nl_re ), [ '1', '2', '3', '4', '5', '6', '7', '8', '9' ]

  #---------------------------------------------------------------------------------------------------------
  '$nl_re: allows global replace': ( test ) ->
    test.eq ( '1\r\n2\n3\v4\f5\r6\x857\u20288\u20299'.replace @$nl_re, '#' ), '1#2#3#4#5#6#7#8#9'

