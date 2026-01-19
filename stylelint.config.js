/** @type {import('stylelint').Config} */
export default {
  extends: [
    'stylelint-config-standard-scss',
    'stylelint-config-standard-vue/scss',
    'stylelint-config-recess-order',
  ],
  rules: {
    'no-descending-specificity': null,
    'declaration-empty-line-before': null,
    'font-family-no-missing-generic-family-keyword': null,
    'selector-class-pattern':
      '^([a-z][a-z0-9]*)(-[a-z0-9]+)*(__[a-z0-9]+(-[a-z0-9]+)*)?(--[a-z0-9]+(-[a-z0-9]+)*)?$',
  },
}
