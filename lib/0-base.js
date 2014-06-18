// Generated by CoffeeScript 1.7.1
(function() {
  var $new, CHR, NUMBER, ROUTE, TEXT, TRM, TYPES, XRE, alert, badge, debug, echo, help, info, log, rpr, warn, whisper, ƒ, _G;

  TYPES = require('coffeenode-types');

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = '﴾1-base﴿';

  log = TRM.get_logger('plain', badge);

  info = TRM.get_logger('info', badge);

  whisper = TRM.get_logger('whisper', badge);

  alert = TRM.get_logger('alert', badge);

  debug = TRM.get_logger('debug', badge);

  warn = TRM.get_logger('warn', badge);

  help = TRM.get_logger('help', badge);

  echo = TRM.echo.bind(TRM);

  ƒ = require('flowmatic');

  this.$new = ƒ["new"]["new"](this);

  $new = ƒ["new"];

  TEXT = require('./2-text');

  CHR = require('./3-chr');

  NUMBER = require('./4-number');

  ROUTE = require('./6-route');

  XRE = require('./9-xre');

  this.$ = {
    'use-keyword': 'use'
  };


  /* TAINT `ƒ.or` is an expedient here */

  this.$_use_keyword = ƒ.or((function(_this) {
    return function() {
      return ƒ.string(_this.$['use-keyword']);
    };
  })(this));

  this.use_argument = ƒ.or(((function(_this) {
    return function() {
      return ROUTE.symbol;
    };
  })(this)), ((function(_this) {
    return function() {
      return NUMBER.integer;
    };
  })(this)), ((function(_this) {
    return function() {
      return TEXT.literal;
    };
  })(this)));

  this.use_statement = (ƒ.seq(((function(_this) {
    return function() {
      return _this.$_use_keyword;
    };
  })(this)), ((function(_this) {
    return function() {
      return CHR.ilws;
    };
  })(this)), ((function(_this) {
    return function() {
      return _this.use_argument;
    };
  })(this)))).onMatch((function(_this) {
    return function(match, state) {
      return _this.nodes.use_statement(state, match[0], match[1]);
    };
  })(this));

  this.nodes = {};

  _G = this;

  this.nodes.use_statement = function(state, keyword, argument) {
    return ƒ["new"]._XXX_YYY_node(_G.use_statement.as, state, 'BASE/use-statement', {
      keyword: keyword,
      argument: argument
    });
  };

  this.$TESTS = {
    'use_argument: accepts symbols': function(test) {
      var $, G, mark, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      G = this;
      $ = G.$;
      mark = ROUTE.$['symbol/mark'];
      probes_and_matchers = [
        [
          "" + mark + "x", {
            "type": "Literal",
            "x-subtype": "symbol",
            "x-mark": ":",
            "raw": ":x",
            "value": "x"
          }
        ], [
          "" + mark + "foo", {
            "type": "Literal",
            "x-subtype": "symbol",
            "x-mark": ":",
            "raw": ":foo",
            "value": "foo"
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.use_argument.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    },
    'use_argument: accepts integer': function(test) {
      var $, G, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      G = this;
      $ = G.$;
      probes_and_matchers = [
        [
          "12349876", {
            type: 'NUMBER/integer',
            raw: '12349876',
            value: 12349876
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.use_argument.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    },
    'use_argument: accepts strings': function(test) {
      var $, G, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      G = this;
      $ = G.$;
      probes_and_matchers = [
        [
          "'some text'", {
            "type": "TEXT/literal",
            "value": "some text"
          }
        ], [
          '"other text"', {
            "type": "TEXT/literal",
            "value": "other text"
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.use_argument.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    },
    'use_statement: accepts symbols, digits, strings': function(test) {
      var $, G, keyword, mark, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      G = this;
      $ = G.$;
      mark = ROUTE.$['symbol/mark'];
      keyword = G.$['use-keyword'];
      probes_and_matchers = [
        [
          "use " + mark + "x", {
            "type": "BASE/use-statement",
            "keyword": "use",
            "argument": {
              "type": "Literal",
              "x-subtype": "symbol",
              "x-mark": ":",
              "raw": ":x",
              "value": "x"
            }
          }
        ], [
          "use " + mark + "foo", {
            "type": "BASE/use-statement",
            "keyword": "use",
            "argument": {
              "type": "Literal",
              "x-subtype": "symbol",
              "x-mark": ":",
              "raw": ":foo",
              "value": "foo"
            }
          }
        ], [
          "use 12349876", {
            "type": "BASE/use-statement",
            "keyword": "use",
            "argument": {
              "type": "NUMBER/integer",
              "raw": "12349876",
              "value": 12349876
            }
          }
        ], [
          "use 'some text'", {
            "type": "BASE/use-statement",
            "keyword": "use",
            "argument": {
              "type": "TEXT/literal",
              "value": "some text"
            }
          }
        ], [
          'use "other text"', {
            "type": "BASE/use-statement",
            "keyword": "use",
            "argument": {
              "type": "TEXT/literal",
              "value": "other text"
            }
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.use_statement.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    }
  };

}).call(this);