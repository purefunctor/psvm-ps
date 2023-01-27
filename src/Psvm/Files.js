import fs from "fs-extra";

export function rmRecursive(dir) {
  return function (cb) {
    return function () {
      fs.remove(dir, function (err) {
        cb();
      });
    };
  };
}

export function copyFile(src) {
  return function (to) {
    return function (cb) {
      return function () {
        fs.copy(src, to, function (err) {
          cb();
        });
      };
    };
  };
}

export function mkdirRecursive(dir) {
  return function (cb) {
    return function () {
      fs.mkdirp(dir, function (err) {
        cb();
      });
    };
  };
}
