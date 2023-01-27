import * as psvm from "./output/Main/index.js";
import meta from "./package.json" assert { type: "json" };
psvm.main(meta.name)(meta.version)(meta.description)();
