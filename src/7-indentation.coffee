
###

Parses nested structures.
* **meta-characters** (opener, connector, closer);
* **material characters** are code points that are not meta-characters;
* **phrase**: a contiguous sequence of material characters;
* **suite**: a contiguous sequence of phrases;
* **stage**: suites with a common parent; may include nested stages
* **module**: the outermost stage of a given source.

# * **chunk**
# * **block**



###



############################################################################################################
TYPES                     = require 'coffeenode-types'
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
# BNP                       = require 'coffeenode-bitsnpieces'
$new                      = require './NEW'
CHR                       = require './3-chr'
XRE                       = require './9-xre'







#-----------------------------------------------------------------------------------------------------------
@$ =
  ### When `true`, suites are single strings that represent lines separated by `connector`; when `false`,
  suites are lists with lines as elements: ###
  # 'join-suites':        yes
  'join-suites':        no

  #.........................................................................................................
  'opener':             '【'
  'connector':          '〓'
  'closer':             '】'

  ### other popular choices include:

  #.........................................................................................................
  'opener':             '↳'
  'connector':          '↦'
  'closer':             '↱'
  #.........................................................................................................
  'opener':             '⇩'
  'connector':          '⇨'
  'closer':             '⇧'
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
  R = π.alt -> ( π.seq G.$_indentation, CHR.$nws, /.*/ , π.optional '\n' )
  R = R.onMatch ( match ) ->
    [ indentation, first_chr, rest, nl, ] = match
    material                              = first_chr[ 0 ] + rest[ 0 ]
    return [ indentation, material, nl, ]
  return R

