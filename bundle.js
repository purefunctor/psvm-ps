const esbuild = require("esbuild");
const path = require("path");

esbuild
  .build({
    entryPoints: ["dist/index.js", "dist/psvm.js"],
    minify: true,
    outdir: "bin",
    platform: "node",
    banner: {
      "js": "#!/usr/bin/env node",
    },
  })
  .catch((_e) => process.exit(1));
