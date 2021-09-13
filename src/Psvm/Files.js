const fs = require("fs-extra");

exports.rmRecursiveP = dir => () => fs.remove(dir);

exports.copyFileP = from => to => () => fs.copy(from, to);

exports.mkdirRecursiveP = dir => () => fs.mkdirp(dir);
