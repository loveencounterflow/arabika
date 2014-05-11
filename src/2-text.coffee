
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾1﴿'
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
NEW                       = require './NEW'

#-----------------------------------------------------------------------------------------------------------
@_single_quote    = π.string "'"
@_double_quote    = π.string '"'
@_nosq            = ( π.alt ( => @_escaped ), /[^']+/ )
  .onMatch ( match ) -> match[ 0 ]
@_nodq            = ( π.alt ( => @_escaped ), /[^"]+/ )
  .onMatch ( match ) -> match[ 0 ]
@_chr_escaper     = π.string '\\'
@_unicode4_escape = π.string 'u'
@_sq_text_literal = π.seq @_single_quote, @_nosq, @_single_quote
@_dq_text_literal = π.seq @_double_quote, @_nodq, @_double_quote
### TAINT maybe we should *not* un-escape anything; better for translation ###
@literal          = ( π.alt @_sq_text_literal, @_dq_text_literal )
  .onMatch ( match ) =>
    [ ignore, value, ignore, ] = match
    return NEW.literal ( match.join '' ), value


#-----------------------------------------------------------------------------------------------------------
@simple_escape = ( π.regex /[bfnrt]/ )
  .onMatch ( match ) => @_escape_table[ match[ 0 ] ]

#-----------------------------------------------------------------------------------------------------------
@_escape_table =
  b: '\b'
  f: '\f'
  n: '\n'
  r: '\r'
  t: '\t'

#-----------------------------------------------------------------------------------------------------------
### TAINT String conversion method dubious; will fail outside of Unicode BMP ###
@_unicode_hex = ( π.seq @_unicode4_escape, /[0-9a-fA-F]{4}/ )
  .onMatch ( match ) => String.fromCharCode '0x' + match[ 1 ]

#-----------------------------------------------------------------------------------------------------------
@_escaped = ( π.seq @_chr_escaper, ( π.alt @simple_escape, @_unicode_hex, /./ ) )
  .onMatch ( match ) => match[ 1 ]

