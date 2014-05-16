


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
  ### TAINT dot suspected to match incorrectly? ###
  ### TAINT assumes newlines are equal to `\n` ###
  'leading-ws':          XRE '(?:^|\\n)(\\p{Space_Separator}*)(.*)(?=\\n|$)'
  'opener':              '﴾'
  'closer':              '﴿'

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
### TAINT no memoizing ###
@$_ascii_punctuation = π.alt =>
  π.regex XRE '[' + ( XRE.$_esc @$_constants[ 'ascii-punctuation' ] ) + ']'

#-----------------------------------------------------------------------------------------------------------
@$_indentation = ( π.repeat XRE '.', 'Qs' )
  .onMatch ( match ) -> match[ 0 ]

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@$_indentation =  ( π.repeat ' ' )
  .onMatch ( match ) ->
    # unless match.length / 2 == parseInt match.length / 2
    #   throw new Error "inconsistent indentation"
    return match.join ''

#-----------------------------------------------------------------------------------------------------------
# /.*/ makes the rule fail:
# @$_indented_line =  ( π.seq @$_indentation, /.*/, π.optional '\n' )
@$_indented_material_line = ( π.seq @$_indentation, /.+/ , π.optional '\n' )
  .onMatch ( match ) -> return [ match[ 0 ], match[ 1 ][ 0 ], match[ 2 ] ]

#-----------------------------------------------------------------------------------------------------------
### TAINT simplified version of LWS ###
@$_blank_line = ( π.regex /([\x20\t]+)(\n|$)/ )
  .onMatch ( match ) -> return [ '', match[ 1 ], match[ 2 ] ]

#-----------------------------------------------------------------------------------------------------------
### TAINT simplified version of LWS ###
@$_line = π.alt @$_blank_line, @$_indented_material_line

#-----------------------------------------------------------------------------------------------------------
# @$_indented_lines = π.seq @$_indented_line, @$_indented_line
@$_lines = π.repeat @$_line #, 1
  # .onMatch ( match ) -> NEW.x_indentation match.length / 2


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@TESTS =

  #---------------------------------------------------------------------------------------------------------
  '$...': ( test ) ->
    test.fail "no tests"
  #   test.eq ( @$_chr.run 'x' ), 'x'
  #   test.eq ( @$_chr.run '\r' ), '\r'
  #   test.eq ( @$_chr.run '\n' ), '\n'
  #   test.eq ( @$_chr.run '𠀝' ), '𠀝'

  # #---------------------------------------------------------------------------------------------------------
  # 'chr: matches code points (instead of code units) and newlines': ( test ) ->
  #   test.eq ( @chr.run 'x'  ), NEW.literal 'chr', 'x', 'x'
  #   test.eq ( @chr.run '\r' ), NEW.literal 'chr', '\r', '\r'
  #   test.eq ( @chr.run '\n' ), NEW.literal 'chr', '\n', '\n'
  #   test.eq ( @chr.run '𠀝'  ), NEW.literal 'chr', '𠀝', '𠀝'

  # #---------------------------------------------------------------------------------------------------------
  # '$chr: accepts single character, be it one or two code units': ( test ) ->
  #   probes_and_results = [
  #     [ '0',                  '0' ]
  #     [ 'q',                  'q' ]
  #     [ '中',     　           '中' ]
  #     [ '𠀝',     　           '𠀝' ]
  #     ]
  #   for [ probe, result, ] in probes_and_results
  #     test.eq ( @$_chr.run probe ), result

  # #---------------------------------------------------------------------------------------------------------
  # '$chr: rejects more than a single character': ( test ) ->
  #   probes = [ '01', 'qwertz', '中中', '𠀝x', ]
  #   for probe in probes
  #     test.throws ( => @$_chr.run probe ), /Expected end/

  # #---------------------------------------------------------------------------------------------------------
  # '$ascii_punctuation: rejects anything but ASCII punctuation': ( test ) ->
  #   probes = [ 'a', '', '中', '𠀁', ]
  #   for probe in probes
  #     # try
  #     #   debug rpr probe
  #     #   @$_ascii_punctuation.run probe
  #     # catch error
  #     #   debug error[ 'message' ]
  #     test.throws ( => @$_ascii_punctuation.run probe ), /Expected /



d = @$_constants[ 'leading-ws' ]
debug ''.match d
debug ' '.match d
debug '  '.match d
debug '\n  '.match d
debug 'abc'.match d
debug '\n    abc'.match d

debug()
debug rpr ''.split d
debug rpr ' '.split d
debug rpr '  '.split d
debug rpr '\n  '.split d
debug rpr 'abc'.split d

source = """
    abc
  abc
def
  ghi
  jkl
    mno
  pqr
xyz
"""
# debug @$_indented_lines.run source
# debug rpr @$_indentation.run '    '
debug rpr @$_indented_material_line.run '  abc'
debug rpr @$_indented_material_line.run '  abc\n'
lines = @$_lines.run source
debug lines

### TAINT we should probably wait with complaints about indentation until later when we can rule out the
existance of special constructs such as triple-quoted string literals, comments and the like; also, `!use`
statements may alter the semantics of indentations ###
R = []
current_level = -1
for line, line_idx in lines
  [ indentation, material, ending, ] = line
  level = indentation.length # / 2
  # #.........................................................................................................
  # unless level is parseInt level
  #   warn level, current_level
  #   throw new Error "inconsistent indentation (not an even number of spaces) on line ##{line_idx + 1}:\n#{rpr line}"
  # #.........................................................................................................
  # if current_level is null
  #   unless level is 0
  #     warn level, current_level
  #     throw new Error "inconsistent indentation (starts with indentation) on line ##{line_idx + 1}:\n#{rpr line}"
  # #.........................................................................................................
  # if level > current_level + 1
  #   warn level, current_level
  #   throw new Error "inconsistent indentation (too deep) on line ##{line_idx + 1}:\n#{rpr line}"
  #.........................................................................................................
  if level > current_level
    dents = []
    while level > current_level
      current_level += 1
      dents.push @$_constants[ 'opener' ]
    R.push dents.join ''
  #.........................................................................................................
  else if current_level > level
    dents = []
    while current_level > level
      current_level -= 1
      dents.push @$_constants[ 'closer' ]
    R.push dents.join ''
  R.push '.' + material
#...........................................................................................................
### TAINT code repetition ###
if current_level > -1
  dents = []
  while current_level > -1
    current_level -= 1
    dents.push @$_constants[ 'closer' ]
  R.push dents.join ''

whisper R
info '\n' + R.join '\n'


