


###

Potentially useful character classes:

* from within 7bit US ASCII:
  * any letter;
  * any digit;
  * any punctuation;
  * any single whitespace character;
  * any single linear whitespace character;
  * any single non-whitespace / printing character;
  * space (i.e. U+0020);

* from within 21bit (a.k.a. 32bit) Unicode (v6.3):
  * any single character, be it ASCII, from the Astral Planes, whitespace, newline, whatever;
  * any single non-whitespace / printing character;
  * any digit;
  * any letter;
  * any character except ASCII punctuation;
  * any newline character (zero or more characters that are line endings, including implied EOF);
  * more?

###

############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾8-character﴿'
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
XRE                       = require './9-xre'

#-----------------------------------------------------------------------------------------------------------
@$_constants =
  'ascii-punctuation':  """-!"#%&'()*,./:;?@[\\]_{}"""


#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
### TAINT no memoizing ###
@$_ascii_punctuation = π.alt =>
  π.regex XRE '[' + ( XRE.$_esc @$_constants[ 'ascii-punctuation' ] ) + ']'

#-----------------------------------------------------------------------------------------------------------
@$_chr = ( π.regex XRE '.', 'Qs' )
  .onMatch ( match ) -> match[ 0 ]

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@chr =  ( π.alt @$_chr )
  .onMatch ( match ) -> NEW.literal 'chr', match, match


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@TESTS =

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



# matcher = XRE '\\pP'
# for cid in [ 0 .. 127 ]
#   chr = String.fromCharCode cid
#   info rpr chr if matcher.test chr



# d = XRE '[' + ( BNP.escape_regex @$_constants[ 'ascii-punctuation' ] ) + ']'
# debug 'a'.match d
# debug '.'.match d





