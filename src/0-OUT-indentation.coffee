
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾7-indentation﴿'
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
@$ =
  ### TAINT dot suspected to match incorrectly? ###
  ### TAINT assumes newlines are equal to `\n` ###
  'leading-ws':         XRE '(?:^|\\n)(\\p{Space_Separator}*)(.*)(?=\\n|$)'
  'opener':             '⟦'
  'connector':          '∿'
  'closer':             '⟧'

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
### TAINT no memoizing ###
@$_metachr = π.alt =>
  π.regex XRE '[' + ( XRE.$_esc @$[ 'opener' ] + @$[ 'connector' ] + @$[ 'closer' ] ) + ']'

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
### TAINT no memoizing ###
@$_nometachrs = π.alt =>
  π.regex XRE '[^' + ( XRE.$_esc @$[ 'opener' ] + @$[ 'connector' ] + @$[ 'closer' ] ) + ']*'

# #-----------------------------------------------------------------------------------------------------------
# @$_indentation = ( π.repeat XRE '.', 'Qs' )
#   .onMatch ( match ) -> match[ 0 ]

#-----------------------------------------------------------------------------------------------------------
### TAINT `π.alt` is an expedient here ###
@$_indentation =  ( π.repeat ' ' )
  .onMatch ( match ) ->
    # unless match.length / 2 == parseInt match.length / 2
    #   throw new Error "inconsistent indentation"
    return match.join ''

#-----------------------------------------------------------------------------------------------------------
### `/.* /` instead of `/.+/` makes the rule fail: ###
# @$_indented_line =  ( π.seq @$_indentation, /.*/, π.optional '\n' )
@$_raw_indented_material_line = ( π.seq @$_indentation, /.+/ , π.optional '\n' )
  .onMatch ( match ) -> return [ match[ 0 ], match[ 1 ][ 0 ], match[ 2 ] ]

#-----------------------------------------------------------------------------------------------------------
### TAINT simplified version of LWS ###
@$_raw_blank_line = ( π.regex /([\x20\t]+)(\n|$)/ )
  .onMatch ( match ) -> return [ '', match[ 1 ], match[ 2 ] ]

#-----------------------------------------------------------------------------------------------------------
### TAINT simplified version of LWS ###
@$_raw_line = π.alt @$_raw_blank_line, @$_raw_indented_material_line

#-----------------------------------------------------------------------------------------------------------
# @$_indented_lines = π.seq @$_indented_line, @$_indented_line
@$_raw_lines = π.repeat @$_raw_line #, 1
  # .onMatch ( match ) -> NEW.x_indentation match.length / 2

#-----------------------------------------------------------------------------------------------------------
# @$_line = π.seq @$_metachr, @$_raw_indented_material_line

#-----------------------------------------------------------------------------------------------------------
# @line = π.seq @$_metachr, @$_nometachrs, @$_metachr

#-----------------------------------------------------------------------------------------------------------
# @lines = π.repeat @line

#-----------------------------------------------------------------------------------------------------------
### TAINT must escape meta-chrs ###
### TAINT must delay to allow for late changes ###
@phrase = ( π.regex /// [^ #{@$[ 'opener' ]} #{@$[ 'connector' ]} #{@$[ 'closer' ]} ]+ /// )
  .onMatch ( match ) ->
    R = [ 'phrase', match[ 0 ] ]
    whisper R
    return R
  .describe "one or more non-meta characters"

#-----------------------------------------------------------------------------------------------------------
@phrases = ( π.repeatSeparated @phrase, /\|/ )
  .onMatch ( match ) ->
    # whisper match
    return [ 'phrases', match... ]

#-----------------------------------------------------------------------------------------------------------
@bracketed = ( π.seq '(', ( π.repeat => @expression ), ')' )
  .onMatch ( match ) ->
    R = [ 'bracketed', match[ 0 ], match[ 1 ], match[ 2 ], ]
    whisper R
    return R

#-----------------------------------------------------------------------------------------------------------
@expression = ( π.alt @bracketed, @phrases )


#-----------------------------------------------------------------------------------------------------------
# @suite = π.seq ( => @$[ 'opener' ] ), '\n',


# #===========================================================================================================
# # TESTS
# #-----------------------------------------------------------------------------------------------------------
# @$TESTS =

#   #---------------------------------------------------------------------------------------------------------
#   'expression: parses simple bracketed': ( test ) ->
#     source  = """(xxx)"""
#     source  = """(A(B)C)"""
#     source  = """(xxx(yyy(zzz))aaa)"""
#     source  = """(xxx|www|333(yyy(zzz))aaa)"""
#     # test.eq ( @expression.run probe ), ( NEW.literal 'digits', probe, probe )



############################################################################################################
@_ = ->
  d = @$[ 'leading-ws' ]
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
  f = ->
    for x in xs
      while x > 0
        x -= 1
        log x
        g x
    log 'ok'
    log 'over'
  """

  # debug @$_indented_lines.run source
  # debug rpr @$_indentation.run '    '
  debug rpr @$_raw_indented_material_line.run '  abc'
  debug rpr @$_raw_indented_material_line.run '  abc\n'
  lines = @$_raw_lines.run source
  debug lines

  ### TAINT we should probably wait with complaints about indentation until later when we can rule out the
  existance of special constructs such as triple-quoted string literals, comments and the like; also, `!use`
  statements may alter the semantics of indentations ###
  R = []
  chrs_per_level  = 2
  base_level      = -chrs_per_level
  current_level   = base_level
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
        current_level += chrs_per_level
        dents.push @$[ 'opener' ]
      R.push dents.join ''
    #.........................................................................................................
    else if current_level > level
      dents = []
      while current_level > level
        current_level -= chrs_per_level
        dents.push @$[ 'closer' ]
      R.push dents.join ''
    else
      R.push @$[ 'connector' ]
    R.push material
    # R.push '\n'
  #...........................................................................................................
  ### TAINT code repetition ###
  if current_level > base_level
    dents = []
    while current_level > base_level
      current_level -= chrs_per_level
      dents.push @$[ 'closer' ]
    R.push dents.join ''
  R = R.join ''
  ### TAINT must keep line numbers; also applies to indentations ###
  # if R[ 0 ] isnt '\n'
  debug '\n' + R
  # debug @line.run "⟦x -= 1∿"
  # debug @lines.run R




@_() unless module.parent?


