


![](https://github.com/loveencounterflow/arabika/raw/master/art/arabika-logo-3.png)


# Arabika

Experiments in Parser Combinators, Modular Grammars, Domain-Specific Languages (DSLs), Indentation-Based
Grammars and Symbiotic Programming Languages (that compile to JavaScript). Written in tasty CoffeeScript.

<!-- Tower of Babel -->

## 7: Pagoda (Indentation-Parsing)

Semantic indentation is known to be 'hard to parse'; it has typically been done 'outside the
grammar', using tricks that are not normally available within classical parsing setups (think BNF, Yacc,
Bison...). To quote a [recent paper](http://michaeldadams.org/papers/layout_parsing/LayoutParsing.pdf):

> Several popular languages, such as Haskell, Python, and F#, use the indentation and layout of code as part
> of their syntax. Because context-free grammars cannot express the rules of indenta- tion, parsers for these
> languages currently use *ad hoc* techniques to handle layout. These techniques tend to be low-level and
> operational in nature and forgo the advantages of more declarative specifications like context-free
> grammars. For example, they are often coded by hand instead of being generated by a parser generator.

Arabika takes a somewhat novel approach in parsing semantic indentation.

It is known to be possible to simplify parsing significant whitespace when meaningful indentations
are turned into regular parsing tokens; this is the approach both
[Python](https://docs.python.org/2/reference/lexical_analysis.html#indentation)
and the much less popular
[parboiled parsing library](https://github.com/sirthias/parboiled/wiki/Indentation-Based-Grammars)
take.

I'm not quite sure how Python's somewhat opaque implementation works—whether it acts on strings
or whether abstract tokens are inserted into a parse tree—but parboiled
[definitely inserts Unicode code points into the source to be parsed](https://github.com/sirthias/parboiled/blob/master/parboiled-core/src/main/java/org/parboiled/support/Chars.java#L62).
In this particular case, implementors have chosen to recruit a number of lesser-used and otherwise 'illegal'
Unicode codepoints (all of which have a status of 'reserved') to function as 'anchors' within the
transformed source text:

    del_error:    u/fdea
    ins_error:    u/fdeb
    resync:       u/fdec
    resync_start: u/fded
    resync_end:   u/fdee
    resync_eoi:   u/fdef
    eoi:          u/ffff
    indent:       u/fdd0
    dedent:       u/fdd1

For a while, i have considered to use this exact same solution: pick some characters that 'should not' occur
in 'regular' source code and use that to signal indentation structure.

But then, what to do if such codepoints should inadvertently crop up in a source file? Well, i thought, you
could always escape such occurrances, do all the parsing stuff, and when the AST is there, you unescape
all those occurrances. **But**... that's **(1)** a real nuisance to do, because you have a *lot* of tiny
source snippets that are handled all across your grammar, and **(2)** *whatever* means you use to escape
regular occurrances of such characters, there *can* not be any guarantee that such escape sequences do
not already occur inside, say, a string literal (where they were intended to signify something completely
different, and were not meant to be mutated by the parser). For this reason, escaping is not an option.

Having implemented some form of indentation parsing for the *n*-th iteration this time round, it occurred
to me that i dislike the use of 'weird' codepoints to signal indentation steps. Sure, the computer won't
mind whether that's a `u/4e01` or a `u/fdd0` in your string, but i do—and certainly so when i print out
that string for diagnostic purposes. Using reserved codepoints mean your terminal output will be littered
with lots of `�`—you know, that `u/fffd` `Replacement Character` guy. This is ugly, uninformative, and also
misleading, as it could also indicate an encoding error. You'd have to translate that string before printing
it. Not good.

But then i realized i have been looking the wrong direction all the time: What if, instead of trying to hide
our tokens, as it were, we made it part of the Official Syntax? I mean, Arabika and all that Parser
Combinators stuff [has long been intended to lead to modular, dynamically redefinable grammars that
mainly function as high-level-to-high-level code translators](https://github.com/loveencounterflow/presentation-2012-04-16),
so, importantly:

**(1)** If a particular choice of meta-codepoints conflicts with what you want to use
for other purposes in your source, you can always choose to use another dialect (of indentation parsing)
to avoid that conflict.

**(2)** What we're doing here already *is* source translation, and as such it wouldn't hurt to keep
it both out of the closet and readable. In other words, if

````coffeescript
if x > 0
  x += 1
  print x
````

is the language you enjoy writing stuff in, and that gets turned into

````javascript
if (x > 0) { x += 1; print(x); }
````

wouldn't you be interested in the fact that at some point that same source surfaces as

````
【if x > 0【x += 1〓print x】】
````

or maybe as

````
↳if x > 0↳x += 1↦print x↱↱
````

**(3)** Take note that **although you're writing code in an indentation-based language, you can anytime
insert code that is bracketed instead of indented—`if x > 0【x += 1〓print x】` is a legal `if` statement
in that language!


[Indentation-sensitive syntax for Scheme](http://srfi.schemers.org/srfi-49/srfi-49.html)

