
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'more-experiments'
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


#===========================================================================================================
# TOKEN CLASSES
#-----------------------------------------------------------------------------------------------------------
# NUMBER LITERALS
#-----------------------------------------------------------------------------------------------------------
ascii_digits            = /// [0-9]+ ///



#-----------------------------------------------------------------------------------------------------------
# IDENTIFIERS
#-----------------------------------------------------------------------------------------------------------
### Matches basic US-ASCII names with upper- and lower case letters plus digits, where only letters are
allowed as first character. Does not include *any* punctuation. ###
basic_ascii_name = /// [a-zA-Z] [a-zA-Z0-9]* ///

### Like `basic_ascii_name`, but allows for a dash in the middle of a name. ###
ascii_name = π.regex ///
  # (3 or more chrs)
  [a-zA-Z] [a-zA-Z0-9]* [-a-zA-Z0-9]*? [a-zA-Z0-9]+ |
  # match one alphabetic and an optional alphanumeric chr (1 or 2 chrs), OR
  [a-zA-Z] [a-zA-Z0-9]?
  ///

#-----------------------------------------------------------------------------------------------------------
# WHITESPACE
#-----------------------------------------------------------------------------------------------------------
one_asciispace            = π.regex /// \x20 ///
two_asciispaces           = π.regex /// \x20{2} ///

### Matches zero or an even number of ASCII space characters (`\x20`). ###
two_n0_asciispaces        = π.regex ///(?: \x20{2} )*///

### Matches zero or more ASCII space characters (`\x20`). ###
optional_asciispaces      = π.regex /// \x20* ///

### Matches one or more ASCII space characters (`\x20`). ###
asciispaces               = π.regex /// \x20+ ///

### For the time being, we only recognize U-0020 as linear whitespace: ###
lws                       = asciispaces

#-----------------------------------------------------------------------------------------------------------
# PUNCTUATION
#-----------------------------------------------------------------------------------------------------------
test_for_comma          = π.regex /,/
test_for_nocomma        = π.regex /[^,]*/


#===========================================================================================================
# MATCHERS
#-----------------------------------------------------------------------------------------------------------
id = ( x ) ->
  return x

#-----------------------------------------------------------------------------------------------------------
number = ( π.regex ascii_digits ).onMatch ( match ) ->
  return parseInt match[ 0 ], 10

#-----------------------------------------------------------------------------------------------------------
comma = test_for_comma.onMatch ( match ) ->
  # debug 'comma', match[ 0 ]
  return match[ 0 ]

#-----------------------------------------------------------------------------------------------------------
nocomma = test_for_nocomma.onMatch ( match ) ->
  # debug 'nocomma', match[ 0 ]
  return match[ 0 ]


#===========================================================================================================
# ASSIGNMENTS
#-----------------------------------------------------------------------------------------------------------
assignment_lhs            = π.alt ascii_name
assignment_rhs            = π.alt expression

#===========================================================================================================
# ACTORS
#-----------------------------------------------------------------------------------------------------------
add = ( total, separator, n ) ->
  debug 'add', total, separator, n
  return total + n


#===========================================================================================================
# PARSERS
#-----------------------------------------------------------------------------------------------------------
# expression = π.reduce number, "+", id, add
expression = π.reduce ascii_digits, '+', id, add

#-----------------------------------------------------------------------------------------------------------
csv         = π.repeatSeparated nocomma, comma
# sum     = π.seq ( -> expr ), '+', ( -> expr )
# product = π.seq ( -> expr ), '*', ( -> expr )
product     = π.seq ( -> expr ), lws, '*', lws, ( -> expr )
division    = π.seq ( -> expr ), lws, '/', lws, ( -> expr )
sum         = π.seq ( -> expr ), lws, '+', lws, ( -> expr )
difference  = π.seq ( -> expr ), lws, '-', lws, ( -> expr )
# sum_expr    = π.alt sum, number
sum_expr    = π.alt sum, difference, number
expr        = π.alt sum_expr, product, division
expr.describe 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
expr.onMatch ( match ) ->
  debug match
  return [ 'expr', match, ]

