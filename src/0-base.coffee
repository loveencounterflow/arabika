

############################################################################################################
TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾1-base﴿'
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
$new                      = ƒ.new
TEXT                      = require './2-text'
CHR                       = require './3-chr'
NUMBER                    = require './4-number'
ROUTE                     = require './6-route'
XRE                       = require './9-xre'


#-----------------------------------------------------------------------------------------------------------
@$ =
  'use-keyword':    'use'

#-----------------------------------------------------------------------------------------------------------
### TAINT `ƒ.or` is an expedient here ###
@$_use_keyword     = ƒ.or => ƒ.string @$[ 'use-keyword' ]

#-----------------------------------------------------------------------------------------------------------
@use_argument     = ƒ.or ( => ROUTE.symbol ), ( => NUMBER.integer ), ( => TEXT.literal )

#-----------------------------------------------------------------------------------------------------------
@use_statement    = ( ƒ.seq ( => @$_use_keyword ), ( => CHR.ilws ), ( => @use_argument ) )
  .onMatch ( match, state ) => @nodes.use_statement state, match[ 0 ], match[ 1 ]

#-----------------------------------------------------------------------------------------------------------
@nodes = {}
_G = @
@nodes.use_statement = ( state, keyword, argument ) ->
  return ƒ.new._XXX_YYY_node _G.use_statement.as, state, 'BASE/use-statement',
    keyword:    keyword
    argument:   argument


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  'use_argument: accepts symbols': ( test ) ->
    G = @
    $ = G.$
    mark = ROUTE.$[ 'symbol/mark' ]
    probes_and_matchers = [
      [ "#{mark}x",      {"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":x","value":"x"}   ]
      [ "#{mark}foo",    {"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":foo","value":"foo"} ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.use_argument.run probe
      # debug JSON.stringify @use_argument.run probe
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  'use_argument: accepts integer': ( test ) ->
    G = @
    $ = G.$
    probes_and_matchers = [
      [ "12349876",       { type: 'NUMBER/integer', raw: '12349876', value: 12349876 } ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.use_argument.run probe
      # debug JSON.stringify @use_argument.run probe
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  'use_argument: accepts strings': ( test ) ->
    G = @
    $ = G.$
    probes_and_matchers = [
      [ "'some text'",    {"type":"TEXT/literal","value":"some text"} ]
      [ '"other text"' ,  {"type":"TEXT/literal","value":"other text"} ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.use_argument.run probe
      # debug JSON.stringify result
      test.eq result, matcher

  #---------------------------------------------------------------------------------------------------------
  'use_statement: accepts symbols, digits, strings': ( test ) ->
    G       = @
    $       = G.$
    mark    = ROUTE.$[ 'symbol/mark' ]
    keyword = G.$[ 'use-keyword' ]
    probes_and_matchers = [
      [ "use #{mark}x",       {"type":"BASE/use-statement","keyword":"use","argument":{"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":x","value":"x"}}   ]
      [ "use #{mark}foo",     {"type":"BASE/use-statement","keyword":"use","argument":{"type":"Literal","x-subtype":"symbol","x-mark":":","raw":":foo","value":"foo"}} ]
      [ "use 12349876",       {"type":"BASE/use-statement","keyword":"use","argument":{"type":"NUMBER/integer","raw":"12349876","value":12349876}} ]
      [ "use 'some text'",    {"type":"BASE/use-statement","keyword":"use","argument":{"type":"TEXT/literal","value":"some text"}}  ]
      [ 'use "other text"',   {"type":"BASE/use-statement","keyword":"use","argument":{"type":"TEXT/literal","value":"other text"}}  ]
      ]
    #.......................................................................................................
    for [ probe, matcher, ] in probes_and_matchers
      result = ƒ.new._delete_grammar_references G.use_statement.run probe
      # debug JSON.stringify result
      test.eq result, matcher

  # #---------------------------------------------------------------------------------------------------------
  # 'use_statement: compilation to JS': ( test ) ->
  #   G       = @
  #   $       = G.$
  #   mark    = ROUTE.$[ 'symbol/mark' ]
  #   keyword = G.$[ 'use-keyword' ]
  #   probes_and_matchers = [
  #     [ "use #{mark}x",      {"type":"Literal","x-subtype":"use-statement","raw":"use ':x'","value":"use ':x'"} ]
  #     [ "use #{mark}foo",    {"type":"Literal","x-subtype":"use-statement","raw":"use ':foo'","value":"use ':foo'"} ]
  #     [ "use 12349876",       {"type":"Literal","x-subtype":"use-statement","raw":"use '12349876'","value":"use '12349876'"} ]
  #     [ "use 'some text'",    {"type":"Literal","x-subtype":"use-statement","raw":"use '\\'some text\\''","value":"use '\\'some text\\''"} ]
  #     [ 'use "other text"' ,  {"type":"Literal","x-subtype":"use-statement","raw":"use '\"other text\"'","value":"use '\"other text\"'"} ]
  #     ]
  #   #.......................................................................................................
  #   for [ probe, matcher, ] in probes_and_matchers
  #     # debug JSON.stringify @use_statement.run probe
  #     test.eq ( test.as_js @use_statement.run probe ), result














