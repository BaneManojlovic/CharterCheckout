import path from 'path';
import { remote } from 'webdriverio';

// This project drives Appium directly through the `webdriverio` client (not the
// full @wdio/cli test runner), so step definitions call `createIOSDriver()` to get
// a session rather than relying on wdio's own config/runner lifecycle.

/** Local Appium server connection details. Override via env vars for CI. */
export const APPIUM_SERVER = {
  hostname: process.env.APPIUM_HOST ?? 'localhost',
  port: process.env.APPIUM_PORT ? Number(process.env.APPIUM_PORT) : 4723,
  path: '/',
  logLevel: 'info' as const,
};

/**
 * Path to the built .app bundle for the iOS Simulator.
 * Defaults to the conventional output of:
 *   xcodebuild -scheme CharterCheckoutApp -configuration Debug \
 *     -sdk iphonesimulator -derivedDataPath build
 * Override with IOS_APP_PATH for CI or a different local build location.
 */
export const IOS_APP_PATH =
  process.env.IOS_APP_PATH ??
  path.resolve(
    __dirname,
    'CharterCheckoutApp/build/Build/Products/Debug-iphonesimulator/CharterCheckoutApp.app'
  );

/** Capabilities targeting an iPhone 16 / iOS 18 Simulator via the XCUITest driver. */
export const IOS_SIMULATOR_CAPABILITIES = {
  platformName: 'iOS',
  'appium:automationName': 'XCUITest',
  'appium:deviceName': process.env.IOS_DEVICE_NAME ?? 'iPhone 16',
  'appium:platformVersion': process.env.IOS_PLATFORM_VERSION ?? '18.0',
  'appium:app': IOS_APP_PATH,
  'appium:noReset': false,
  'appium:newCommandTimeout': 240,
};

/** Creates a fresh WebdriverIO session against the local Appium server. */
export async function createIOSDriver() {
  return remote({
    ...APPIUM_SERVER,
    capabilities: IOS_SIMULATOR_CAPABILITIES,
  });
}
