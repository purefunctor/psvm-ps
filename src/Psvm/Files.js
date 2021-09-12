const fs = require("fs-extra");


exports.rmRecursive = function(dir) {
  return function(cb) {
    return function() {
      fs.remove(dir, function(err) {
        cb();
      });
    };
  };
};


exports.copyFile = function(src) {
  return function(to) {
    return function(cb) {
      return function () {
        fs.copy(src, to, function(err) {
          cb();
        });
      };
    };
  };
};


exports.mkdirRecursive = function(dir) {
  return function(cb) {
    return function() {
      fs.mkdirp(dir, function(err) {
        cb();
      });
    };
  };
};
