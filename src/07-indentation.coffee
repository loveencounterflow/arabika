
###




###



############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾0-bracketed-expressions﴿'
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
# BNP                       = require 'coffeenode-bitsnpieces'
$new                      = require './NEW'
XRE                       = require './9-xre'







#-----------------------------------------------------------------------------------------------------------
@$ =
  #.........................................................................................................
  'opener':             '⇩'
  'connector':          '⇨'
  'closer':             '⇧'

  #.........................................................................................................
  'opener':             '↳'
  'connector':          '↦'
  'closer':             '↱'
  ### other popular choices include:

  #.........................................................................................................
  'opener':             '↧'
  'connector':          '↦'
  'closer':             '↥'
  #.........................................................................................................
  'opener':             '￬'
  'connector':          '￫'
  'closer':             '￪'
  #.........................................................................................................
  'opener':             '⟦'
  'connector':          '∿'
  'closer':             '⟧'

  ###

  #.........................................................................................................
  'indentation-chr':    ' '
  'chrs-per-level':     2
  ### Maximum number of steps that positive indents may progress;
  set to 1 to allow standard single-step indentation (as in Python and CoffeeScript),
  set to e.g. 2 to allow 'unconventional' single and double-step indentation,
  set to Infinity to allow unlimited indentation deltas,
  set to 0 to disallow indentation altogether: ###
  'delta':              1

#-----------------------------------------------------------------------------------------------------------
@$new = $new.new @


#===========================================================================================================
# TURNING INDENTED INTO BRACKETED INTERMEDIATE REPRESENTATION
#-----------------------------------------------------------------------------------------------------------
### TAINT must parameterize ###
@$new.$_indentation = ( G, $ ) ->
  R = π.alt -> ( π.repeat ' ' )
  R = R.onMatch ( match ) -> return match.join ''
  return R

#-----------------------------------------------------------------------------------------------------------
### TAINT naive line ending ###
@$new.$_raw_indented_material_line = ( G, $ ) ->
  R = π.alt -> ( π.seq G.$_indentation, /.+/ , π.optional '\n' )
  R = R.onMatch ( match ) -> return [ match[ 0 ], match[ 1 ][ 0 ], match[ 2 ] ]
  return R

#-----------------------------------------------------------------------------------------------------------
### TAINT must parameterize ###
@$new.$_raw_blank_line = ( G, $ ) ->
  R = ( π.regex /([\x20\t]+)(\n|$)/ )
  R = R.onMatch ( match ) -> return [ '', match[ 1 ], match[ 2 ] ]

#-----------------------------------------------------------------------------------------------------------
@$new.$_raw_line = ( G, $ ) ->
  return π.alt ( -> G.$_raw_blank_line ), ( -> G.$_raw_indented_material_line )

#-----------------------------------------------------------------------------------------------------------
@$new.$_raw_lines = ( G, $ ) ->
  return π.repeat -> G.$_raw_line

#-----------------------------------------------------------------------------------------------------------
### TAINT must escape occurrences of meta-chrs in source ####
### TAINT should use parser state to indicate error locations ####
@$new.$_as_bracketed = ( G, $ ) ->
  R = ( source ) ->
    lines               = G.$_raw_lines.run source
    R                   = []
    chrs_per_level      = $[ 'chrs-per-level' ]
    delta               = $[ 'delta' ]
    max_indent_chrs     = delta * chrs_per_level
    base_raw_level      = -chrs_per_level
    current_raw_level   = base_raw_level
    #.......................................................................................................
    for line, line_idx in lines
      [ indentation, material, ending, ] = line
      raw_level = indentation.length
      level     = raw_level / chrs_per_level
      #.........................................................................................................
      unless raw_level is Math.floor raw_level
        # warn level, current_raw_level
        throw new Error """
          inconsistent indentation (no multiple of #{chrs_per_level} characters) on line ##{line_idx + 1}:
          #{rpr line}"""
      #.........................................................................................................
      if raw_level > current_raw_level + max_indent_chrs
        # warn raw_level, current_raw_level
        throw new Error """
          inconsistent indentation (too deep) on line ##{line_idx + 1}:
          #{rpr line}"""
      #.........................................................................................................
      if raw_level > current_raw_level
        dents = []
        while raw_level > current_raw_level
          current_raw_level += chrs_per_level
          dents.push $[ 'opener' ]
        R.push dents.join ''
      #.........................................................................................................
      else if current_raw_level > raw_level
        dents = []
        while current_raw_level > raw_level
          current_raw_level -= chrs_per_level
          dents.push $[ 'closer' ]
        R.push dents.join ''
      else
        R.push $[ 'connector' ]
      R.push material
      # R.push '\n'
    #...........................................................................................................
    ### TAINT code repetition ###
    if current_raw_level > base_raw_level
      dents = []
      while current_raw_level > base_raw_level
        current_raw_level -= chrs_per_level
        dents.push $[ 'closer' ]
      R.push dents.join ''
    R = R.join ''
  #.........................................................................................................
  return R