#-----------------------------------------------------------------------------------------------------------
### TAINT must parameterize ###
### TAINT naive whitespace definition; use CHR ###
@$new.$_raw_blank_line = ( G, $ ) ->
  R = ( π.regex /([\x20\t]+)(\n|$)/ )
  R = R.onMatch ( match ) -> return [ '', match[ 1 ], match[ 2 ] ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$_raw_line = ( G, $ ) ->
  return ( π.alt ( -> G.$_raw_blank_line ), ( -> G.$_raw_indented_material_line ) )

#-----------------------------------------------------------------------------------------------------------
@$new.$_raw_lines = ( G, $ ) ->
  return π.repeat -> G.$_raw_line

# #-----------------------------------------------------------------------------------------------------------
# ### used to issue warning in case metachrs appear in source ###
# @$new.$_metachrs = ( G, $ ) ->
#   ### TAINT code duplication: same escaped metachrs used in `$phrase` ###
#   metachrs  = XRE.$esc $[ 'opener' ] + $[ 'connector' ] + $[ 'closer' ]
#   R = π.alt ( π.seq /[\s\S]*/, /// [ #{metachrs} ] ///, /[\s\S]*/ ), /[\s\S]*/
#   R = R.onMatch ( match, state ) ->
#     debug match
#     return match
#   return R

#-----------------------------------------------------------------------------------------------------------
### TAINT must escape occurrences of meta-chrs in source ####
### TAINT should use parser state to indicate error locations ####
@$new.$_as_bracketed = ( G, $ ) ->
  R = ( source ) ->
    source              = source.replace CHR.$nl_re, '\n'
    source             += '\n' unless source[ source.length - 1 ] is '\n'
    lines               = G.$_raw_lines.run source
    RR                  = []
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
      #.....................................................................................................
      unless raw_level is Math.floor raw_level
        # warn level, current_raw_level
        throw new Error """
          inconsistent indentation (no multiple of #{chrs_per_level} characters) on line ##{line_idx + 1}:
          #{rpr line}"""
      #.....................................................................................................
      if raw_level > current_raw_level + max_indent_chrs
        # warn raw_level, current_raw_level
        throw new Error """
          inconsistent indentation (too deep) on line ##{line_idx + 1}:
          #{rpr line}"""
      #.....................................................................................................
      if raw_level > current_raw_level
        dents = []
        while raw_level > current_raw_level
          current_raw_level += chrs_per_level
          dents.push $[ 'opener' ]
        RR.push dents.join ''
      #.....................................................................................................
      else if current_raw_level > raw_level
        dents = []
        while current_raw_level > raw_level
          current_raw_level -= chrs_per_level
          dents.push $[ 'closer' ]
        RR.push dents.join ''
      else
        RR.push $[ 'connector' ]
      RR.push material
      # RR.push '\n'
    #.......................................................................................................
    ### TAINT code repetition ###
    if current_raw_level > base_raw_level
      dents = []
      while current_raw_level > base_raw_level
        current_raw_level -= chrs_per_level
        dents.push $[ 'closer' ]
      RR.push dents.join ''
    RR = RR.join ''
    return RR
  #.........................................................................................................
  return R


#===========================================================================================================
# PARSING BRACKETED INTERMEDIATE REPRESENTATION
#-----------------------------------------------------------------------------------------------------------
@$new.$suite = ( G, $ ) ->
  # metachrs  = XRE.$esc $[ 'opener' ] + $[ 'connector' ] + $[ 'closer' ]
  metachrs  = XRE.$esc $[ 'opener' ] + $[ 'closer' ]
  R         = π.repeatSeparated /// [^ #{metachrs} ]+ ///, $[ 'connector' ]
  R         = R.onMatch ( match ) -> match.join $[ 'connector' ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$stage = ( G, $ ) ->
  R = π.seq $[ 'opener' ], ( -> G.$chunks ), $[ 'closer' ]
  R = R.onMatch ( match ) -> match[ 1 ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$chunk = ( G, $ ) ->
  R = π.alt ( -> G.$suite ), ( -> G.$stage )
  # R = R.onMatch ( match ) -> [ 'chunk', match..., ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$chunks = ( G, $ ) ->
  R = π.repeat ( -> G.$chunk ), 1
  #.........................................................................................................
  R = R.onMatch ( match ) ->
    return match if $[ 'join-suites' ]
    RR = []
    for element in match
      if TYPES.isa_text element
        RR.splice RR.length, 0, ( element.split $[ 'connector' ] )...
      else
        RR.push element
    return RR
  #.........................................................................................................
  return R


#===========================================================================================================
# PARSING INDENTED SOURCE
#-----------------------------------------------------------------------------------------------------------
@$new.$module = ( G, $ ) ->
  ### Same as `$chunk`, but accepts indented source. ###
  R = π.seq ( -> G.$chunk ), π.end
  R = R.transform ( text ) -> G.$_as_bracketed text
  R = R.onMatch ( match ) -> match[ 0 ]
  return R


#===========================================================================================================
# APPLY NEW TO MODULE
#-----------------------------------------------------------------------------------------------------------
### Run `@$new` to make `@` (`this`) an instance of this grammar with default options: ###
@$new @, null


#===========================================================================================================
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  '$suite: parses phrases joined by connector (1)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': no
    source  = 'abc=def=ghi'
    # debug G.$suite.run source
    test.eq ( G.$suite.run source ), 'abc=def=ghi'

  #---------------------------------------------------------------------------------------------------------
  '$suite: parses phrases joined by connector (2)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': yes
    source  = 'abc=def=ghi'
    # debug G.$suite.run source
    test.eq ( G.$suite.run source ), 'abc=def=ghi'

  #---------------------------------------------------------------------------------------------------------
  '$chunk: parses simple bracketed expression (1)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': no
    source  = '<abc=def=ghi>'
    # debug G.$chunk.run source
    test.eq ( G.$chunk.run source ), [ 'abc', 'def', 'ghi', ]

  #---------------------------------------------------------------------------------------------------------
  '$chunk: parses simple bracketed expression (2)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': yes
    source  = '<abc=def=ghi>'
    # debug G.$chunk.run source
    test.eq ( G.$chunk.run source ), [ 'abc=def=ghi', ]

  #---------------------------------------------------------------------------------------------------------
  '$chunk: parses nested bracketed expression (1)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': no
    source  = '<abc=def<ghi<jkl=mno>>pqr>'
    # debug G.$chunk.run source
    test.eq ( G.$chunk.run source ), [ 'abc', 'def', [ 'ghi', [ 'jkl', 'mno', ] ], 'pqr', ]

  #---------------------------------------------------------------------------------------------------------
  '$chunk: parses nested bracketed expression (2)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': yes
    source  = '<abc=def<ghi<jkl=mno>>pqr>'
    # debug G.$chunk.run source
    test.eq ( G.$chunk.run source ), [ 'abc=def', [ 'ghi', [ 'jkl=mno', ] ], 'pqr', ]

  #---------------------------------------------------------------------------------------------------------
  '$module: parses indented source (1)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': no
    source  = """
    abc
    def
      ghi
        jkl
        mno
    pqr
    """
    # debug G.$module.run source
    test.eq ( G.$module.run source ), [ 'abc', 'def', [ 'ghi', [ 'jkl', 'mno', ] ], 'pqr', ]

  #---------------------------------------------------------------------------------------------------------
  '$module: parses indented source (2)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': yes
    source  = """
    abc
    def
      ghi
        jkl
        mno
    pqr
    """
    # debug G.$module.run source
    test.eq ( G.$module.run source ), [ 'abc=def', [ 'ghi', [ 'jkl=mno', ] ], 'pqr', ]


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
    result    = result.replace /⟦/g, $[ 'opener' ]
    result    = result.replace /⟧/g, $[ 'closer' ]
    result    = result.replace /∿/g, $[ 'connector' ]
    # debug bracketed
    test.eq bracketed, result

  #---------------------------------------------------------------------------------------------------------
  '$_as_bracketed (default G): disallow unconventional indentation': ( test ) ->
    G       = @
    source  = """
    f = ->
        for x in xs
      while x > 0
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
    result    = result.replace /⟦/g, $[ 'opener' ]
    result    = result.replace /⟧/g, $[ 'closer' ]
    result    = result.replace /∿/g, $[ 'connector' ]
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
    # test.throws ( -> G.$_as_bracketed source ), /Expected no-whitespace/
    test.throws ( -> G.$_as_bracketed source ), /Expected end/

  # #---------------------------------------------------------------------------------------------------------
  # 'expression (default G): parses one-liner program': ( test ) ->
  #   G       = @
  #   source  = "xxx"
  #   node    = G.expression.run source
  #   debug test.as_js node

  # #---------------------------------------------------------------------------------------------------------
  # 'expression (default G): parses program (1)': ( test ) ->
  #   G       = @
  #   source  = """
  #   if x > 0
  #     log 'ok'
  #   """
  #   node = G.expression.run source
  #   debug test.as_js node

  # # #---------------------------------------------------------------------------------------------------------
  # # 'expression (default G): parses program (2)': ( test ) ->
  # #   G       = @
  # #   source  = """
  # #   f = ->
  # #     for x in xs
  # #       while x > 0
  # #         x -= 1
  # #         log x
  # #         g x
  # #     log 'ok'
  # #     log 'over'
  # #   """
  # #   node = debug G.expression.run source
  # #   debug test.as_js node

