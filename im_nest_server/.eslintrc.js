module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    tsconfigRootDir: __dirname,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint/eslint-plugin'],
  extends: ['plugin:@typescript-eslint/recommended'],
  root: true,
  env: {
    node: true,
    jest: true,
  },
  ignorePatterns: ['.eslintrc.js'],
  rules: {
    'no-console': 'off',
    // process.env.NODE_ENV.indexOf('development') == -1 ? 'off' : 'error', // 强制生产环境不能使用console
    'no-debugger': 'off',
    // process.env.NODE_ENV.indexOf('development') == -1 ? 'off' : 'error', // 强制生产环境不能使用debugger
    'no-alert': 'off', // 强制生产环境不能使用alert、confirm 和 prompt
    'no-eval': 'off',
    // process.env.NODE_ENV.indexOf('development') == -1 ? 'off' : 'error', // 强制生产环境不能使用 eval()
    curly: 'error', // 强制所有控制语句使用一致的括号风格
    'default-case': 'error', // 要求 switch 语句中有 default 分支
    'no-eq-null': 'error', // 禁止在没有类型检查操作符的情况下与 null 进行比较
    // 'array-bracket-newline': ['error', {
    //   "multiline": true
    // }], // 禁止在数组开括号后和闭括号前强制换行
    // "object-curly-newline":' ["error", "always"]', // 强制在花括号内使用一致的换行符
    indent: [
      'error',
      2,
      {
        SwitchCase: 1,
        ArrayExpression: 1,
        ObjectExpression: 1,
      },
    ], // 缩进风格
    'no-multiple-empty-lines': [
      2,
      {
        max: 1,
      },
    ], // 禁止出现多行空行
    'no-plusplus': [
      'error',
      {
        allowForLoopAfterthoughts: true,
      },
    ], // 禁止使用一元操作符 ++ 和 --,允许在 for 循环的最后一个表达式中使用 ++ 和 --
    quotes: ['error', 'single'], // 要求尽可能地使用单引号
    'spaced-comment': ['error', 'always'], // // 或 /* 必须跟随至少一个空白
    'switch-colon-spacing': [
      'error',
      {
        before: false,
      },
    ], // 强制在 switch 的冒号之前有空格
    'no-duplicate-imports': 'error', // 禁止重复导入
    'no-const-assign': 'error', // 不允许改变用const声明的变量
    'no-useless-computed-key': 'error', // 禁止在对象中使用不必要的计算属性
    'no-invalid-regexp': 0, // 禁止无效的正则表达式
    '@typescript-eslint/no-var-requires': 'warn', // 允许require
  },
};