#===========================================================================================================
# FUNCTIONS
#-----------------------------------------------------------------------------------------------------------
single_slim_arrow         = π.string '->'
single_fat_arrow          = π.string '=>'
double_slim_arrow         = π.string '<->'
double_fat_arrow          = π.string '<=>'
arrow                     = π.alt single_slim_arrow, single_fat_arrow, double_slim_arrow, double_fat_arrow
return_literal            = π.string '<-'
bare_return_statement     = return_literal
filled_return_statement   = π [ return_literal, lws, expr, ]
return_statement          = π.alt bare_return_statement, filled_return_statement
parameter_separator       = π.seq comma, lws
bare_name_list            = π.repeatSeparated ascii_name, parameter_separator
signature_open            = π.string '('
signature_close           = π.string ')'
optional_comma            = π.optional comma
empty_signature           = π [ signature_open,                                           signature_close, ]
filled_signature          = π [ signature_open, lws, bare_name_list, optional_comma, lws, signature_close, ]
signature                 = π.alt empty_signature, filled_signature
bare_function_def_head    = arrow
filled_function_def_head  = π [ signature, lws, arrow, ]
function_def_head         = π.alt filled_function_def_head, bare_function_def_head
exp_or_return             = π.alt return_statement, expr
### TAINT need to separate statements and expressions with semicolons or other punctuation ###
exps_or_returns           = π.repeat ( π.alt return_statement, expression ), 1
# filled_function_def_body  = π.string ''
inline_function_def_body  = π [ lws, exp_or_return, ]
inline_function_def       = π [ function_def_head, π.optional π [ lws, inline_function_def_body, ] ]
staged_function_def       = π.string '????????????????????????'
function_def              = π.alt staged_function_def, inline_function_def


############################################################################################################
# info expression.run "3+50+2"
# info csv.run "this,is,csv"

# info comma.run ','

# try
#   info comma.run '+'
# catch error
#   warn error[ 'message' ]
#   state = error[ 'state' ]

# expr.matchIf ( term ) ->
#   debug 'expr.matchIf', term
#   return true

# info expr.run '2+10+100'
# info rv  = π.consume expr, '2+10+100!!!'
source  = '2+10+100!!!'
source  = '2+10+100'
# info rv  = π.parse    expr, source
# info rv  = π.consume  expr, source, debugGraph: yes
# info rv  = π.consume  expression, source, debugGraph: yes
rv      = π.consume  ( π.repeat ( π.alt /[0-9]+/, '+' ), 1 ), source, debugGraph: yes
# TRM.dir sum

#-----------------------------------------------------------------------------------------------------------
show_parse_result = ( name, parse_result ) ->
  # debug parse_result
  state     = parse_result[ 'state' ]
  source    = state[ 'internal' ][ 'text' ]
  log TRM.grey '------------------------------------------------------------------------------'
  log TRM.grey name, rpr source
  if ( message = parse_result[ 'message' ] )?
    warn message
    warn source
  else
    loc       = state[ 'loc'     ]
    oldloc    = state[ 'oldloc'  ]
    endloc    = state[ 'endloc'  ]
    squiggles = state.toSquiggles()
    prefix    = TRM.white source[ oldloc[ 'pos' ] ... loc[ 'pos' ] ]
    info TRM.gold rpr _clean_match parse_result[ 'match' ]
    if loc[ 'pos' ] == source.length
      info ok.concat prefix
    else
      info notok.concat prefix, ( TRM.red TRM.reverse TRM.bold source[ loc[ 'pos' ] .. ] )
ok    = TRM.green TRM.bold '✓ '
notok = TRM.red   TRM.bold '✘ '

#-----------------------------------------------------------------------------------------------------------
_clean_match = ( match ) ->
  return match unless TYPES.isa_list match
  R = []
  for element in match
    R.push _clean_match element
  return R

#-----------------------------------------------------------------------------------------------------------
parse = ( P... ) ->
  return show 'parse', P...

#-----------------------------------------------------------------------------------------------------------
consume = ( P... ) ->
  return show 'consume', P...

#-----------------------------------------------------------------------------------------------------------
show = ( method_name, grammar, name, source ) ->
  parser = if grammar? then grammar[ name ] else eval name
  show_parse_result name, R = π[ method_name ] parser, source
  return R

