const esbuild = require("esbuild");
const path = require("path");

esbuild
  .build({
    entryPoints: ["index.js", "psvm.js"],
    minify: true,
    outdir: "dist",
    platform: "node",
    banner: {
      "js": "#!/usr/bin/env node",
    },
  })
  .catch((_e) => process.exit(1));
