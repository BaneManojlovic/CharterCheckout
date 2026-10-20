module.exports = {
  default: {
    requireModule: ['ts-node/register'],
    require: ['features/step-definitions/**/*.ts'],
    paths: ['features/**/*.feature'],
    format: ['progress-bar', 'summary'],
    publishQuiet: true,
  },
};
