const cliProgress = require("cli-progress");
const decompress = require("decompress");
const download = require("download");
const fs = require("fs");

exports.downloadUrlToP = url => to => () => new Promise((resolve, reject) => {
  const bar = new cliProgress.SingleBar({
    format: "Fetching |{bar}| {percentage}% in {eta}s",
    barCompleteChar: '\u2588',
    barIncompleteChar: ' ',
  });
  bar.start(100, 0, { speed: "N/A" })

  const toStream = fs.createWriteStream(to);
  toStream.on("finish", function() {
    bar.stop();
  })

  const dlStream = download(url);
  dlStream.on("downloadProgress", function(progress) {
    bar.update(progress.percent * 100);
  }).on("error", function() {
    bar.stop();
  });

  dlStream.pipe(toStream);
})

exports.extractFromToP = from => to => () => {
    decompress(from, to);
}
