import { relative } from 'path'

/** @type {import('lint-staged').Configuration} */
export default {
  '*.+(js|vue)': ['eslint --fix --max-warnings=0', 'prettier --write'],
  '*.+(vue|scss)': ['stylelint --fix', 'prettier --write'],
  '*.+(json)': 'prettier --write',
  '*.php': (filenames) => {
    const relativeFiles = filenames
      .map((file) => relative(process.cwd(), file))
      .join(' ')
    return `./vendor/bin/sail php ./vendor/bin/duster fix ${relativeFiles}`
  },
}
