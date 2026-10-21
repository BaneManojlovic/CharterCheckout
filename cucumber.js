module.exports = {
  default: {
    requireModule: ['ts-node/register'],
    require: ['features/support/**/*.ts', 'features/step-definitions/**/*.ts'],
    paths: ['features/**/*.feature'],
    // Console progress bar + summary, plus a standalone HTML dashboard report.
    format: ['progress-bar', 'summary', 'html:reports/cucumber-dashboard.html'],
    publishQuiet: true,
  },
};
