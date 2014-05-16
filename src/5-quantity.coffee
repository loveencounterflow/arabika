
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
π                         = require 'coffeenode-packrattle'
# BASE                      = require './1-base'
NUMBER                    = require './4-number'
NEW                       = require './NEW'


#-----------------------------------------------------------------------------------------------------------
# @quantity = π.seq @NUMBER.literal, @unit


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
# @TESTS =

#   #---------------------------------------------------------------------------------------------------------
#   'digits: parses sequences of ASCII digits': ( test ) ->
#     for probe in """0 12 7 1928374 080""".split /\s+/
#       test.eq ( @digits.run probe ), ( NEW.literal 'digits', probe, probe )
