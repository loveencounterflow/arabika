
############################################################################################################
π                         = require 'coffeenode-packrattle'

#-----------------------------------------------------------------------------------------------------------
### Linear WhiteSpace ###
@lws = ( π.regex /\x20+/ )
  .onMatch ( match ) -> [ 'lws', match[ 0 ], ]

#-----------------------------------------------------------------------------------------------------------
### invisible LWS ###
@ilws = π.drop π.regex /\x20+/

#-----------------------------------------------------------------------------------------------------------
### no WhiteSpace ###
@nws = ( π.regex /\S+/ )
  .onMatch ( match ) => [ 'nws', match[ 0 ], ]