test = ->
  grammar = null
  consume grammar, 'ascii_digits', '1234'
  consume grammar, 'ascii_digits', '1234...'
  consume grammar, 'ascii_name', 'helo'
  consume grammar, 'ascii_name', 'helo-there'
  consume grammar, 'ascii_name', '-h'
  consume grammar, 'ascii_name', 'h-'
  consume grammar, 'ascii_name', '-helo'
  consume grammar, 'ascii_name', 'helo-'
  consume grammar, 'ascii_name', 'h-o'
  consume grammar, 'ascii_name', 'he-o'
  consume grammar, 'ascii_name', 'h-lo'
  consume grammar, 'ascii_name', 'h2-o'
  consume grammar, 'ascii_name', 'H2-O'
  consume grammar, 'ascii_name', 'x1'
  consume grammar, 'ascii_name', 'x12'
  consume grammar, 'ascii_name', 'helo 1234'
  consume grammar, 'ascii_name', ''
  consume grammar, 'ascii_name', '1234'
  consume grammar, 'number', '1234'
  consume grammar, 'sum', '1234'
  consume grammar, 'sum', '1234+1234'
  consume grammar, 'sum', '1234 +1234'
  consume grammar, 'sum', '1234 + 1234'
  consume grammar, 'product', '1234'
  consume grammar, 'product', '1234*1234'
  consume grammar, 'product', '1234 *1234'
  consume grammar, 'product', '1234 * 1234'
  consume grammar, 'expr', '1234'
  consume grammar, 'expr', '1234*1234'
  consume grammar, 'expr', '1234+1234'
  consume grammar, 'expr', '1234+1234*456'
  consume grammar, 'expr', '1234 *1234'
  consume grammar, 'expr', '1234 * 1234'
  consume grammar, 'expr', '12 * 34 + 56'
  consume grammar, 'expr', '12 / 34 + 56'
  consume grammar, 'expr', '12 + 34 * 56'
  consume grammar, 'expr', '12 + 34 / 56'
  parse grammar, 'expr', '12 + 34 / 56'
  consume grammar, 'single_slim_arrow', '->'
  consume grammar, 'single_slim_arrow', '=>'
  consume grammar, 'single_fat_arrow', '->'
  consume grammar, 'single_fat_arrow', '=>'
  consume grammar, 'single_slim_arrow', '<->'
  consume grammar, 'single_slim_arrow', '<=>'
  consume grammar, 'single_fat_arrow', '<->'
  consume grammar, 'single_fat_arrow', '<=>'
  consume grammar, 'double_slim_arrow', '<->'
  consume grammar, 'double_slim_arrow', '<=>'
  consume grammar, 'double_fat_arrow', '<->'
  consume grammar, 'double_fat_arrow', '<=>'
  consume grammar, 'parameter_separator', ','
  consume grammar, 'parameter_separator', ' ,'
  consume grammar, 'parameter_separator', ', '
  consume grammar, 'parameter_separator', ',  '
  consume grammar, 'bare_name_list', ''
  consume grammar, 'bare_name_list', '1'
  consume grammar, 'bare_name_list', '1, 2'
  consume grammar, 'empty_signature', '()'
  consume grammar, 'empty_signature', '(   )'
  consume grammar, 'filled_signature', '()'
  consume grammar, 'filled_signature', '(   )'
  consume grammar, 'filled_signature', '( 42 )'
  consume grammar, 'filled_signature', '( 42, )'
  consume grammar, 'filled_signature', '( 42, 108 )'
  consume grammar, 'filled_signature', '( 42, 108, )'
  consume grammar, 'filled_signature', '( foo )'
  consume grammar, 'filled_signature', '( foo, )'
  consume grammar, 'filled_signature', '( foo, bar )'
  consume grammar, 'filled_signature', '( foo, bar, )'
  consume grammar, 'filled_signature', '(foo)'
  consume grammar, 'filled_signature', '(foo,)'
  consume grammar, 'filled_signature', '(foo, bar)'
  consume grammar, 'filled_signature', '(foo, bar,)'
  consume grammar, 'inline_function_def', '->'
  consume grammar, 'inline_function_def', '=>'
  consume grammar, 'inline_function_def', '() =>'
  consume grammar, 'inline_function_def', '( a ) =>'
  consume grammar, 'inline_function_def', '( a ) <=> 42'
  consume grammar, 'inline_function_def', '( a ) => <- 42'
  consume grammar, 'inline_function_def', '( a, ) =>'
  consume grammar, 'inline_function_def', '( a, b ) =>'
  consume grammar, 'inline_function_def', '( a, b, ) =>'
  consume grammar, 'inline_function_def', '( a, 42, ) =>'
  consume grammar, 'inline_function_def', '( a, 42, ) => <-'
  consume grammar, 'inline_function_def', '( a, b, ) => <- a + b'
  consume grammar, 'inline_function_def', '( a, b, ) <=> a + b'

