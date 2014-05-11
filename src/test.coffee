


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
#...........................................................................................................
NEW                       = require './NEW'
LOADER                    = require './grammar-loader'


#-----------------------------------------------------------------------------------------------------------
@main = ->
  route_infos = LOADER.get_route_infos()
  #.........................................................................................................
  for route_info in route_infos
    { route
      name
      nr    }   = route_info
    module = require route
    #.......................................................................................................
    unless ( TESTS = module[ 'TESTS' ] )?
      warn "no tests found for #{name} (#{route})"
      continue
    #.......................................................................................................
    whisper "testing #{name} (#{route}"
    for name of TESTS
      continue if name[ 0 ] is '_'
      try
        TESTS[ name ].apply module
      catch error
        warn "  #{TRM.grey name}: #{TRM.red error[ 'message' ]}"
        continue
      log "  #{TRM.grey name}: #{TRM.green 'ok'}"
  #.........................................................................................................
  return null



############################################################################################################
@main() unless module.parent?


