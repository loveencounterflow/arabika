



############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾11-loop﴿'
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
BNP                       = require 'coffeenode-bitsnpieces'


#===========================================================================================================
# OPTIONS
#-----------------------------------------------------------------------------------------------------------
@options =
  'loop-keyword':         'loop'
  'break-keyword':        'break'
  # TEXT:                   require './2-text'
  # CHR:                    require './3-chr'
  # NUMBER:                 require './4-number'
  # ROUTE:                  require './6-route'
  INDENTATION:            require './7-indentation'
  LINE:                   require './12-line'


#===========================================================================================================
# CONSTRUCTOR
#-----------------------------------------------------------------------------------------------------------
@constructor = ( G, $ ) ->
  # debug '©421', ( name for name of G )
  # debug '©421', ( name for name of $ )


  #=========================================================================================================
  # RULES
  #---------------------------------------------------------------------------------------------------------
  G.break_statement = ->
    return ƒ.or -> $[ 'break-keyword' ]
    .onMatch ( match, state ) -> G.nodes.break_statement state
    .describe 'break-statement'

  #---------------------------------------------------------------------------------------------------------
  G.loop_keyword = ->
    return ƒ.or -> $[ 'loop-keyword' ]

  #---------------------------------------------------------------------------------------------------------
  G.loop_statement = ->
    # return ƒ.seq ( -> $.INDENTATION.$step ), ( -> $.INDENTATION.$chunk )
    return ƒ.seq ( -> $[ 'loop-keyword' ] ), ( -> ƒ.check $.INDENTATION.$indent ), ( -> $.INDENTATION.$chunk )
    .onMatch ( match, state ) ->
      loop_keyword        = $[ 'loop-keyword' ]
      [ keyword
        opener
        chunk ] = match
      throw new Error "expected #{rpr loop_keyword}, got #{rpr keyword}" unless keyword is loop_keyword
      ### TAINT not correct, chunk may contain other suites ###
      ### TAINT shouldn't parse here, but in INDENTATION.$chunk ###
      # chunk               = ( $.LINE.line.run line for line in chunk )
      # whisper ƒ.new._delete_grammar_references chunk
      return G.nodes.loop_statement state, keyword, chunk
    .describe 'loop-statement'


  #=========================================================================================================
  # TRANSLATORS
  #---------------------------------------------------------------------------------------------------------
  G.break_statement.as =
    coffee: ( node ) ->
      # whisper node
      return target: 'break', taints: null

  #---------------------------------------------------------------------------------------------------------
  G.loop_statement.as =
    coffee: ( node ) ->
      ### TAINT not correct, chunk may contain other suites ###
      chunk_results = ( ƒ.as.coffee line for line in node[ 'chunk' ] )
      taints        = ƒ.as._collect_taints chunk_results...
      target        = [ 'loop' ]
      # whisper chunk_results
      for chunk_result in chunk_results
        target.push '  ' + chunk_result[ 'target' ]
      target        = target.join '\n'
      return target: target, taints: taints


  #=========================================================================================================
  # NODES
  #---------------------------------------------------------------------------------------------------------
  G.nodes.break_statement = ( state, match ) ->
    return ƒ.new._XXX_YYY_node G.break_statement.as, state, 'break-statement',
      'keyword':   $[ 'break-keyword' ]

  #---------------------------------------------------------------------------------------------------------
  G.nodes.loop_statement = ( state, keyword, chunk ) ->
    return ƒ.new._XXX_YYY_node G.loop_statement.as, state, 'loop-statement',
      'keyword':    keyword
      'chunk':      chunk


  #=========================================================================================================
  # TESTS
  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'break: break keyword' ] = ( test ) ->
    keyword = $[ 'break-keyword' ]
    probes_and_matchers  = [
      [ "#{keyword}", {"type":"break-statement","keyword":"break"}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.break_statement.run probe
      # debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'loop: keyword and stage' ] = ( test ) ->
    keyword = $[ 'loop-keyword' ]
    probes_and_matchers  = [
      [ """
        #{keyword}
          foo
          bar
          baz
        """, {"type":"loop-statement","keyword":"loop","chunk":[{"type":"relative-route","raw":"foo","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"foo"}]},{"type":"relative-route","raw":"bar","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"bar"}]},{"type":"relative-route","raw":"baz","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"baz"}]}]}, ]
      [ """
        #{keyword}
          foo
          bar
          loop
            arc
            bo
            cy
          dean
          eps
        """, {"type":"loop-statement","keyword":"loop","chunk":[{"type":"relative-route","raw":"foo","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"foo"}]},{"type":"relative-route","raw":"bar","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"bar"}]},"loop",{"type":"relative-route","raw":"abo","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"abo"}]},{"type":"relative-route","raw":"dean","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"dean"}]},{"type":"relative-route","raw":"eps","value":[{"type":"Identifier","x-subtype":"identifier-without-sigil","name":"eps"}]}]}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      probe   = $.INDENTATION.$_as_bracketed probe
      probe   = probe.replace /^【(.*)】$/, '$1'
      # whisper probe
      result  = ƒ.new._delete_grammar_references G.loop_statement.run probe
      # debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'loop: refuses to parse dedent' ] = ( test ) ->
    keyword = $[ 'loop-keyword' ]
    probes_and_matchers  = [
      [ """
        #{keyword}
          foo
          bar
          baz
        bling
        """, {}, ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      test.throws ( -> G.loop_statement.run probe ), /Expected loop/

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'break_statement.as.coffee: render break statement' ] = ( test ) ->
    probes_and_matchers  = [
      [ "break", "break", ]
      # [ "#{joiner}chinese#{joiner}𠀁#{mark} 'some text'", "### unable to find translator for Literal/text ###\n$FM[ 'global' ][ 'chinese' ][ '𠀁' ] = 'some text'", ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      node        = G.break_statement.run probe
      translation = G.break_statement.as.coffee node
      result      = ƒ.as.coffee.target translation
      # debug JSON.stringify result
      # debug '\n' + result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  G.tests[ 'loop_statement.as.coffee: render loop statement' ] = ( test ) ->
    loop_keyword  = $[ 'loop-keyword' ]
    break_keyword = $[ 'break-keyword' ]
    probes_and_matchers  = [
      [ """#{loop_keyword}【#{break_keyword}】""", "loop\n  break", ]
      [ """#{loop_keyword}【foo/bar: 42】""", "### unable to find translator for Literal/integer ###\nloop\n  $FM[ 'scope' ][ 'foo' ][ 'bar' ] = 42", ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      node        = G.loop_statement.run probe
      translation = G.loop_statement.as.coffee node
      result      = ƒ.as.coffee.target translation
      # debug JSON.stringify result
      # debug '\n' + result
      test.eq result, matcher



############################################################################################################
ƒ.new.consolidate @

# debug '©321', ( name for name of @ )

# (require './6-name').route.run 'foo/bar'
# @assignment.run 'd: 3'
# @assignment.run 'def/ghi'
# @assignment.run '10'
# @assignment.run '"10"'
# @assignment.run ' '