#===========================================================================================================
# PARSING BRACKETED INTERMEDIATE REPRESENTATION
#-----------------------------------------------------------------------------------------------------------
@$new.$bracketed = ( G, $ ) ->
  R = π.alt -> π.seq $[ 'opener' ], ( π.repeat => G.$suite ), $[ 'closer' ]
  R = R.onMatch ( match ) -> [ 'bracketed', match[ 0 ], match[ 1 ], match[ 2 ], ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$phrases = ( G, $ ) ->
  R = π.alt -> π.repeatSeparated G.$phrase, /// #{XRE.$esc $[ 'connector' ]} ///
  R = R.onMatch ( match ) -> [ 'phrases', match... ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$phrase = ( G, $ ) ->
  metachrs  = XRE.$esc $[ 'opener' ] + $[ 'connector' ] + $[ 'closer' ]
  R         = π.alt -> π.regex /// [^ #{metachrs} ]+ ///
  R         = R.onMatch ( match ) -> [ 'phrase', match[ 0 ] ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$suite = ( G, $ ) ->
  return π.alt -> π.alt G.$bracketed, G.$phrases


#===========================================================================================================
# APPLY NEW TO MODULE
#-----------------------------------------------------------------------------------------------------------
### Run `@$new` to make `@` (`this`) an instance of this grammar with default options: ###
@$new @, null


#===========================================================================================================
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  'bracketed: parses simple bracketed phrase': ( test ) ->
    G       = @$new opener: '(', connector: '|', closer: ')'
    source  = """(xxx)"""
    test.eq ( G.$bracketed.run source ), ["bracketed","(",[["phrases",["phrase","xxx"]]],")"]

  #---------------------------------------------------------------------------------------------------------
  'bracketed: parses nested bracketed phrase': ( test ) ->
    G       = @$new opener: '(', connector: '|', closer: ')'
    source  = """(A(B)C)"""
    test.eq ( G.$bracketed.run source ), ["bracketed","(",[["phrases",["phrase","A"]],["bracketed","(",[["phrases",["phrase","B"]]],")"],["phrases",["phrase","C"]]],")"]

  #---------------------------------------------------------------------------------------------------------
  'bracketed: parses multiply nested bracketed phrase': ( test ) ->
    G       = @$new opener: '(', connector: '|', closer: ')'
    source  = """(xxx(yyy(zzz))aaa)"""
    test.eq ( G.$bracketed.run source ), ["bracketed","(",[["phrases",["phrase","xxx"]],["bracketed","(",[["phrases",["phrase","yyy"]],["bracketed","(",[["phrases",["phrase","zzz"]]],")"]],")"],["phrases",["phrase","aaa"]]],")"]

  #---------------------------------------------------------------------------------------------------------
  'bracketed: parses multiply nested bracketed phrase with connectors': ( test ) ->
    G       = @$new opener: '(', connector: '|', closer: ')'
    source  = """(xxx|www|333(yyy(zzz))aaa)"""
    test.eq ( G.$bracketed.run source ), ["bracketed","(",[["phrases",["phrase","xxx"],["phrase","www"],["phrase","333"]],["bracketed","(",[["phrases",["phrase","yyy"]],["bracketed","(",[["phrases",["phrase","zzz"]]],")"]],")"],["phrases",["phrase","aaa"]]],")"]

  #---------------------------------------------------------------------------------------------------------
  'expression: parses simple bracketed phrase': ( test ) ->
    G       = @$new opener: '(', connector: '|', closer: ')'
    source  = """(xxx)"""
    test.eq ( G.$suite.run source ), ["bracketed","(",[["phrases",["phrase","xxx"]]],")"]

  #---------------------------------------------------------------------------------------------------------
  'expression: parses nested bracketed phrase': ( test ) ->
    G       = @$new opener: '(', connector: '|', closer: ')'
    source  = """(A(B)C)"""
    test.eq ( G.$suite.run source ), ["bracketed","(",[["phrases",["phrase","A"]],["bracketed","(",[["phrases",["phrase","B"]]],")"],["phrases",["phrase","C"]]],")"]

  #---------------------------------------------------------------------------------------------------------
  'expression: parses multiply nested bracketed phrase': ( test ) ->
    G       = @$new opener: '(', connector: '|', closer: ')'
    source  = """(xxx(yyy(zzz))aaa)"""
    test.eq ( G.$suite.run source ), ["bracketed","(",[["phrases",["phrase","xxx"]],["bracketed","(",[["phrases",["phrase","yyy"]],["bracketed","(",[["phrases",["phrase","zzz"]]],")"]],")"],["phrases",["phrase","aaa"]]],")"]

  #---------------------------------------------------------------------------------------------------------
  'expression: parses multiply nested bracketed phrase with connectors': ( test ) ->
    G       = @$new opener: '(', connector: '|', closer: ')'
    source  = """(xxx|www|333(yyy(zzz))aaa)"""
    test.eq ( G.$suite.run source ), ["bracketed","(",[["phrases",["phrase","xxx"],["phrase","www"],["phrase","333"]],["bracketed","(",[["phrases",["phrase","yyy"]],["bracketed","(",[["phrases",["phrase","zzz"]]],")"]],")"],["phrases",["phrase","aaa"]]],")"]

  #---------------------------------------------------------------------------------------------------------
  '$_raw_lines: turns indented source into list of triplets': ( test ) ->
    G       = @
    source  = """
    f = ->
      for x in xs
        while x > 0
          x -= 1
          log x
          g x
      log 'ok'
      log 'over'
    """
    lines = G.$_raw_lines.run source
    # debug JSON.stringify lines
    test.eq lines, [["","f = ->","\n"],["  ","for x in xs","\n"],["    ","while x > 0","\n"],["      ","x -= 1","\n"],["      ","log x","\n"],["      ","g x","\n"],["  ","log 'ok'","\n"],["  ","log 'over'",""]]

  #---------------------------------------------------------------------------------------------------------
  '$_as_bracketed: turns indented source into bracketed string': ( test ) ->
    G       = @
    $       = G[ '$' ]
    source  = """
    f = ->
      for x in xs
        while x > 0
          x -= 1
          log x
          g x
      log 'ok'
      log 'over'
    """
    # source = """
    # if x > 0
    #   x += 1
    #   print x
    # """
    bracketed = G.$_as_bracketed source
    result    = "⟦f = ->⟦for x in xs⟦while x > 0⟦x -= 1∿log x∿g x⟧⟧log 'ok'∿log 'over'⟧⟧"
    result    = result.replace /⟦/, $[ 'opener' ]
    result    = result.replace /⟧/, $[ 'closer' ]
    result    = result.replace /∿/, $[ 'connector' ]
    debug bracketed
    test.eq bracketed, result

  #---------------------------------------------------------------------------------------------------------
  '$_as_bracketed (default G): disallow unconventional indentation': ( test ) ->
    G       = @
    source  = """
    f = ->
        for x in xs
      while x > 0
        x -= 1
        log x
        g x
      log 'ok'
      log 'over'
    """
    test.throws ( -> G.$_as_bracketed source ), /inconsistent indentation \(too deep\) on line/

  #---------------------------------------------------------------------------------------------------------
  '$_as_bracketed (custom G): allow unconventional indentation': ( test ) ->
    options =
      'delta':  Infinity
    #.......................................................................................................
    G       = @$new options
    $       = G[ '$' ]
    #.......................................................................................................
    source  = """
    f = ->
        for x in xs
      while x > 0
        x -= 1
        log x
        g x
      log 'ok'
      log 'over'
    """
    #.......................................................................................................
    bracketed = G.$_as_bracketed source
    result    = "⟦f = ->⟦⟦for x in xs⟧while x > 0⟦x -= 1∿log x∿g x⟧log 'ok'∿log 'over'⟧⟧"
    result    = result.replace /⟦/, $[ 'opener' ]
    result    = result.replace /⟧/, $[ 'closer' ]
    result    = result.replace /∿/, $[ 'connector' ]
    test.eq bracketed, result

  #---------------------------------------------------------------------------------------------------------
  '$_as_bracketed (default G): disallow forbidden indentation-like chrs': ( test ) ->
    G       = @
    source  = """
    f = ->
      for x in xs
        \twhile x > 0
          x -= 1
          log x
          g x
      log 'ok'
      log 'over'
    """
    # debug JSON.stringify bracketed
    test.throws ( -> G.$_as_bracketed source ), /XXXXXXXXXXXXX/

  #---------------------------------------------------------------------------------------------------------
  '$_as_bracketed: normalize line endings': ( test ) ->
    throw new Error "not implemented"

  #---------------------------------------------------------------------------------------------------------
  '$_as_bracketed: warn where meta-chrs in raw source': ( test ) ->
    throw new Error "not implemented"




