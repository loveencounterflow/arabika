
############################################################################################################
# njs_util                  = require 'util'
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾main﴿'
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
### https://github.com/isaacs/node-glob ###
GLOB                      = require 'glob'
### https://github.com/loveencounterflow/coffeenode-packrattle,
forked from https://github.com/robey/packrattle ###
π                         = require 'coffeenode-packrattle'
#...........................................................................................................
@new                      = require './nodes'
MULTIMIX                  = require 'coffeenode-multimix'


### find all files that start with a digit other than 0: ###
glob            = njs_path.join __dirname, '*'
routes          = ( route for route in GLOB.sync glob when /^[1-9]/.test njs_path.basename route )

### sort routes numerically: ###
routes.sort ( a, b ) ->
  a = parseInt ( a.replace /\/([0-9])[^\/]+/g, '$1' ), 10
  b = parseInt ( b.replace /\/([0-9])[^\/]+/g, '$1' ), 10
  return +1 if a > b
  return -1 if a < b
  return  0


modules         = ( require route for route in routes )
# info modules
module.exports  = MULTIMIX.assemble @, modules...
  # MULTIMIX.compose

