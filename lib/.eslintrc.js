const rules = {
  "indent": [
    "error",
    2,
    { "SwitchCase": 1 }
  ],
  "semi": [
    "error",
    "always"
  ],
  "eol-last": [
    "error",
    "always"
  ],
  "eqeqeq": [
    "error",
    "always"
  ],
};

module.exports = {
  "root": true,
  "env": {
    "es6": true,
    "node": true,
  },
  "extends": [
    "eslint:recommended",
  ],
  "parserOptions": {
    "ecmaVersion": 9,
  },
  "rules": {
    ...rules,
  },
  "overrides": [
    {
      "files": ["**/*.esm.js"],
      "env": {
        "es6": true,
        "node": true,
      },
      "extends": [
        "eslint:recommended",
      ],
      "parserOptions": {
        "ecmaVersion": 9,
        "sourceType": "module",
      },
      "rules": {
        ...rules,
      },
    },
    {
      "files": ["src/**/*.ts"],
      "env": {
        "es2021": true,
        "node": true,
      },
      "extends": [
        "eslint:recommended",
        "plugin:@typescript-eslint/recommended"
      ],
      "parser": "@typescript-eslint/parser",
      "parserOptions": {
        "ecmaVersion": 12,
        "sourceType": "module"
      },
      "plugins": [
        "@typescript-eslint"
      ],
      "rules": {
        ...rules,
        "no-unused-vars": 0,
      },
    }
  ],
};