test()

# source        = '1 + 2 + 3 * 4'
# parse_result  = π.consume expr, source
# info parse_result
parser = π.string 'abc'
parser = parser.onMatch ( match, state ) ->
  warn rpr match
  return [ 'text', match, ]
info π.parse parser, 'abcx'



# s = sum '1+2+3'
# echo expr.toDot()
# echo number.toDot()
# echo expression.toDot()
# parse_result  = π.consume inline_function_def, '( a, ) <=> 42', debugGraph: yes
# parse_result  = π.consume expr, '42 + 12 * 3', debugGraph: yes
# state         = parse_result[ 'state' ]
# echo state.debugGraphToDot()
# info 'ok'

# π.string "..."   # match exactly this string, and return it
# π.regex /.../    # match this regex, and return the match object (which can be used to extract any groups)
# π.end()          # matches only the end of the string
# π.reject()       # always fails to match



### If 'p1' matches, return that as the result; otherwise, try 'p2', and so on, until finding a match.
If none of the parsers match, fail. ###
# π.alt p1, p2, ...

### Verify that 'p' matches, but don't advance the parser's position. Perl calls this a
"zero-width lookahead". ###
# π.check p

### If 'p' matches, packrattle will no longer backtrack through previous 'alt' alternatives: the parsing
is "committed" to this branch. (This can be used with 'onFail' to give less ambiguous error messages.) ###
# π.commit p

### If 'p' matches, return null as the match result, which will cause it to be omitted from the result
of any sequence. ###
# π.drop p

### Turn a successful match of 'p' into a failure, or a failure into a success (with an empty string as
the match result). ###
# π.not_ p

### Match 'p' or return the default value (usually the empty string), succeeding either way. ###
# π.optional p, defaultValue = ""

### Match 'p' multiple times (often written as "p*"). The match result will be an array of all the
non-null 'p' results. (Note that it's trivial to match zero times, so often you want to set
'minCount' to 1.) ###
# π.repeat p, minCount = 0, maxCount = infinity

### Match all of the parsers in sequence. The match result will be an array of all of the non-null match
results. ###
# π.seq p1, p2, ...


# All of the combinators are also defined as methods on the parsers, so you can chain them with method
# calls. The method versions all take one fewer argument, because the first 'p' is implied.

# For example, these two lines are equivalent:

# var comment = pr.seq(pr.commit(pr.string("#")), pr.regex(/[^\n]+\n/));
# var comment = pr.seq(pr.string("#").commit(), pr.regex(/[^\n]+\n/));


# parser.onMatch f          # If the parser is successful, call 'f' on the match result, using the return
                            # value of 'f' as the new match result.
# parser.onFail newMessage  # Replace the error message for this parser when it fails to match.
# parser.describe message   # Calls onFail("Expected " + message), but also sets the parser's description
                            # for debugging purposes.
# parser.matchIf f          # If the parser is successful, call 'f' on the match result: if it returns true,
                            # continue as normal, but if it returns false, fail to match.



### Like seq, but make an attempt to match 'ignore' before each parser, throwing away the result if it
matches and ignoring if it doesn't. This is typically used to discard whitespace. ###
# seqIgnore(ignore, p1, p2, ...)

### Similar to 'seqIgnore', attempts to match 'ignore' before each iteration of 'p', throwing away
the result. ###
# repeatIgnore(ignore, p, minCount = 0, maxCount = infinity)

### Like 'repeatIgnore', but there must be at least one match of 'p', the separator is not optional,
and the separator is only matched (and discarded) between items. ###
# repeatSeparated(p, separator = "", minCount = 1, maxCount = infinity)








