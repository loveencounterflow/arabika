
############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = '﴾9-xre﴿'
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
# ƒ                         = require 'flowmatic'
# $new                      = ƒ.new
#...........................................................................................................
### See:
  https://github.com/loveencounterflow/xregexp3
  https://github.com/slevithan/xregexp/wiki/Roadmap
  https://gist.github.com/slevithan/2630353
  http://blog.stevenlevithan.com/archives/javascript-regex-and-unicode
###
XRegExp                    = require 'xregexp3'
#...........................................................................................................
### Always allow expressions like `\p{...}` to match beyond the Unicode BMP: ###
XRegExp.install 'astral'
#...........................................................................................................
### Always allow new extensions: ###
XRegExp.install 'extensibility'

# #-----------------------------------------------------------------------------------------------------------
# @_extend = ( matcher, flags, handler ) ->
#   if handler?

#-----------------------------------------------------------------------------------------------------------
extension_u =

  #.........................................................................................................
  matcher: /\\u{([0-9A-Fa-f]{1,6})}/

  #.........................................................................................................
  handler: ( ->
    pad4 = (s) ->
      s = "0" + s  while s.length < 4
      s
    dec = (hex) ->
      parseInt hex, 16
    hex = (dec) ->
      parseInt(dec, 10).toString 16
    #.........................................................................................................
    return ( match ) ->
      code = dec(match[1])
      offset = undefined
      throw new SyntaxError("invalid Unicode code point " + match[0])  if code > 0x10FFFF

      # Converting to \uNNNN avoids needing to escape the character and keep it separate
      # from preceding tokens
      return "\\u" + pad4(hex(code))  if code <= 0xFFFF
      offset = code - 0x10000
      return "\\u" + pad4(hex(0xD800 + (offset >> 10))) + "\\u" + pad4(hex(0xDC00 + (offset & 0x3FF)))
    )()

  #.........................................................................................................
  options:
    scope: 'all'
#...........................................................................................................
XRegExp.addToken extension_u.matcher, extension_u.handler, extension_u.options

#-----------------------------------------------------------------------------------------------------------
### Add the Q flag that makes the dot match all code units;
see http://www.regular-expressions.info/dot.html ###
XRegExp.addToken /\./,
  ( match, scope, flags ) ->
    dot = if /s/.test flags then '[\\s\\S]' else '.'
    return "(?:[\\ud800-\\udbff][\\udc00-\\udfff]|#{dot})"
  scope:  'default'
  flag:   'Q'

#-----------------------------------------------------------------------------------------------------------
### Add the U (ungreedy) flag from PCRE and RE2, which reverses greedy and lazy quantifiers: ###
XRegExp.addToken /([?*+]|{\d+(?:,\d*)?})(\??)/,
  ( match ) -> match[ 1 ] + if match[ 2 ] then '' else '?'
  flag: 'U'

#-----------------------------------------------------------------------------------------------------------
module.exports = XRE = ( P... ) ->
  return XRegExp P...
# #...........................................................................................................
# XRE.new = XRE.bind XRE
# throw '####################################'
# debug (require 'coffeenode-types').type_of XRE

#-----------------------------------------------------------------------------------------------------------
XRE.$esc = BNP.escape_regex.bind BNP


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
XRE.TESTS =

  #---------------------------------------------------------------------------------------------------------
  '(all): even without flag `A`, `\\p{}` expressions match astral characters': ( test ) ->
    matcher = XRegExp '\\pL'
    test.eq ( '〇𠀝x'.match matcher )[ 0 ], '𠀝'

  #---------------------------------------------------------------------------------------------------------
  '(all): even without flag `u`, `\\u{}` expressions match (astral) characters by codepoint': ( test ) ->
    test.eq ( '〇𠀝x'.match XRegExp '\\u{3007}' )[ 0 ], '〇'
    test.eq ( '〇𠀝x'.match XRegExp '\\u{2001d}' )[ 0 ], '𠀝'

  #---------------------------------------------------------------------------------------------------------
  '(`Q` flag): make dot match code points (instead of code units)': ( test ) ->
    test.eq ( '𠀝x'.match XRegExp '.', 'Q' )[ 0 ], '𠀝'

  #---------------------------------------------------------------------------------------------------------
  '(`Q` flag): dot matches code units without flag': ( test ) ->
    test.eq ( '𠀝x'.match XRegExp '.' )[ 0 ], '\ud840'

  #---------------------------------------------------------------------------------------------------------
  '(`Q` flag): respects `s` flag': ( test ) ->
    test.eq ( '𠀁x\nabc'.match XRegExp '.+'       )[ 0 ], '𠀁x'
    test.eq ( '𠀁x\nabc'.match XRegExp '.+', 'Q'  )[ 0 ], '𠀁x'
    test.eq ( '𠀁x\nabc'.match XRegExp '.+', 'Qs' )[ 0 ], '𠀁x\nabc'
    test.eq ( '𠀁x\nabc'.match XRegExp '.+', 's'  )[ 0 ], '𠀁x\nabc'










