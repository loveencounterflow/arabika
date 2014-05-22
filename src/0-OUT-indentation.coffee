
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
# XRE                       = require './9-xre'
$new                      = require './NEW'


# #-----------------------------------------------------------------------------------------------------------
# @$ =
#   'leading-ws':         XRE '(?:^|\\n)(\\p{Space_Separator}*)(.*)(?=\\n|$)'
#   'opener':             '⟦'
#   'connector':          '∿'
#   'closer':             '⟧'

### Parses nested structures.
* **meta-characters** are `<`, `=`, `>` (easy to type, not special in RegExes);
* **material characters** are code points that are not meta-characters;
* **phrase**: a contiguous sequence of material characters;
* **suite**: a contiguous sequence of phrases;
* **stage**: suites with a common parent; may include nested stages
* **module**: the outermost stage of a given source.

# * **chunk**
# * **block**

Valid inputs include:

````
<>
<1>
<1 = 2>
<1 = 2 <3>>
<1 = 2 <3 <4>>
<1 = 2 <3 <4 = 5>>
<1 = 2 <3 <4 = 5> 6>
<1 = 2 <3 <4 = 5> 6 = 7>
````

###

  # accumulator = null
  # reducer     = null

#-----------------------------------------------------------------------------------------------------------
@$new = $new.new @

#-----------------------------------------------------------------------------------------------------------
@$new.$phrase = ( G, $ ) ->
  R = π.alt /[^<=>]+/
  R = R.onMatch ( match ) -> match[ 0 ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$suite = ( G, $ ) ->
  R = π.repeatSeparated ( -> G.$phrase ), /// = ///
  R = R.onMatch ( match ) -> [ 'suite', match... ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$chunk = ( G, $ ) ->
  R = π.alt ( -> G.$suite ), ( -> G.$stage )
  R = R.onMatch ( match ) -> [ 'chunk', match... ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$chunks = ( G, $ ) ->
  R = π.repeat ( -> G.$chunk ), 1
  R = R.onMatch ( match ) -> [ 'chunks', match... ]
  return R

#-----------------------------------------------------------------------------------------------------------
@$new.$stage = ( G, $ ) ->
  R = π.seq /</, ( -> G.$chunks ), />/
  R = R.onMatch ( match ) -> [ 'stage', match... ]
  return R


#===========================================================================================================
# APPLY NEW TO MODULE
#-----------------------------------------------------------------------------------------------------------
### Run `@$new` to make `@` (`this`) an instance of this grammar with default options: ###
@$new @, null

#-----------------------------------------------------------------------------------------------------------
# @suite = π.seq ( => @$[ 'opener' ] ), '\n',


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@$TESTS =

  #---------------------------------------------------------------------------------------------------------
  '$phrase: parses source without meta-characters': ( test ) ->
    null
#     source  = """(xxx)"""
#     source  = """(A(B)C)"""
#     source  = """(xxx(yyy(zzz))aaa)"""
#     source  = """(xxx|www|333(yyy(zzz))aaa)"""
#     # test.eq ( @expression.run probe ), ( NEW.literal 'digits', probe, probe )




# @_() unless module.parent?


