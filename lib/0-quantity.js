// Generated by CoffeeScript 1.7.1
(function() {
  var $new, NUMBER, TRM, alert, badge, debug, echo, help, info, log, rpr, warn, whisper, ƒ;

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = '﴾5-quantity﴿';

  log = TRM.get_logger('plain', badge);

  info = TRM.get_logger('info', badge);

  whisper = TRM.get_logger('whisper', badge);

  alert = TRM.get_logger('alert', badge);

  debug = TRM.get_logger('debug', badge);

  warn = TRM.get_logger('warn', badge);

  help = TRM.get_logger('help', badge);

  echo = TRM.echo.bind(TRM);

  ƒ = require('flowmatic');

  $new = ƒ["new"];

  NUMBER = require('./4-number');

}).call(this);
