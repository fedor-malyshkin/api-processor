const esbuild = require('esbuild')

esbuild
  .build({
    entryPoints: ['./index.ts'],
    outdir: 'lib/cjs',
    bundle: true,
    minify: true,
    format: 'cjs',
    target: 'ESNext'
  })
  .catch(() => process.exit(1))

esbuild
  .build({
    entryPoints: ['./index.ts'],
    outdir: 'lib/esnext',
    bundle: true,
    minify: true,
    format: 'esm',
    target: 'ESNext'
  })
  .catch(() => process.exit(1))
