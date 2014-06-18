// Generated by CoffeeScript 1.7.1
(function() {
  var BNP, TRM, XRE, alert, badge, debug, echo, help, info, log, rpr, warn, whisper, ƒ;

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = '﴾6-route﴿';

  log = TRM.get_logger('plain', badge);

  info = TRM.get_logger('info', badge);

  whisper = TRM.get_logger('whisper', badge);

  alert = TRM.get_logger('alert', badge);

  debug = TRM.get_logger('debug', badge);

  warn = TRM.get_logger('warn', badge);

  help = TRM.get_logger('help', badge);

  echo = TRM.echo.bind(TRM);

  ƒ = require('flowmatic');

  BNP = require('coffeenode-bitsnpieces');


  /* TAINT XRE will become a FlowMatic helper module */

  XRE = require('./XRE');

  this.options = {

    /* Names: */

    /* Leading and trailing characters in names (excluding sigils): */
    'identifier/first-chr': XRE('\\p{L}', 'A'),
    'identifier/trailing-chrs': XRE('(?:-|\\p{L}|\\d)*', 'A'),

    /* Character used to form URL-like routes out of crumbs: */
    'crumb/joiner': '/',
    'crumb/this-scope': '.',
    'crumb/parent-scope': '..',

    /* Sigils: */

    /* Sigils may start and classify simple names: */
    'sigils': {
      '~': 'system',
      '.': 'hidden',
      '_': 'private',
      '%': 'cached',
      '!': 'attention'
    },

    /* Marks are like sigils, but with slightly different semantics. */
    'symbol/mark': ':'
  };

  this.constructor = function(G, $) {
    G.$identifier_first_chr = function() {
      var R;
      R = ƒ.regex($['identifier/first-chr']);
      R = R.onMatch(function(match) {
        return match[0];
      });
      R = R.describe('first character of name');
      return R;
    };
    G.$identifier_trailing_chrs = function() {
      var R;
      R = ƒ.regex($['identifier/trailing-chrs']);
      R = R.onMatch(function(match) {
        return match[0];
      });
      R = R.describe('trailing characters of name');
      return R;
    };
    G.$sigil = function() {
      var R, key, sigils;
      sigils = ((function() {
        var _results;
        _results = [];
        for (key in $['sigils']) {
          _results.push(XRE.$esc(key));
        }
        return _results;
      })()).join('');
      R = ƒ.regex(new RegExp("[" + sigils + "]"));
      R = R.onMatch(function(match, state) {
        return match[0];
      });
      R = R.describe('sigil');
      return R;
    };
    G.identifier_with_sigil = function() {
      var R;
      R = ƒ.seq(G.$sigil, (function() {
        return G.$identifier_first_chr;
      }), (function() {
        return G.$identifier_trailing_chrs;
      }));
      R = R.onMatch(function(match, state) {
        return G.nodes.identifier_with_sigil(state, match[0], match[1] + match[2]);
      });
      R = R.describe('identifier-with-sigil');
      return R;
    };
    G.identifier_without_sigil = function() {
      var R;
      R = ƒ.seq((function() {
        return G.$identifier_first_chr;
      }), (function() {
        return G.$identifier_trailing_chrs;
      }));
      R = R.onMatch(function(match, state) {
        return G.nodes.identifier_without_sigil(state, match[0] + match[1]);
      });
      R = R.describe('name-without-sigil');
      return R;
    };
    G.identifier = function() {
      var R;
      R = ƒ.or((function() {
        return G.identifier_with_sigil;
      }), (function() {
        return G.identifier_without_sigil;
      }));
      R = R.describe('identifier');
      return R;
    };
    G.relative_route = function() {
      var R;
      R = ƒ.repeatSeparated((function() {
        return G.identifier;
      }), $['crumb/joiner']);
      R = R.onMatch(function(match, state) {
        var identifier, raw;
        raw = ((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = match.length; _i < _len; _i++) {
            identifier = match[_i];
            _results.push(identifier['name']);
          }
          return _results;
        })()).join($['crumb/joiner']);
        return G.nodes.relative_route(state, raw, match);
      });
      R = R.describe('relative-route');
      return R;
    };
    G.absolute_route = function() {
      var R;
      R = ƒ.seq($['crumb/joiner'], (function() {
        return G.relative_route;
      }));
      R = R.onMatch(function(match, state) {
        var route, slash;
        slash = match[0], route = match[1];
        route['raw'] = $['crumb/joiner'] + route['raw'];
        route['type'] = 'absolute-route';
        return route;
      });
      R = R.describe('absolute-route');
      return R;
    };
    G.route = function() {
      var R;
      R = ƒ.or((function() {
        return G.absolute_route;
      }), (function() {
        return G.relative_route;
      }));
      R = R.describe('route');
      return R;
    };
    G.route.as = {
      coffee: function(node) {
        var crumb, crumb_subtype, crumb_type, crumbs, idx, name, names, root_name, target, type, _i, _len;
        type = node['type'];
        root_name = type === 'relative-route' ? 'scope' : 'global';
        crumbs = node['value'];
        names = [];
        for (idx = _i = 0, _len = crumbs.length; _i < _len; idx = ++_i) {
          crumb = crumbs[idx];
          crumb_type = crumb['type'];
          crumb_subtype = crumb['x-subtype'];
          if (crumb_type !== 'Identifier') {
            throw new Error("unknown crumb type " + (rpr(crumb_type)));
          }
          names.push(crumb['name']);
        }
        names = ((function() {
          var _j, _len1, _results;
          _results = [];
          for (_j = 0, _len1 = names.length; _j < _len1; _j++) {
            name = names[_j];
            _results.push("[ " + (rpr(name)) + " ]");
          }
          return _results;
        })()).join('');
        target = "$FM[ " + (rpr(root_name)) + " ]" + names;
        return {
          target: target
        };
      }
    };
    G.symbol = function() {
      var R;
      R = ƒ.seq($['symbol/mark'], (function() {
        return G.identifier;
      }));
      R = R.onMatch(function(match, state) {
        var identifier, mark;
        mark = match[0];
        identifier = match[1]['name'];
        return G.nodes.symbol(state, mark, mark + identifier, identifier);
      });
      return R;
    };
    G.nodes.symbol = function(state, mark, raw, value) {
      var R;
      R = ƒ["new"]._XXX_node(G, 'Literal', 'symbol');
      R['x-mark'] = mark;
      R['raw'] = raw;
      R['value'] = value;
      return R;
    };
    G.nodes.relative_route = function(state, raw, value) {
      return ƒ["new"]._XXX_YYY_node(G.route.as, state, 'relative-route', {
        'raw': raw,
        'value': value
      });
    };
    G.nodes.identifier_with_sigil = function(state, sigil, name) {
      var R;
      R = ƒ["new"]._XXX_node(G, 'Identifier', 'identifier-with-sigil');
      R['x-sigil'] = sigil;
      R['name'] = sigil + name;
      return R;
    };
    G.nodes.identifier_without_sigil = function(state, name) {
      var R;
      R = ƒ["new"]._XXX_node(G, 'Identifier', 'identifier-without-sigil');
      R['name'] = name;
      return R;
    };
    G.tests['$identifier_first_chr: matches first character of names'] = function(test) {
      var probe, probes, result, _i, _len, _results;
      probes = ['a', 'A', '𠀁'];
      _results = [];
      for (_i = 0, _len = probes.length; _i < _len; _i++) {
        probe = probes[_i];
        result = G.$identifier_first_chr.run(probe);
        _results.push(test.eq(result, probe));
      }
      return _results;
    };
    G.tests['$identifier_trailing_chrs: matches trailing characters of names'] = function(test) {
      var probe, probes, result, _i, _len, _results;
      probes = ['abc', 'abc-def', 'abc-def-45'];
      _results = [];
      for (_i = 0, _len = probes.length; _i < _len; _i++) {
        probe = probes[_i];
        result = G.$identifier_trailing_chrs.run(probe);
        _results.push(test.eq(result, probe));
      }
      return _results;
    };
    G.tests['identifier: matches identifiers'] = function(test) {
      var matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      probes_and_matchers = [
        [
          'n', {
            "type": "Identifier",
            "x-subtype": "identifier-without-sigil",
            "name": "n"
          }
        ], [
          'n0', {
            "type": "Identifier",
            "x-subtype": "identifier-without-sigil",
            "name": "n0"
          }
        ], [
          'readable-names', {
            "type": "Identifier",
            "x-subtype": "identifier-without-sigil",
            "name": "readable-names"
          }
        ], [
          'foo-32', {
            "type": "Identifier",
            "x-subtype": "identifier-without-sigil",
            "name": "foo-32"
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.identifier.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    G.tests['identifier: matches identifiers with sigils'] = function(test) {
      var matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      probes_and_matchers = [
        [
          '~n', {
            "type": "Identifier",
            "x-subtype": "identifier-with-sigil",
            "x-sigil": "~",
            "name": "~n"
          }
        ], [
          '.n0', {
            "type": "Identifier",
            "x-subtype": "identifier-with-sigil",
            "x-sigil": ".",
            "name": ".n0"
          }
        ], [
          '_readable-names', {
            "type": "Identifier",
            "x-subtype": "identifier-with-sigil",
            "x-sigil": "_",
            "name": "_readable-names"
          }
        ], [
          '%foo-32', {
            "type": "Identifier",
            "x-subtype": "identifier-with-sigil",
            "x-sigil": "%",
            "name": "%foo-32"
          }
        ], [
          '!foo-32', {
            "type": "Identifier",
            "x-subtype": "identifier-with-sigil",
            "x-sigil": "!",
            "name": "!foo-32"
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.identifier.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    G.tests['identifier: rejects non-identifiers'] = function(test) {
      var probe, probes, _i, _len, _results;
      probes = ['034', '-/-', '()', '؟?'];
      _results = [];
      for (_i = 0, _len = probes.length; _i < _len; _i++) {
        probe = probes[_i];
        _results.push(test.throws(((function(_this) {
          return function() {
            return G.identifier.run(probe);
          };
        })(this)), /Expected/));
      }
      return _results;
    };
    G.tests['$[ "symbol/mark" ]: is a single character'] = function(test) {

      /* TAINT test will fail for Unicode 32bit code points */
      var TYPES;
      TYPES = require('coffeenode-types');
      test.ok(TYPES.isa_text($['symbol/mark']));
      return test.ok($['symbol/mark'].length === 1);
    };
    G.tests['symbol: accepts sequences of symbol/mark, name chrs'] = function(test) {
      var mark, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      mark = $['symbol/mark'];
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
        ], [
          "" + mark + "Supercalifragilisticexpialidocious", {
            "type": "Literal",
            "x-subtype": "symbol",
            "x-mark": ":",
            "raw": ":Supercalifragilisticexpialidocious",
            "value": "Supercalifragilisticexpialidocious"
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.symbol.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    G.tests['symbol: rejects names with whitespace'] = function(test) {
      var mark, probe, probes, _i, _len, _results;
      mark = $['symbol/mark'];
      probes = ["" + mark + "xxx xxx", "" + mark + "foo\tbar", "" + mark + "Super/cali/fragilistic/expialidocious"];
      _results = [];
      for (_i = 0, _len = probes.length; _i < _len; _i++) {
        probe = probes[_i];
        _results.push(test.throws((function() {
          return G.symbol.run(probe);
        }), /Expected/));
      }
      return _results;
    };
    G.tests['route: accepts single name'] = function(test) {

      /* TAINT test will fail for Unicode 32bit code points */
      var matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      probes_and_matchers = [
        [
          "abc", {
            "type": "relative-route",
            "raw": "abc",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "abc"
              }
            ]
          }
        ], [
          "!國畫很美", {
            "type": "relative-route",
            "raw": "!國畫很美",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-with-sigil",
                "x-sigil": "!",
                "name": "!國畫很美"
              }
            ]
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.route.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    G.tests['route: accepts crumbs separated by crumb joiners'] = function(test) {

      /* TAINT test will fail for Unicode 32bit code points */
      var joiner, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      joiner = $['crumb/joiner'];
      probes_and_matchers = [
        [
          "abc" + joiner + "def", {
            "type": "relative-route",
            "raw": "abc/def",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "abc"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "def"
              }
            ]
          }
        ], [
          "foo" + joiner + "bar" + joiner + "baz" + joiner + "gnu" + joiner + "foo" + joiner + "due", {
            "type": "relative-route",
            "raw": "foo/bar/baz/gnu/foo/due",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "foo"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "bar"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "baz"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "gnu"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "foo"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "due"
              }
            ]
          }
        ], [
          "foo" + joiner + "bar", {
            "type": "relative-route",
            "raw": "foo/bar",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "foo"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "bar"
              }
            ]
          }
        ], [
          "Super" + joiner + "cali" + joiner + "fragilistic" + joiner + "expialidocious", {
            "type": "relative-route",
            "raw": "Super/cali/fragilistic/expialidocious",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "Super"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "cali"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "fragilistic"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "expialidocious"
              }
            ]
          }
        ], [
          "" + joiner + "abc" + joiner + "def", {
            "type": "absolute-route",
            "raw": "/abc/def",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "abc"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "def"
              }
            ]
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.route.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    G.tests['route: accepts leading slash'] = function(test) {

      /* TAINT test will fail for Unicode 32bit code points */
      var joiner, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      joiner = $['crumb/joiner'];
      probes_and_matchers = [
        [
          "" + joiner + "abc" + joiner + "def", {
            "type": "absolute-route",
            "raw": "/abc/def",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "abc"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "def"
              }
            ]
          }
        ], [
          "" + joiner + "foo" + joiner + "bar", {
            "type": "absolute-route",
            "raw": "/foo/bar",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "foo"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "bar"
              }
            ]
          }
        ], [
          "" + joiner + "Super" + joiner + "cali" + joiner + "fragilistic" + joiner + "expialidocious", {
            "type": "absolute-route",
            "raw": "/Super/cali/fragilistic/expialidocious",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "Super"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "cali"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "fragilistic"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "expialidocious"
              }
            ]
          }
        ], [
          "" + joiner + "abc" + joiner + "def", {
            "type": "absolute-route",
            "raw": "/abc/def",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "abc"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "def"
              }
            ]
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.route.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    G.tests['route: accepts crumbs with sigils'] = function(test) {

      /* TAINT test will fail for Unicode 32bit code points */
      var joiner, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      joiner = $['crumb/joiner'];
      probes_and_matchers = [
        [
          "!abc" + joiner + "def", {
            "type": "relative-route",
            "raw": "!abc/def",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-with-sigil",
                "x-sigil": "!",
                "name": "!abc"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "def"
              }
            ]
          }
        ], [
          "foo" + joiner + "%bar", {
            "type": "relative-route",
            "raw": "foo/%bar",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "foo"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-with-sigil",
                "x-sigil": "%",
                "name": "%bar"
              }
            ]
          }
        ], [
          "Super" + joiner + "_cali" + joiner + "fragilistic" + joiner + "expialidocious", {
            "type": "relative-route",
            "raw": "Super/_cali/fragilistic/expialidocious",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "Super"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-with-sigil",
                "x-sigil": "_",
                "name": "_cali"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "fragilistic"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "expialidocious"
              }
            ]
          }
        ], [
          "" + joiner + "abc" + joiner + "~def", {
            "type": "absolute-route",
            "raw": "/abc/~def",
            "value": [
              {
                "type": "Identifier",
                "x-subtype": "identifier-without-sigil",
                "name": "abc"
              }, {
                "type": "Identifier",
                "x-subtype": "identifier-with-sigil",
                "x-sigil": "~",
                "name": "~def"
              }
            ]
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.route.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    return G.tests['as.coffee: render relative route as CoffeeScript'] = function(test) {
      var matcher, node, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      probes_and_matchers = [["foo/bar/!baz", "$FM[ 'scope' ][ 'foo' ][ 'bar' ][ '!baz' ]"]];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        node = G.route.run(probe);
        result = (G.route.as.coffee(node))['target'];
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
  };

  ƒ["new"].consolidate(this);

}).call(this);