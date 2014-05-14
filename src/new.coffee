

############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾base﴿'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM
#...........................................................................................................
MULTIMIX                  = require 'coffeenode-multimix'



#===========================================================================================================
# STANDARDS
#-----------------------------------------------------------------------------------------------------------
@binary_expression = ( subtype, operator, left, right, verbatim ) ->
  R                 = @_new_node 'BinaryExpression', subtype, verbatim
  R[ 'operator'   ] = operator
  R[ 'left'       ] = left
  R[ 'right'      ] = right
  return R

#-----------------------------------------------------------------------------------------------------------
@block_statement = ( subtype, body, verbatim ) ->
  R                 = @_new_node 'BlockStatement', subtype, verbatim
  R[ 'body'       ] = body
  return R

#-----------------------------------------------------------------------------------------------------------
@literal = ( subtype, raw, value, verbatim ) ->
  R                 = @_new_node 'Literal', subtype, verbatim
  R[ 'raw'        ] = raw
  R[ 'value'      ] = value
  return R


#===========================================================================================================
# ADDITIONS
#-----------------------------------------------------------------------------------------------------------
@x_comment = ( text, subtype = 'comment' ) ->
  verbatim = '/* ' + ( text.replace /\/\*/g, '/ *' ) + ' */'
  return @literal subtype, null, null, verbatim

#-----------------------------------------------------------------------------------------------------------
@x_use_statement = ( keyword, argument ) ->
  text = "#{keyword} #{rpr argument}"
  return @x_comment text, 'use-statement'


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@_new_node = ( type, subtype, verbatim ) ->
  R =
    type:         type
    'x-subtype':  subtype
  R[ 'x-verbatim' ] = verbatim if verbatim?
  return R

#-----------------------------------------------------------------------------------------------------------
@_add_verbatim = ( node, verbatim ) ->


############################################################################################################
MULTIMIX.bundle @


