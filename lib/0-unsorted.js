// Generated by CoffeeScript 1.6.3
(function() {
  var NEW, NUMBER, TRM, WS, alert, badge, debug, echo, help, info, log, rainbow, rpr, warn, whisper, π,
    __slice = [].slice;

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = '﴾777﴿';

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

  WS = require('./3-ws');

  NUMBER = require('./4-number');

  NEW = require('./NEW');

  this._operator_on_match = function(match) {
    return ['operator', match[0]];
  };

  this._operation_on_match = function(match) {
    var left, operator, right;
    left = match[0];
    operator = match[1][1];
    right = match[2];
    return NEW.binary_expression(operator, left, right);
  };

  this.plus = (π.string('+')).onMatch(this._operator_on_match);

  this.times = (π.string('*')).onMatch(this._operator_on_match);


  /*
  possible:
    addition    = π.seq ( -> expression ), ( -> lws ), ( -> plus ), ( -> lws ), ( -> expression )
  not possible:
    addition    = π.seq expression, lws, plus, lws, expression
   */

  this.addition = (π.seq(((function(_this) {
    return function() {
      return _this.expression;
    };
  })(this)), WS.ilws, this.plus, WS.ilws, ((function(_this) {
    return function() {
      return _this.expression;
    };
  })(this)))).onMatch(this._operation_on_match.bind(this));

  this.multiplication = (π.seq(((function(_this) {
    return function() {
      return _this.expression;
    };
  })(this)), WS.ilws, this.times, WS.ilws, ((function(_this) {
    return function() {
      return _this.expression;
    };
  })(this)))).onMatch(this._operation_on_match.bind(this));

  this.sum = π.alt(this.addition, NUMBER.digits);

  this.product = π.alt(this.multiplication, NUMBER.digits);

  this.expression = (π.alt(this.sum, this.product)).onMatch((function(_this) {
    return function(match) {
      return ['expression', match];
    };
  })(this));

  this.list_kernel = π.repeatSeparated(((function(_this) {
    return function() {
      return _this.expression;
    };
  })(this)), π([',', WS.ilws]));

  this.empty_list = (π.seq('[', π.optional(WS.ilws), ']')).onMatch((function(_this) {
    return function(match) {
      return ['list'];
    };
  })(this));

  this.filled_list = (π.seq('[', WS.ilws, π.optional(this.list_kernel), WS.ilws, ']')).onMatch((function(_this) {
    return function(match) {
      return ['list'].concat(__slice.call(match[1]));
    };
  })(this));

  this.list = π.alt(this.empty_list, this.filled_list);


  /* TAINT does not respected escaped slashes, interpolations */

  this.identifier = (π.regex(/^[^0-9][^\s:]*/)).onMatch((function(_this) {
    return function(match) {
      return ['identifier', match[0].split('/')];
    };
  })(this));

  this.assignment = (π([this.identifier, ':', WS.ilws, this.expression])).onMatch((function(_this) {
    return function(match) {
      return ['assignment', match[0], match[2]];
    };
  })(this));

}).call(this);