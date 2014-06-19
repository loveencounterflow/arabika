
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾5-quantity﴿'
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
  G.helpers.walk_chunkify_events_1 = ( source, handler ) ->
    type      = 'other'
    last_type = type
    lines     = G.helpers._lines_of source
    #.......................................................................................................
    for line, line_idx in lines
      handler null, 'newline'
      type  = 'other' if type is 'eol-comment'
      parts = G.helpers._parts_of line
      # whisper ( rpr line ), TRM.lime parts
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
        if ( type is 'other' ) and ( last_type isnt 'other' ) and ( last_type isnt 'eol-comment' )
          handler null, last_type, part
        else
          handler null, type, part
        last_type = type
    #.......................................................................................................
    handler null, null
    return null

  #---------------------------------------------------------------------------------------------------------
  G.helpers.walk_chunkify_events_2 = ( source, handler ) ->
    buffer    = []
    last_type = null
    #-------------------------------------------------------------------------------------------------------
    send_buffer = ->
      handler null, last_type, buffer.join '' if buffer.length isnt 0
      buffer.length = 0
    #-------------------------------------------------------------------------------------------------------
    G.helpers.walk_chunkify_events_1 source, ( error, type, content ) ->
      throw error if error?
      # info type, if content? then TRM.gold rpr content else ''
      #.....................................................................................................
      if type is null
        send_buffer()
        handler null, 'newline'
        return handler null, null
      #.....................................................................................................
      if type is 'newline'
        #...................................................................................................
        if ( last_type is 'other' ) or ( last_type is 'eol-comment' )
          send_buffer()
          handler null, 'newline'
          return
        #...................................................................................................
        if last_type isnt null
          buffer.push '\n'
          type = last_type
        return
      #.....................................................................................................
      send_buffer() if ( last_type isnt null ) and ( type isnt last_type )
      last_type = type
      buffer.push content
    #-------------------------------------------------------------------------------------------------------
    return null

  #---------------------------------------------------------------------------------------------------------
  G.helpers.walk_chunkify_events_3 = ( source, handler ) ->
    last_type     = null
    ### TAINT simplified setup ###
    level         = 0
    last_level    = level
    dent          = '  '
    dent_length   = dent.length
    dent_matcher  = /// ^ (?: #{XRE.$esc dent} )* ///
    opener        = '('
    connector     = ';'
    closer        = ')'
    #-------------------------------------------------------------------------------------------------------
    adjust_content_level = ( content ) ->
      indentation = ( content.match dent_matcher )[ 0 ]
      level       = indentation.length / dent_length
      whisper level, level - last_level, rpr content
      content     = content.replace indentation, ''
      unless level is Math.floor level
        return handler new Error "illegal indentation on line #xxx: #{rpr content}"
      if      last_level > level then content = ( TEXT.repeat closer, last_level - level ) + content
      else if last_level < level then content = ( TEXT.repeat opener, level - last_level ) + content
      else                            content = connector + content
      last_level = level
      return content
    #-------------------------------------------------------------------------------------------------------
    G.helpers.walk_chunkify_events_2 source, ( error, type, content ) ->
      throw error if error?
      #.....................................................................................................
      ### Pass through events that are irrelevant for indentation: ###
      if ( type isnt 'other' ) and ( type isnt 'newline' )
        return handler null, type, content
      #.....................................................................................................
      if type is 'other' and last_type is 'newline'
        content = adjust_content_level content
      #.....................................................................................................
      if content? then handler null, type, content else handler null, type
      last_type = type
      return
    #-------------------------------------------------------------------------------------------------------
    return null

  #---------------------------------------------------------------------------------------------------------
  G.helpers.as_bracketed = ( source ) ->
    R = []
    #-------------------------------------------------------------------------------------------------------
    G.helpers.walk_chunkify_events_3 source, ( error, type, content ) ->
      throw error if error?
      R.push content unless type is 'newline'
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
      a: \"""helo
        world\"""
      b:
        ba: 65
        bb: 66
        bc: 67
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
  G.tests._show_type_and_content = ( error, type, content ) ->
    throw error if error?
    info ( TEXT.flush_right type, 15 ), if content? then TRM.gold rpr content else ''

  #---------------------------------------------------------------------------------------------------------
  G.tests[ '_helpers.walk_chunkify_events_3 (0)' ] = ( test ) ->
    source  = G.tests._sources[ 0 ]
    #.......................................................................................................
    G.helpers.walk_chunkify_events_3 source, ( error, type, content ) ->
      G.tests._show_type_and_content error, type, content

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'helpers.walk_chunkify_events_1 (1)' ] = ( test ) ->
    source  = G.tests._sources[ 1 ]
    #.......................................................................................................
    G.helpers.walk_chunkify_events_1 source, ( error, type, content ) ->
      G.tests._show_type_and_content error, type, content

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'helpers.walk_chunkify_events_2 (1)' ] = ( test ) ->
    source  = G.tests._sources[ 1 ]
    #.......................................................................................................
    G.helpers.walk_chunkify_events_2 source, ( error, type, content ) ->
      G.tests._show_type_and_content error, type, content

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'helpers.walk_chunkify_events_3 (1)' ] = ( test ) ->
    source  = G.tests._sources[ 1 ]
    #.......................................................................................................
    G.helpers.walk_chunkify_events_3 source, ( error, type, content ) ->
      G.tests._show_type_and_content error, type, content

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'helpers.as_bracketed (1)' ] = ( test ) ->
    source  = G.tests._sources[ 1 ]
    debug rpr G.helpers.as_bracketed source

  #---------------------------------------------------------------------------------------------------------
  G.tests[ '_helpers.as_bracketed (0)' ] = ( test ) ->
    source  = G.tests._sources[ 0 ]
    debug rpr G.helpers.as_bracketed source

  #---------------------------------------------------------------------------------------------------------
  G.tests[ '_helpers.as_bracketed (2)' ] = ( test ) ->
    source  = G.tests._sources[ 2 ]
    debug rpr G.helpers.as_bracketed source


############################################################################################################
ƒ.new.consolidate @


