const esbuild = require("esbuild");
const PurescriptPlugin = require('esbuild-plugin-purescript');
const path = require("path");

esbuild
  .build({
    entryPoints: ["src/index.js"],
    bundle: true,
    minify: true,
    outdir: "dist",
    platform: "node",
    external: ["electron"],
    banner: {
      "js": "#!/usr/bin/env node",
    },
    plugins: [PurescriptPlugin({
      output: path.resolve(__dirname, "dce-output")
    })],
  })
  .catch((_e) => process.exit(1));
