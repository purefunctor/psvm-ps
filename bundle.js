const esbuild = require("esbuild");

esbuild
  .build({
    entryPoints: ["index.js"],
    bundle: true,
    minify: true,
    outdir: "dist",
    platform: "node",
    external: ["fs", "path", "electron"],
    banner: {
      js: "#!/usr/bin/env node",
    },
  })
  .catch((_e) => process.exit(1));
