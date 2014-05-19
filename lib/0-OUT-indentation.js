// Generated by CoffeeScript 1.6.3
(function() {
  var BNP, NEW, TRM, XRE, alert, badge, debug, echo, help, info, log, rainbow, rpr, warn, whisper, π,
    __slice = [].slice;

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = '﴾7-indentation﴿';

  log = TRM.get_logger('plain', badge);

  info = TRM.get_logger('info', badge);

  whisper = TRM.get_logger('whisper', badge);

  alert = TRM.get_logger('alert', badge);

  debug = TRM.get_logger('debug', badge);

  warn = TRM.get_logger('warn', badge);

  help = TRM.get_logger('help', badge);

  echo = TRM.echo.bind(TRM);

  rainbow = TRM.rainbow.bind(TRM);

  π = require('coffeenode-packrattle');

  BNP = require('coffeenode-bitsnpieces');

  NEW = require('./NEW');

  XRE = require('./9-xre');

  this.$ = {

    /* TAINT dot suspected to match incorrectly? */

    /* TAINT assumes newlines are equal to `\n` */
    'leading-ws': XRE('(?:^|\\n)(\\p{Space_Separator}*)(.*)(?=\\n|$)'),
    'opener': '⟦',
    'connector': '∿',
    'closer': '⟧'
  };


  /* TAINT `π.alt` is an expedient here */


  /* TAINT no memoizing */

  this.$_metachr = π.alt((function(_this) {
    return function() {
      return π.regex(XRE('[' + (XRE.$_esc(_this.$['opener'] + _this.$['connector'] + _this.$['closer'])) + ']'));
    };
  })(this));


  /* TAINT `π.alt` is an expedient here */


  /* TAINT no memoizing */

  this.$_nometachrs = π.alt((function(_this) {
    return function() {
      return π.regex(XRE('[^' + (XRE.$_esc(_this.$['opener'] + _this.$['connector'] + _this.$['closer'])) + ']*'));
    };
  })(this));


  /* TAINT `π.alt` is an expedient here */

  this.$_indentation = (π.repeat(' ')).onMatch(function(match) {
    return match.join('');
  });


  /* `/.* /` instead of `/.+/` makes the rule fail: */

  this.$_raw_indented_material_line = (π.seq(this.$_indentation, /.+/, π.optional('\n'))).onMatch(function(match) {
    return [match[0], match[1][0], match[2]];
  });


  /* TAINT simplified version of LWS */

  this.$_raw_blank_line = (π.regex(/([\x20\t]+)(\n|$)/)).onMatch(function(match) {
    return ['', match[1], match[2]];
  });


  /* TAINT simplified version of LWS */

  this.$_raw_line = π.alt(this.$_raw_blank_line, this.$_raw_indented_material_line);

  this.$_raw_lines = π.repeat(this.$_raw_line);


  /* TAINT must escape meta-chrs */


  /* TAINT must delay to allow for late changes */

  this.phrase = (π.regex(RegExp("[^" + this.$['opener'] + this.$['connector'] + this.$['closer'] + "]+"))).onMatch(function(match) {
    var R;
    R = ['phrase', match[0]];
    whisper(R);
    return R;
  }).describe("one or more non-meta characters");

  this.phrases = (π.repeatSeparated(this.phrase, /\|/)).onMatch(function(match) {
    return ['phrases'].concat(__slice.call(match));
  });

  this.bracketed = (π.seq('(', π.repeat((function(_this) {
    return function() {
      return _this.expression;
    };
  })(this)), ')')).onMatch(function(match) {
    var R;
    R = ['bracketed', match[0], match[1], match[2]];
    whisper(R);
    return R;
  });

  this.expression = π.alt(this.bracketed, this.phrases);

  this._ = function() {
    var R, base_level, chrs_per_level, current_level, d, dents, ending, indentation, level, line, line_idx, lines, material, source, _i, _len;
    d = this.$['leading-ws'];
    debug(''.match(d));
    debug(' '.match(d));
    debug('  '.match(d));
    debug('\n  '.match(d));
    debug('abc'.match(d));
    debug('\n    abc'.match(d));
    debug();
    debug(rpr(''.split(d)));
    debug(rpr(' '.split(d)));
    debug(rpr('  '.split(d)));
    debug(rpr('\n  '.split(d)));
    debug(rpr('abc'.split(d)));
    source = "f = ->\n  for x in xs\n    while x > 0\n      x -= 1\n      log x\n      g x\n  log 'ok'\n  log 'over'";
    debug(rpr(this.$_raw_indented_material_line.run('  abc')));
    debug(rpr(this.$_raw_indented_material_line.run('  abc\n')));
    lines = this.$_raw_lines.run(source);
    debug(lines);

    /* TAINT we should probably wait with complaints about indentation until later when we can rule out the
    existance of special constructs such as triple-quoted string literals, comments and the like; also, `!use`
    statements may alter the semantics of indentations
     */
    R = [];
    chrs_per_level = 2;
    base_level = -chrs_per_level;
    current_level = base_level;
    for (line_idx = _i = 0, _len = lines.length; _i < _len; line_idx = ++_i) {
      line = lines[line_idx];
      indentation = line[0], material = line[1], ending = line[2];
      level = indentation.length;
      if (level > current_level) {
        dents = [];
        while (level > current_level) {
          current_level += chrs_per_level;
          dents.push(this.$['opener']);
        }
        R.push(dents.join(''));
      } else if (current_level > level) {
        dents = [];
        while (current_level > level) {
          current_level -= chrs_per_level;
          dents.push(this.$['closer']);
        }
        R.push(dents.join(''));
      } else {
        R.push(this.$['connector']);
      }
      R.push(material);
    }

    /* TAINT code repetition */
    if (current_level > base_level) {
      dents = [];
      while (current_level > base_level) {
        current_level -= chrs_per_level;
        dents.push(this.$['closer']);
      }
      R.push(dents.join(''));
    }
    R = R.join('');

    /* TAINT must keep line numbers; also applies to indentations */
    return debug('\n' + R);
  };

  if (module.parent == null) {
    this._();
  }

}).call(this);