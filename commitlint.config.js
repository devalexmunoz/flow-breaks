export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'subject-case': [2, 'always', 'sentence-case'],
  },
  ignores: [(message) => message.startsWith('WIP')],
}
