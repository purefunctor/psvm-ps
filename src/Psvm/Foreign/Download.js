const cliProgress = require("cli-progress");
const decompress = require("decompress");
const download = require("download");
const fs = require("fs");


exports.downloadUrlToImpl = function(url) {
  return function(to) {
    return function(cb) {
      return function () {
        const bar = new cliProgress.SingleBar({
          format: "Fetching |{bar}| {percentage}% in {eta}s",
          barCompleteChar: '\u2588',
          barIncompleteChar: ' ',
        });
        bar.start(100, 0, { speed: "N/A" })

        const toStream = fs.createWriteStream(to);
        toStream.on("error", function(error) {
          console.error("Failed to write file.")
        }).on("finish", function() {
          bar.stop();
          cb();
        });

        const dlStream = download(url);
        dlStream.on("downloadProgress", function(progress) {
          bar.update(progress.percent * 100);
        }).on("error", function() {
          bar.stop();
        });

        dlStream.pipe(toStream);
      };
    };
  };
};


exports.extractFromToImpl = function(src) {
  return function(to) {
    return function(cb) {
      return function() {
        decompress(src, to).then(function(files) {
          cb();
        });
      };
    };
  };
};
