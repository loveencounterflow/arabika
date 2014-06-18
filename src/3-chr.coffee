
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
ƒ                         = require 'flowmatic'
@$new                     = ƒ.new.new @
BNP                       = require 'coffeenode-bitsnpieces'
XRE                       = require './9-xre'

#-----------------------------------------------------------------------------------------------------------
@$ =
  ### ASCII Punctuation: ###
  'ascii-punctuation':  /// [ - _ ! " \# % & ' ( \[ { \\ } \] ) * , . / : ; ? @ ] ///
  #.........................................................................................................
  ### Whitespace: ###
  ### Unicode line endings (RegEx should have the global flag set): ###
  'newlines':           /// \r\n | [\n\v\f\r\x85\u2028\u2029] ///g
  ### Unicode linear whitespace: ###
  'linear-whitespace':  XRE '\\L+'
  ### Anything but whitespace: ###
  'no-whitespace':      /// [^ \s \x85 ]+ ///


#-----------------------------------------------------------------------------------------------------------
@$new.$ascii_punctuation = ( G, $ ) ->
  R = ƒ.regex $[ 'ascii-punctuation' ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$chr = ( G, $ ) ->
  R = ƒ.regex XRE '.', 'Qs'
  R = R.onMatch ( match ) -> match[ 0 ]
  return R

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$new.chr = ( G, $ ) ->
  R = ƒ.or -> G.$chr
  R = R.onMatch ( match ) -> ƒ.new.literal 'chr', match, match
  return R

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$new.$letter = ( G, $ ) ->
  R = ƒ.regex XRE '\\p{L}', 'A'
  R = R.onMatch ( match ) -> match[ 0 ]
  R = R.describe 'CHR/$letter'
  return R


#===========================================================================================================
# WHITESPACE
#-----------------------------------------------------------------------------------------------------------
@$new.$lws = ( G, $ ) ->
  ### Linear WhiteSpace ###
  R = ƒ.regex $[ 'linear-whitespace' ]
  R = R.onMatch ( match ) -> match[ 0 ]
  R = R.describe 'linear whitespace'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.lws = ( G, $ ) ->
  ### Linear WhiteSpace ###
  R = G.$lws.onMatch ( match ) -> ƒ.new.literal 'lws', match, match
  R = R.describe 'linear whitespace'
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.ilws = ( G, $ ) ->
  ### invisible LWS ###
  R = ƒ.drop ƒ.regex $[ 'linear-whitespace' ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$nws = ( G, $ ) ->
  ### no WhiteSpace ###
  R = ƒ.regex $[ 'no-whitespace' ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.nws = ( G, $ ) ->
  R = ƒ.or -> G.$nws.onMatch ( match ) -> ƒ.new.literal 'nws', match[ 0 ], match[ 0 ]
  R = R.describe "no-whitespace"
  return R

#-----------------------------------------------------------------------------------------------------------
# ### TAINT `ƒ.or` is an expedient here ###
@$new.$nl = ( G, $ ) ->
  R = ƒ.regex $[ 'newlines' ]
  return R


#===========================================================================================================
# APPLY NEW TO MODULE
#-----------------------------------------------------------------------------------------------------------
### Run `@$new` to make `@` (`this`) an instance of this grammar with default options: ###
@$new @, null


#===========================================================================================================
@$TESTS =
#-----------------------------------------------------------------------------------------------------------

  #---------------------------------------------------------------------------------------------------------
  '$chr: matches code points (instead of code units) and newlines': ( test ) ->
    test.eq ( @$chr.run 'x' ), 'x'
    test.eq ( @$chr.run '\r' ), '\r'
    test.eq ( @$chr.run '\n' ), '\n'
    test.eq ( @$chr.run '𠀝' ), '𠀝'

  #---------------------------------------------------------------------------------------------------------
  'chr: matches code points (instead of code units) and newlines': ( test ) ->
    test.eq ( @chr.run 'x'  ), ƒ.new.literal 'chr', 'x', 'x'
    test.eq ( @chr.run '\r' ), ƒ.new.literal 'chr', '\r', '\r'
    test.eq ( @chr.run '\n' ), ƒ.new.literal 'chr', '\n', '\n'
    test.eq ( @chr.run '𠀝'  ), ƒ.new.literal 'chr', '𠀝', '𠀝'

  #---------------------------------------------------------------------------------------------------------
  '$chr: accepts single character, be it one or two code units': ( test ) ->
    probes_and_results = [
      [ '0',                  '0' ]
      [ 'q',                  'q' ]
      [ '中',     　           '中' ]
      [ '𠀝',     　           '𠀝' ]
      ]
    for [ probe, result, ] in probes_and_results
      test.eq ( @$chr.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$chr: rejects more than a single character': ( test ) ->
    probes = [ '01', 'qwertz', '中中', '𠀝x', ]
    for probe in probes
      test.throws ( => @$chr.run probe ), /Expected end/

  #---------------------------------------------------------------------------------------------------------
  '$ascii_punctuation: rejects anything but ASCII punctuation': ( test ) ->
    probes = [ 'a', '', '中', '𠀁', ]
    for probe in probes
      # try
      #   debug rpr probe
      #   @$ascii_punctuation.run probe
      # catch error
      #   debug error[ 'message' ]
      test.throws ( => @$ascii_punctuation.run probe ), /Expected /


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
      test.eq ( @nws.run probe ), ( ƒ.new.literal 'nws', probe, probe )

  #---------------------------------------------------------------------------------------------------------
  'lws: accepts sequences of U+0020': ( test ) ->
    probes = [ ' ', '        ', ]
    for probe in probes
      test.eq ( @lws.run probe ), ( ƒ.new.literal 'lws', probe, probe )

  #---------------------------------------------------------------------------------------------------------
  'ilws: accepts and drops sequences of U+0020': ( test ) ->
    probes = [ ' ', '        ', ]
    for probe in probes
      test.eq ( @ilws.run probe ), null

  #---------------------------------------------------------------------------------------------------------
  "G$[ 'newlines' ]: splits string with Unicode line endings correctly": ( test ) ->
    G = @
    test.eq ( '1\r\n2\n3\v4\f5\r6\x857\u20288\u20299'.split @$[ 'newlines' ] ), \
      [ '1', '2', '3', '4', '5', '6', '7', '8', '9' ]

  #---------------------------------------------------------------------------------------------------------
  "G$[ 'newlines' ]: allows global replace": ( test ) ->
    test.eq ( '1\r\n2\n3\v4\f5\r6\x857\u20288\u20299'.replace @$[ 'newlines' ], '#' ), '1#2#3#4#5#6#7#8#9'

  #---------------------------------------------------------------------------------------------------------
  '$letter: matches single letters, including 32bit code points': ( test ) ->
    probes_and_results = [
      [ 'q',                  'q' ]
      [ '中',     　           '中' ]
      [ '𠀝',     　           '𠀝' ]
      ]
    for [ probe, result, ] in probes_and_results
      # whisper probe
      test.eq ( @$letter.run probe ), result

  #---------------------------------------------------------------------------------------------------------
  '$letter: rejects anything but single letters': ( test ) ->
    probes = [ '0', '-', '(', '؟', 'xx' ]
    for probe in probes
      # whisper probe
      test.throws ( => @$letter.run probe ), /Expected/

