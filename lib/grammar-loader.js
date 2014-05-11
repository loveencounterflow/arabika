// Generated by CoffeeScript 1.6.3

/* TAINT contains no facilities to load other grammar modules than those contained in Arabika */

(function() {
  var GLOB, TRM, alert, badge, debug, echo, help, info, log, njs_path, rpr, warn, whisper;

  njs_path = require('path');

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = '﴾main﴿';

  log = TRM.get_logger('plain', badge);

  info = TRM.get_logger('info', badge);

  whisper = TRM.get_logger('whisper', badge);

  alert = TRM.get_logger('alert', badge);

  debug = TRM.get_logger('debug', badge);

  warn = TRM.get_logger('warn', badge);

  help = TRM.get_logger('help', badge);

  echo = TRM.echo.bind(TRM);


  /* https://github.com/isaacs/node-glob */

  GLOB = require('glob');

  this.new_route_info = function(route) {
    var R, base_name, name, nr;
    base_name = njs_path.basename(route);
    nr = parseInt(base_name.replace(/^([0-9]+).+/g, '$1'), 10);
    name = base_name.replace(/^[0-9]+-([^.]+).+$/g, '$1');
    name = name.replace(/-/g, '_');
    name = name.toUpperCase();
    R = {
      'route': route,
      'name': name,
      'nr': nr
    };
    return R;
  };

  this.get_route_infos = function() {

    /* Get routes for all grammar modules whose name starts with a digit other than 0: */
    var R, glob, route;
    glob = njs_path.join(__dirname, '*');
    R = (function() {
      var _i, _len, _ref, _results;
      _ref = GLOB.sync(glob);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        route = _ref[_i];
        _results.push(route);
      }
      return _results;
    })();
    R = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = R.length; _i < _len; _i++) {
        route = R[_i];
        if (/^[1-9]/.test(njs_path.basename(route))) {
          _results.push(route);
        }
      }
      return _results;
    })();
    R = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = R.length; _i < _len; _i++) {
        route = R[_i];
        _results.push(this.new_route_info(route));
      }
      return _results;
    }).call(this);
    R.sort(function(a, b) {
      a = a['nr'];
      b = b['nr'];
      if (a > b) {
        return +1;
      }
      if (a < b) {
        return -1;
      }
      return 0;
    });
    return R;
  };

}).call(this);