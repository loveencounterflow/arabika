


############################################################################################################
# njs_util                  = require 'util'
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾test﴿'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
urge                      = TRM.get_logger 'urge',      badge
echo                      = TRM.echo.bind TRM
#...........................................................................................................
NEW                       = require './NEW'
LOADER                    = require './grammar-loader'
assert                    = require 'assert'
#...........................................................................................................
BNP                       = require 'coffeenode-bitsnpieces'
ESCODEGEN                 = require 'escodegen'
escodegen_options         = ( require '../options' )[ 'escodegen' ]

#-----------------------------------------------------------------------------------------------------------
@test =

  #---------------------------------------------------------------------------------------------------------
  ok: ( result ) =>
    ### `assert.deepEqual` is broken as of https://github.com/joyent/node/issues/7161 ###
    throw new Error "expected true, got\n#{rpr result}" unless result is true

  #---------------------------------------------------------------------------------------------------------
  eq: ( P... ) =>
    ### `assert.deepEqual` is broken as of https://github.com/joyent/node/issues/7161 ###
    throw new Error "not equal: \n#{( rpr p for p in P ).join '\n'}" unless BNP.equals P...

  #---------------------------------------------------------------------------------------------------------
  as_js: ( node ) =>
    return ESCODEGEN.generate node, escodegen_options

  #---------------------------------------------------------------------------------------------------------
  throws: assert.throws.bind assert

#-----------------------------------------------------------------------------------------------------------
@main = ->
  route_infos = LOADER.get_route_infos()
  #.........................................................................................................
  for route_info in route_infos
    { route, name: module_name, nr } = route_info
    module = require route
    #.......................................................................................................
    unless ( TESTS = module[ 'TESTS' ] )?
      urge "no tests found for #{module_name} (#{route})"
      continue
    #.......................................................................................................
    for test_name of TESTS
      locator = module_name + '/' + test_name
      try
        TESTS[ test_name ].call module, @test
      catch error
        warn "#{locator}:"
        warn error[ 'message' ]
        continue
      log "#{TRM.grey locator}: #{TRM.green 'ok'}"
  #.........................................................................................................
  return null



############################################################################################################
@main() unless module.parent?


