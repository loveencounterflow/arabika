

module.exports =
  escodegen:
    format:
      indent:
        # Indent string. Default is 4 spaces (' ').
        style:                    '  '
        # Base indent level. Default is 0.
        base:                     0
        # Adjust the indentation of multiline comments to keep asterisks vertically aligned. Default is false.
        adjustMultilineComment:   yes
      # New line string. Default is '\n'.
      newline:            '\n'

      # White space string. Default is standard ' ' (\x20).
      space:              ' '
      # Enforce JSON format of numeric and string literals. This option takes precedence over
      # option.format.hexadecimal and option.format.quotes. Default is false.
      json:               no
      # Try to generate shorter numeric literals than toString() (9.8.1). Default is false.
      renumber:           no
      # Generate hexadecimal a numeric literal if it is shorter than its equivalents. Requires
      # option.format.renumber. Default is false.
      hexadecimal:        no
      # Delimiter to use for string literals. Accepted values are: 'single', 'double', and 'auto'.
      # When 'auto' is specified, escodegen selects a delimiter that results in a shorter literal. Default
      # is 'single'.
      quotes:             'auto'
      # Escape as few characters in string literals as necessary. Default is false.
      escapeless:         no
      # Do not include superfluous whitespace characters and line terminators. Default is false.
      compact:            no
      # Preserve parentheses in new expressions that have no arguments. Default is true.
      parentheses:        yes
      # Preserve semicolons at the end of blocks and programs. Default is true.
      semicolons:         yes
      # Mozilla Parser API compatible parse function. If it is provided, generator tries to use the 'raw'
      # representation. See esprima raw information. Default is null.
      parse:              null
      # If comments are attached to AST, escodegen is going to emit comments to output code. Default is false.
      comment:            no
      # sourceMap is the source maps's source filename, that's a name that will show up in the browser
      # debugger for the generated source (if source-maps is enabled). If a non-empty string value is
      # provided, generate a source map. If sourceMapWithCode is true generator returns output hash, where
      # output.map is a source-map representation, which can be serialized as output.map.toString().
      # output.code is a string with generated JS code (note that it's not going to have
      # //@ sourceMappingURL comment in it). Optionally option.sourceContent string can be passed (which
      # represents original source of the file, for example it could be a source of coffeescript from which
      # JS is being generated), if provided generated source map will have original source embedded in it.
      # Optionally option.sourceMapRoot can be provided, in which case option.sourceMap will be treated as
      # relative to it. For more information about source map itself, see source map library document, V3
      # draft and HTML5Rocks introduction. Default is undefined. sourceMapRoot is the source root for the
      # source map (see the Mozilla documentation). If sourceMapWithCode is truthy, an object is returned from
      # generate() of the form: { code: .. , map: .. }.
      sourceMap:          undefined
      sourceMapRoot:      undefined
      sourceMapWithCode:  undefined
      sourceContent:      undefined
      # Recognize DirectiveStatement and distinguish it from ExpressionStatement
      directive:          no
      verbatim:           'x-verbatim'


