// Generated by CoffeeScript 1.7.1
(function() {
  var BNP, TRM, alert, badge, debug, echo, help, info, log, rpr, warn, whisper, ƒ;

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = '﴾11-loop﴿';

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

  this.options = {
    'loop-keyword': 'loop',
    'break-keyword': 'break',
    INDENTATION: require('./7-indentation'),
    LINE: require('./12-line')
  };

  this.constructor = function(G, $) {
    G.break_statement = function() {
      return ƒ.or(function() {
        return $['break-keyword'];
      }).onMatch(function(match, state) {
        return G.nodes.break_statement(state);
      }).describe('break-statement');
    };
    G.loop_keyword = function() {
      return ƒ.or(function() {
        return $['loop-keyword'];
      });
    };
    G.loop_statement = function() {
      return ƒ.seq((function() {
        return $['loop-keyword'];
      }), (function() {
        return ƒ.check($.INDENTATION.$indent);
      }), (function() {
        return $.INDENTATION.$chunk;
      })).onMatch(function(match, state) {
        var chunk, keyword, loop_keyword, opener;
        loop_keyword = $['loop-keyword'];
        keyword = match[0], opener = match[1], chunk = match[2];
        if (keyword !== loop_keyword) {
          throw new Error("expected " + (rpr(loop_keyword)) + ", got " + (rpr(keyword)));
        }

        /* TAINT not correct, chunk may contain other suites */

        /* TAINT shouldn't parse here, but in INDENTATION.$chunk */
        return G.nodes.loop_statement(state, keyword, chunk);
      }).describe('loop-statement');
    };
    G.break_statement.as = {
      coffee: function(node) {
        return {
          target: 'break',
          taints: null
        };
      }
    };
    G.loop_statement.as = {
      coffee: function(node) {

        /* TAINT not correct, chunk may contain other suites */
        var chunk_result, chunk_results, line, taints, target, _i, _len, _ref;
        chunk_results = (function() {
          var _i, _len, _ref, _results;
          _ref = node['chunk'];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            line = _ref[_i];
            _results.push(ƒ.as.coffee(line));
          }
          return _results;
        })();
        taints = (_ref = ƒ.as)._collect_taints.apply(_ref, chunk_results);
        target = ['loop'];
        for (_i = 0, _len = chunk_results.length; _i < _len; _i++) {
          chunk_result = chunk_results[_i];
          target.push('  ' + chunk_result['target']);
        }
        target = target.join('\n');
        return {
          target: target,
          taints: taints
        };
      }
    };
    G.nodes.break_statement = function(state, match) {
      return ƒ["new"]._XXX_YYY_node(G.break_statement.as, state, 'break-statement', {
        'keyword': $['break-keyword']
      });
    };
    G.nodes.loop_statement = function(state, keyword, chunk) {
      return ƒ["new"]._XXX_YYY_node(G.loop_statement.as, state, 'loop-statement', {
        'keyword': keyword,
        'chunk': chunk
      });
    };
    G.tests['break: break keyword'] = function(test) {
      var keyword, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      keyword = $['break-keyword'];
      probes_and_matchers = [
        [
          "" + keyword, {
            "type": "break-statement",
            "keyword": "break"
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.break_statement.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    G.tests['loop: keyword and stage'] = function(test) {
      var keyword, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      keyword = $['loop-keyword'];
      probes_and_matchers = [
        [
          "" + keyword + "\n  foo\n  bar\n  baz", {
            "type": "loop-statement",
            "keyword": "loop",
            "chunk": [
              {
                "type": "relative-route",
                "raw": "foo",
                "value": [
                  {
                    "type": "Identifier",
                    "x-subtype": "identifier-without-sigil",
                    "name": "foo"
                  }
                ]
              }, {
                "type": "relative-route",
                "raw": "bar",
                "value": [
                  {
                    "type": "Identifier",
                    "x-subtype": "identifier-without-sigil",
                    "name": "bar"
                  }
                ]
              }, {
                "type": "relative-route",
                "raw": "baz",
                "value": [
                  {
                    "type": "Identifier",
                    "x-subtype": "identifier-without-sigil",
                    "name": "baz"
                  }
                ]
              }
            ]
          }
        ], [
          "" + keyword + "\n  foo\n  bar\n  loop\n    arc\n    bo\n    cy\n  dean\n  eps", {
            "type": "loop-statement",
            "keyword": "loop",
            "chunk": [
              {
                "type": "relative-route",
                "raw": "foo",
                "value": [
                  {
                    "type": "Identifier",
                    "x-subtype": "identifier-without-sigil",
                    "name": "foo"
                  }
                ]
              }, {
                "type": "relative-route",
                "raw": "bar",
                "value": [
                  {
                    "type": "Identifier",
                    "x-subtype": "identifier-without-sigil",
                    "name": "bar"
                  }
                ]
              }, "loop", {
                "type": "relative-route",
                "raw": "abo",
                "value": [
                  {
                    "type": "Identifier",
                    "x-subtype": "identifier-without-sigil",
                    "name": "abo"
                  }
                ]
              }, {
                "type": "relative-route",
                "raw": "dean",
                "value": [
                  {
                    "type": "Identifier",
                    "x-subtype": "identifier-without-sigil",
                    "name": "dean"
                  }
                ]
              }, {
                "type": "relative-route",
                "raw": "eps",
                "value": [
                  {
                    "type": "Identifier",
                    "x-subtype": "identifier-without-sigil",
                    "name": "eps"
                  }
                ]
              }
            ]
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        probe = $.INDENTATION.$_as_bracketed(probe);
        probe = probe.replace(/^【(.*)】$/, '$1');
        result = ƒ["new"]._delete_grammar_references(G.loop_statement.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    G.tests['loop: refuses to parse dedent'] = function(test) {
      var keyword, matcher, probe, probes_and_matchers, _i, _len, _ref, _results;
      keyword = $['loop-keyword'];
      probes_and_matchers = [["" + keyword + "\n  foo\n  bar\n  baz\nbling", {}]];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        _results.push(test.throws((function() {
          return G.loop_statement.run(probe);
        }), /Expected loop/));
      }
      return _results;
    };
    G.tests['break_statement.as.coffee: render break statement'] = function(test) {
      var matcher, node, probe, probes_and_matchers, result, translation, _i, _len, _ref, _results;
      probes_and_matchers = [["break", "break"]];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        node = G.break_statement.run(probe);
        translation = G.break_statement.as.coffee(node);
        result = ƒ.as.coffee.target(translation);
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    return G.tests['loop_statement.as.coffee: render loop statement'] = function(test) {
      var break_keyword, loop_keyword, matcher, node, probe, probes_and_matchers, result, translation, _i, _len, _ref, _results;
      loop_keyword = $['loop-keyword'];
      break_keyword = $['break-keyword'];
      probes_and_matchers = [["" + loop_keyword + "【" + break_keyword + "】", "loop\n  break"], ["" + loop_keyword + "【foo/bar: 42】", "### unable to find translator for Literal/integer ###\nloop\n  $FM[ 'scope' ][ 'foo' ][ 'bar' ] = 42"]];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        node = G.loop_statement.run(probe);
        translation = G.loop_statement.as.coffee(node);
        result = ƒ.as.coffee.target(translation);
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
  };

  ƒ["new"].consolidate(this);

}).call(this);
