const psvm = require("./psvm.js");
const meta = require("../package.json");
psvm.main(meta.name)(meta.version)(meta.description)();
