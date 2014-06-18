


### Parses nested structures.
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
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
TYPES                     = require 'coffeenode-types'
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
BNP                       = require 'coffeenode-bitsnpieces'
ƒ                         = require 'flowmatic'
$new                      = ƒ.new
XRE                       = require './XRE'


#-----------------------------------------------------------------------------------------------------------
@$ =
  # 'leading-ws':         XRE '(?:^|\\n)(\\p{Space_Separator}*)(.*)(?=\\n|$)'
  'opener':             '⟦'
  'connector':          '∿'
  'closer':             '⟧'
  ### When `true`, suites are single strings that represent lines separated by `connector`; when `false`,
  suites are lists with lines as elements: ###
  # 'join-suites':        yes
  'join-suites':        no

#-----------------------------------------------------------------------------------------------------------
@$new = $new.new @


#-----------------------------------------------------------------------------------------------------------
@$new.$suite = ( G, $ ) ->
  # metachrs  = XRE.$esc $[ 'opener' ] + $[ 'connector' ] + $[ 'closer' ]
  metachrs  = XRE.$esc $[ 'opener' ] + $[ 'closer' ]
  R         = ƒ.repeatSeparated /// [^ #{metachrs} ]+ ///, $[ 'connector' ]
  R         = R.onMatch ( match ) -> match.join $[ 'connector' ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$stage = ( G, $ ) ->
  R = ƒ.seq $[ 'opener' ], ( -> G.$chunks ), $[ 'closer' ]
  R = R.onMatch ( match ) -> match[ 1 ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$chunk = ( G, $ ) ->
  R = ƒ.or ( -> G.$suite ), ( -> G.$stage )
  # R = R.onMatch ( match ) -> [ 'chunk', match..., ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$chunks = ( G, $ ) ->
  R = ƒ.repeat ( -> G.$chunk ), 1
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

#-----------------------------------------------------------------------------------------------------------
@$new.$module = ( G, $ ) ->
  R = ƒ.seq ( -> G.$chunk ), ƒ.end
  R = R.onMatch ( match ) -> match[ 0 ]
  return R


#===========================================================================================================
# APPLY NEW TO MODULE
#-----------------------------------------------------------------------------------------------------------
### Run `@$new` to make `@` (`this`) an instance of this grammar with default options: ###
@$new @, null

#-----------------------------------------------------------------------------------------------------------
# @suite = ƒ.seq ( => @$[ 'opener' ] ), '\n',


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
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
    debug G.$chunk.run source
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
  '$module: parses nested bracketed expression (1)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': no
    source  = '<abc=def<ghi<jkl=mno>>pqr>'
    # debug G.$module.run source
    test.eq ( G.$module.run source ), [ 'abc', 'def', [ 'ghi', [ 'jkl', 'mno', ] ], 'pqr', ]

  #---------------------------------------------------------------------------------------------------------
  '$module: parses nested bracketed expression (2)': ( test ) ->
    G       = @$new opener: '<', connector: '=', closer: '>', 'join-suites': yes
    source  = '<abc=def<ghi<jkl=mno>>pqr>'
    # debug G.$module.run source
    test.eq ( G.$module.run source ), [ 'abc=def', [ 'ghi', [ 'jkl=mno', ] ], 'pqr', ]


