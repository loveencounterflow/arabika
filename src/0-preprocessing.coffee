
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾0-preprocessing﴿'
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
XRE                       = require './XRE'
TEXT                      = require 'coffeenode-text'
STEP                      = require 'coffeenode-step'


#===========================================================================================================
# OPTIONS
#-----------------------------------------------------------------------------------------------------------
@options =
  CHR:            require './3-CHR'

#===========================================================================================================
# CONSTRUCTOR
#-----------------------------------------------------------------------------------------------------------
@constructor = ( G, $ ) ->

  #---------------------------------------------------------------------------------------------------------
  G.helpers.new_event = ( type, position, content, has_newline ) ->
    R =
      'type':           type
      'position':       position
      'content':        content
      'has-newline':    has_newline
      'level-delta':    null
      'level':          null
    return R

  #---------------------------------------------------------------------------------------------------------
  G.helpers._normalize_newlines = ( source ) ->
    ### Make sure that source
    * contains only `\n` linebreaks
    * ends with a single `\n`
    ###
    source = source.replace $.CHR.$[ 'newlines' ], '\n'
    source = source.replace /\n*$/, '\n'
    return source

  #---------------------------------------------------------------------------------------------------------
  G.helpers._lines_of = ( source ) ->
    ### Make sure that source contains only `\n` linebreaks; then, split source into lines. ###
    source    = source.replace $.CHR.$[ 'newlines' ], '\n'
    source    = source.replace /\s*$/, ''
    R         = source.split /\n/
    # R[ idx ]  = '\n' + R[ idx ] for line, idx in R
    return R

  #---------------------------------------------------------------------------------------------------------
  G.helpers._parts_of = ( source ) ->
    # source = G.helpers._normalize_newlines source
    ### TAINT does not honor escaped quotes ###
    R = source.split /// ( \#\#\# | \# | """ | ''' | " | ' ) ///
    ### Remove empty strings: ###
    for idx in [ R.length - 1 .. 0 ] by -1
      R.splice idx, 1 if R[ idx ] is ''
    return R

  #---------------------------------------------------------------------------------------------------------
  G.helpers.step_chunkify_events = ( source, handler ) ->
    type      = 'other'
    # last_type = type
    lines     = G.helpers._lines_of source
    #.......................................................................................................
    for line, line_idx in lines
      type          = 'other' if type is 'eol-comment'
      parts         = G.helpers._parts_of line
      last_part_idx = parts.length - 1
      #.....................................................................................................
      for part, part_idx in parts
        #.....................................................................................................
        switch part
          #.................................................................................................
          when '###'                                                                        # block-comment
            if type is 'block-comment'  then type = 'other'
            else if type is 'other'     then type = 'block-comment'
          #.................................................................................................
          when '#'                                                                          # comment
            if type is 'other'          then type = 'eol-comment'
          #.................................................................................................
          when '"""'                                                                        # triple-dq
            if type is 'triple-dq'      then type = 'other'
            else if type is 'other'     then type = 'triple-dq'
          #.................................................................................................
          when "'''"                                                                        # triple-sq
            if type is 'triple-sq'      then type = 'other'
            else if type is 'other'     then type = 'triple-sq'
          #.................................................................................................
          when '"'                                                                          # single-dq
            if type is 'single-dq'      then type = 'other'
            else if type is 'other'     then type = 'single-dq'
          #.................................................................................................
          when "'"                                                                          # single-sq
            if type is 'single-sq'      then type = 'other'
            else if type is 'other'     then type = 'single-sq'
        #...................................................................................................
        handler null, type, part, part_idx is last_part_idx
    #.......................................................................................................
    handler null, null, null, null, null
    return null

  #---------------------------------------------------------------------------------------------------------
  G.helpers.step_events = ( source, handler ) ->
    stepper   = STEP.call_back G.helpers.step_chunkify_events, source
    is_fenced =
      'block-comment':  1
      'triple-dq':      1
      'triple-sq':      1
      'single-dq':      1
      'single-sq':      1
    #-------------------------------------------------------------------------------------------------------
    STEP.triplets stepper, ( error, last_value, this_value, next_value ) ->
      return handler error if error?
      return handler null, null if last_value is null
      #.....................................................................................................
      this_position                             = 'middle'
      [ last_type                             ] = last_value
      [ this_type, this_content, this_has_nl  ] = this_value
      [ next_type                             ] = next_value
      #.....................................................................................................
      ### Correct early ending of fenced constructs such as `'quoted strings'`: ###
      if is_fenced[ last_type ]
        if this_type isnt last_type
          this_position = 'stop'
          this_type     = last_type
      else if is_fenced[ this_type ]
        if this_type isnt last_type
          this_position = 'start'
        else
          this_position = 'middle'
      else
        this_position = 'other'
      #.....................................................................................................
      # info ( TRM.grey TEXT.flush_right last_type,        12 ),
      #   TRM.grey TEXT.flush_right this_type,        12
      #   TRM.grey TEXT.flush_left this_position,    8
      #   TRM.lime TEXT.flush_left  ( rpr this_content ), 12
      #   TRM.gold if this_has_nl then '+' else ' '
      #   TRM.grey next_type
      handler null, G.helpers.new_event this_type, this_position, this_content, this_has_nl
    #-------------------------------------------------------------------------------------------------------
    return null

  #---------------------------------------------------------------------------------------------------------
  G.helpers.step_events_with_levels = ( source, handler ) ->
    level         = 0
    last_level    = level
    ### TAINT simplified and non-parametrized implementation of indentation ###
    has_newline   = yes
    had_newline   = had_newline
    dent          = ' '
    dent_length   = dent.length
    dent_matcher  = /// ^ (?: #{XRE.$esc dent} )* ///
    #-------------------------------------------------------------------------------------------------------
    adjust_level = ( event, content ) ->
      ### TAINT must complain when extra whitespace found ###
      content                 = event[ 'content' ]
      indentation             = ( content.match dent_matcher )[ 0 ]
      level                   = indentation.length / dent_length / 2
      #.....................................................................................................
      unless level is Math.floor level
        return handler new Error "illegal indentation on line #xxx: #{rpr content}"
      #.....................................................................................................
      content                 = content.replace indentation, ''
      event[ 'content' ]      = content
      set_level event
    #-------------------------------------------------------------------------------------------------------
    set_level = ( event ) ->
      event[ 'level'        ] = level
      event[ 'level-delta'  ] = level - last_level
      last_level              = level
      had_newline             = has_newline
      return null
    #-------------------------------------------------------------------------------------------------------
    G.helpers.step_events source, ( error, event ) ->
      throw error if error?
      return handler null, null if event is null
      { type, position, content, 'has-newline': has_newline } = event
      #.....................................................................................................
      if ( not had_newline ) or type isnt 'other'
        set_level event
        return handler null, event
      #.....................................................................................................
      adjust_level event if had_newline
      handler null, event
    #-------------------------------------------------------------------------------------------------------
    return null

  #---------------------------------------------------------------------------------------------------------
  G.helpers.as_bracketed = ( source ) ->
    ### TAINT must parametrize these ###
    opener        = '('
    # connector     = ';'
    closer        = ')'
    R             = []
    #-------------------------------------------------------------------------------------------------------
    G.helpers.step_events_with_levels source, ( error, event ) ->
      throw error if error?
      return R if event is null
      #.....................................................................................................
      { type, content, 'level-delta': level_delta, 'has-newline': has_newline } = event
      #.....................................................................................................
      if level_delta > 0
        R.push opener for idx in [ 0 ... level_delta ]
        R.push content
      #.....................................................................................................
      else if level_delta < 0
        R.push content
        R.push closer for idx in [ level_delta ... 0 ]
      #.....................................................................................................
      else
        R.push content
      #.....................................................................................................
      if has_newline
        # R.push if type is 'other' then connector else '\n'
        R.push '\n'
    #-------------------------------------------------------------------------------------------------------
    return R.join ''


  #=========================================================================================================
  # RULES
  #---------------------------------------------------------------------------------------------------------

  #=========================================================================================================
  # TESTS
  #---------------------------------------------------------------------------------------------------------
  G.tests._sources = [
    #.......................................................................................................
    # 0
    """#!/whatever
    something # a comment # with hashes
    # another comment
    something else
    d:
      a: \"""helo
        world\"""# 123
      b:
        ba: 65
        bb: 66
        bc: 67

    loop
      x: _ + 1
      break
    ### a longer comment
      taking up 2 lines ###
    log "message" + 'foo'
    """,
    #.......................................................................................................
    # 1
    """
    d:
      a: \"""helo # ###
        world\"""
      b:

        ba: 'A(B)C'# comment
        bb: ''
        bc: 67
    e: 42
    f
      ### comment ###
      'foo'
    """,
    #.......................................................................................................
    # 2
    """
    d:
      a: 64
      b:
        ba: 65
        bb: 66
        bc:
          bca: 68
    e: 69
    """,
    '' ]

  #---------------------------------------------------------------------------------------------------------
  G.tests._show_type_and_content = ( error, type, position, content ) ->
    TYPES = require 'coffeenode-types'
    throw error if error?
    if TYPES.isa_pod type
      return info ( "#{name}: #{value}" for name, value of type ).join ', '
    if arguments.length <= 3
      content = position
      return info ( TEXT.flush_right type, 10 ), if content? then TRM.gold rpr content else ''
    info ( TEXT.flush_right type, 10 ), ( TEXT.flush_left position, 8 ), if content? then TRM.gold rpr content else ''

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'helpers.step_chunkify_events (1)' ] = ( test ) ->
    source  = G.tests._sources[ 1 ]
    #.......................................................................................................
    G.helpers.step_chunkify_events source, ( error, type, content ) ->
      G.tests._show_type_and_content error, type, content

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'helpers.step_events (1)' ] = ( test ) ->
    source  = G.tests._sources[ 1 ]
    #.......................................................................................................
    G.helpers.step_events source, ( error, event ) ->
      G.tests._show_type_and_content error, event

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'helpers.step_events_with_levels (1)' ] = ( test ) ->
    source  = G.tests._sources[ 1 ]
    #.......................................................................................................
    G.helpers.step_events_with_levels source, ( error, event ) ->
      G.tests._show_type_and_content error, event

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'helpers.as_bracketed (1)' ] = ( test ) ->
    source  = G.tests._sources[ 1 ]
    debug JSON.stringify G.helpers.as_bracketed source


############################################################################################################
ƒ.new.consolidate @


