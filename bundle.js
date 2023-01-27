import esbuild from "esbuild";

esbuild
  .build({
    entryPoints: ["index.js", "psvm.js"],
    minify: true,
    outdir: "dist",
    platform: "node",
    external: ["fs", "path", "electron"],
    banner: {
      js: "#!/usr/bin/env node",
    },
  })
  .catch((_e) => process.exit(1));
