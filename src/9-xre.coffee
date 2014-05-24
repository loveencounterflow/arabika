

###

[Whitespace in Unicode 6.3](http://en.wikipedia.org/wiki/Whitespace_character):

Linear:

  U+0009  HT, Horizontal Tab
  U+0020  space
  U+00A0  no-break space
  U+1680  ogham space mark
  U+2000  en quad
  U+2001  em quad
  U+2002  en space
  U+2003  em space
  U+2004  three-per-em space
  U+2005  four-per-em space
  U+2006  six-per-em space
  U+2007  figure space
  U+2008  punctuation space
  U+2009  thin space
  U+200A  hair space
  U+202F  narrow no-break space
  U+205F  medium mathematical space
  U+3000  ideographic space

Line breaking:
  U+000A  LF, Line feed
  U+000B  VT, Vertical Tab
  U+000C  FF, Form feed
  U+000D  CR, Carriage return
  U+0085  NEL, Next line
  U+2028  line separator
  U+2029  paragraph separator

###


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

#-----------------------------------------------------------------------------------------------------------
XRegExp.addToken /\\u{([0-9A-Fa-f]{1,6})}/,
  #.........................................................................................................
  (->
    #.......................................................................................................
    pad = ( literal ) ->
      '0' + literal while literal.length < 4
      return literal
    #.......................................................................................................
    as_dec = ( literal ) -> parseInt literal, 16
    as_hex = (       n ) -> ( parseInt  n, 10 ).toString 16
    #.......................................................................................................
    return ( match, scope, flags ) ->
      cid = as_dec match[ 1 ]
      throw new SyntaxError "invalid Unicode code point #{match[ 0 ]}" if cid > 0x10FFFF
      ### Converting to \uNNNN avoids needing to escape the character and keep it separate
      from preceding tokens: ###
      return "\\u#{pad as_hex cid}" if cid <= 0xFFFF
      offset          = cid - 0x10000
      lead_surrogate  = pad as_hex 0xD800 + ( offset >> 10 )
      trail_surrogate = pad as_hex 0xDC00 + ( offset & 0x3FF )
      return "\\u#{lead_surrogate}\\u#{trail_surrogate}"
  )()
  scope:  'all'
  # flag:   'Q'

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
### Add the \L escape that matches all linear whitespace: ###
XRegExp.addToken /\\L/,
  ( match, scope, flags ) ->
    return "[\\u0009\\u0020\\u00A0\\u1680\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2007\\u2008\\u2009\\u200A\\u202F\\u205F\\u3000]"
  scope:  'all'


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
XRE.$TESTS =
#-----------------------------------------------------------------------------------------------------------

  #---------------------------------------------------------------------------------------------------------
  '(all): even without flag `A`, `\\p{}` expressions match astral characters': ( test ) ->
    matcher = XRegExp '\\pL'
    test.eq ( '〇𠀝x'.match matcher )[ 0 ], '𠀝'

  #---------------------------------------------------------------------------------------------------------
  '(all): even without flag `u`, `\\u{}` expressions match (astral) characters by codepoint': ( test ) ->
    test.eq ( '〇𠀝x'.match XRegExp '\\u{3007}' )[ 0 ], '〇'
    test.eq ( '〇𠀝x'.match XRegExp '\\u{2001d}' )[ 0 ], '𠀝'

  #---------------------------------------------------------------------------------------------------------
  '(all): even without flag `u`, `\\u{}` is rejected when argument is not a hexadecimal digit': ( test ) ->
    test.throws ( -> '〇𠀝x'.match XRegExp '\\u{}' ), /Invalid/
    test.throws ( -> '〇𠀝x'.match XRegExp '\\u{xxx}' ), /Invalid/

  #---------------------------------------------------------------------------------------------------------
  '(all): even without flag `u`, `\\u{}` is rejected when argument is beyond limits': ( test ) ->
    test.throws ( -> '〇𠀝x'.match XRegExp '\\u{201234}' ), /invalid Unicode code point/

  #---------------------------------------------------------------------------------------------------------
  '(all): `\\L` matches linear whitespace': ( test ) ->
    test.ok ( XRegExp '\\L' ).test ' '
    test.ok ( XRegExp '\\L' ).test '\t'
    test.ok ( XRegExp '\\L' ).test '\u3000'

  #---------------------------------------------------------------------------------------------------------
  '(all): `\\L+` matches stretches of linear whitespace': ( test ) ->
    test.eq (      ' \t '.match XRegExp '\\L+' )[ 0 ],      ' \t '
    test.eq (  '\t\t\t\t'.match XRegExp '\\L+' )[ 0 ],  '\t\t\t\t'
    test.eq ( '\u3000 \t'.match XRegExp '\\L+' )[ 0 ], '\u3000 \t'

  #---------------------------------------------------------------------------------------------------------
  '(all): `\\L` does not match other characters than linear whitespace': ( test ) ->
    test.ok not ( XRegExp '\\L' ).test 'x'
    test.ok not ( XRegExp '\\L' ).test '\n'
    test.ok not ( XRegExp '\\L' ).test '\r'

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










