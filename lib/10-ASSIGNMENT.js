// Generated by CoffeeScript 1.7.1
(function() {
  var BNP, TRM, alert, badge, debug, echo, help, info, log, rpr, warn, whisper, ƒ,
    __slice = [].slice;

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = '﴾10-assignment﴿';

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
    'mark': ':',
    'needs-lws-before': false,
    'needs-lws-after': true,
    TEXT: require('./2-text'),
    CHR: require('./3-chr'),
    NUMBER: require('./4-number'),
    ROUTE: require('./6-route')
  };

  this.constructor = function(G, $) {
    G._TEMPORARY_expression = function() {

      /* TAINT placeholder method for a more complete version of what contitutes an expression */
      return ƒ.or((function() {
        return $.NUMBER.integer;
      }), (function() {
        return $.TEXT.literal;
      }), (function() {
        return $.ROUTE.route;
      }));
    };
    G.assignment = function() {
      var lws_after, lws_before;
      lws_before = $['needs-lws-before'] ? (function() {
        return $.CHR.ilws;
      }) : ƒ.drop('');
      lws_after = $['needs-lws-after'] ? (function() {
        return $.CHR.ilws;
      }) : ƒ.drop('');
      return ƒ.seq((function() {
        return $.ROUTE.route;
      }), lws_before, $['mark'], lws_after, (function() {
        return G._TEMPORARY_expression;
      })).onMatch(function(match, state) {
        var _ref;
        return (_ref = G.nodes).assignment.apply(_ref, [state].concat(__slice.call(match)));
      }).describe('assignment');
    };
    G.assignment.as = {
      coffee: function(node) {
        var lhs, lhs_result, mark, rhs, rhs_result, taints, target;
        lhs = node.lhs, mark = node.mark, rhs = node.rhs;
        lhs_result = ƒ.as.coffee(lhs);
        rhs_result = ƒ.as.coffee(rhs);
        target = "" + lhs_result['target'] + " = " + rhs_result['target'];
        taints = ƒ.as._collect_taints(lhs_result, rhs_result);
        return {
          target: target,
          taints: taints
        };
      }
    };
    G.nodes.assignment = function(state, lhs, mark, rhs) {
      return ƒ["new"]._XXX_YYY_node(G.assignment.as, state, 'assignment', {
        'lhs': lhs,
        'mark': mark,
        'rhs': rhs
      });
    };
    G.tests['assignment: accepts assignment with name'] = function(test) {
      var joiner, mark, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      joiner = $.ROUTE.$['crumb/joiner'];
      mark = $['mark'];
      probes_and_matchers = [
        [
          "abc" + mark + " 42", {
            "type": "assignment",
            "lhs": {
              "type": "relative-route",
              "raw": "abc",
              "value": [
                {
                  "type": "Identifier",
                  "x-subtype": "identifier-without-sigil",
                  "name": "abc"
                }
              ]
            },
            "mark": ":",
            "rhs": {
              "type": "NUMBER/integer",
              "raw": "42",
              "value": 42
            }
          }
        ], [
          "𠀁" + mark + " '42'", {
            "type": "assignment",
            "lhs": {
              "type": "relative-route",
              "raw": "𠀁",
              "value": [
                {
                  "type": "Identifier",
                  "x-subtype": "identifier-without-sigil",
                  "name": "𠀁"
                }
              ]
            },
            "mark": ":",
            "rhs": {
              "type": "TEXT/literal",
              "value": "42"
            }
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.assignment.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    G.tests['assignment: accepts assignment with route'] = function(test) {
      var joiner, mark, matcher, probe, probes_and_matchers, result, _i, _len, _ref, _results;
      joiner = $.ROUTE.$['crumb/joiner'];
      mark = $['mark'];
      probes_and_matchers = [
        [
          "yet" + joiner + "another" + joiner + "route" + mark + " 42", {
            "type": "assignment",
            "lhs": {
              "type": "relative-route",
              "raw": "yet/another/route",
              "value": [
                {
                  "type": "Identifier",
                  "x-subtype": "identifier-without-sigil",
                  "name": "yet"
                }, {
                  "type": "Identifier",
                  "x-subtype": "identifier-without-sigil",
                  "name": "another"
                }, {
                  "type": "Identifier",
                  "x-subtype": "identifier-without-sigil",
                  "name": "route"
                }
              ]
            },
            "mark": ":",
            "rhs": {
              "type": "NUMBER/integer",
              "raw": "42",
              "value": 42
            }
          }
        ], [
          "" + joiner + "chinese" + joiner + "𠀁" + mark + " '42'", {
            "type": "assignment",
            "lhs": {
              "type": "absolute-route",
              "raw": "/chinese/𠀁",
              "value": [
                {
                  "type": "Identifier",
                  "x-subtype": "identifier-without-sigil",
                  "name": "chinese"
                }, {
                  "type": "Identifier",
                  "x-subtype": "identifier-without-sigil",
                  "name": "𠀁"
                }
              ]
            },
            "mark": ":",
            "rhs": {
              "type": "TEXT/literal",
              "value": "42"
            }
          }
        ]
      ];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        result = ƒ["new"]._delete_grammar_references(G.assignment.run(probe));
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
    return G.tests['as.coffee: render assignment as CoffeeScript'] = function(test) {
      var joiner, mark, matcher, node, probe, probes_and_matchers, result, translation, _i, _len, _ref, _results;
      joiner = $.ROUTE.$['crumb/joiner'];
      mark = $['mark'];
      probes_and_matchers = [["yet" + joiner + "another" + joiner + "route" + mark + " 42", "$FM[ 'scope' ][ 'yet' ][ 'another' ][ 'route' ] = 42"], ["" + joiner + "chinese" + joiner + "𠀁" + mark + " 'some text'", "$FM[ 'global' ][ 'chinese' ][ '𠀁' ] = 'some text'"]];
      _results = [];
      for (_i = 0, _len = probes_and_matchers.length; _i < _len; _i++) {
        _ref = probes_and_matchers[_i], probe = _ref[0], matcher = _ref[1];
        node = G.assignment.run(probe);
        translation = G.assignment.as.coffee(node);
        result = ƒ.as.coffee.target(translation);
        _results.push(test.eq(result, matcher));
      }
      return _results;
    };
  };

  ƒ["new"].consolidate(this);

}).call(this);