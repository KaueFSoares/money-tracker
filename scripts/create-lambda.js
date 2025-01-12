const fs = require('fs')
const path = require('path')
const { execSync } = require('child_process')

const lambdaName = process.argv[2]
const targetDir = "." + process.argv[3] || path.join(__dirname, '../lambdas')

if (!lambdaName) {
  console.error('Missing name')
  process.exit(1)
}

const lambdaPath = path.resolve(targetDir, lambdaName)

if (fs.existsSync(lambdaPath)) {
  console.error(`The directory "${lambdaName}" already exists in ${targetDir}.`)
  process.exit(1)
}

fs.mkdirSync(lambdaPath, { recursive: true })
fs.mkdirSync(path.join(lambdaPath, 'src'))

console.log('Created folder: ', lambdaPath)

execSync(`cd ${lambdaPath} && npm init -y`, { stdio: 'inherit' })

execSync(
  `cd ${lambdaPath} && npm install --save-dev typescript @types/node @types/aws-lambda`,
  { stdio: 'inherit' }
)

fs.writeFileSync(path.join(lambdaPath, 'src/index.ts'), '')

fs.writeFileSync(
  path.join(lambdaPath, 'tsconfig.json'),
  JSON.stringify(
    {
      compilerOptions: {
        target: 'ES2020',
        module: 'CommonJS',
        rootDir: './src',
        outDir: './dist',
        esModuleInterop: true,
        forceConsistentCasingInFileNames: true,
        strict: true,
        skipLibCheck: true,
      },
      include: ['./src/**/*.ts'],
      exclude: ['node_modules', 'dist'],
    },
    null,
    2
  )
)

execSync(`cd ${lambdaPath} && npm install --save-dev prettier`, { stdio: 'inherit' })

fs.writeFileSync(
  path.join(lambdaPath, '.prettierrc'),
  JSON.stringify(
    {
      semi: false,
      singleQuote: true,
      tabWidth: 2,
      useTabs: false,
      arrowParens: 'always',
      endOfLine: 'lf',
    },
    null,
    2
  )
)

fs.writeFileSync(
  path.join(lambdaPath, '.prettierignore'),
  ['node_modules', 'dist'].join('\n')
)

fs.writeFileSync(
  path.join(lambdaPath, '.editorconfig'),
  `root = true

[*]
indent_style = space
indent_size = 2
`
)

console.log(`Lambda "${lambdaName}" set up successfully in: "${lambdaPath}"!`)
