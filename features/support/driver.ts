import { Before, After, setDefaultTimeout } from '@cucumber/cucumber';
import { createIOSDriver } from '../../wdio.conf';

// Shared Appium session and helpers for every step definition file, so each
// scenario gets exactly one fresh app session no matter which steps it uses.

// Appium session startup can take well beyond Cucumber's 5s default step timeout.
setDefaultTimeout(60 * 1000);

/** The active WebdriverIO session for the current scenario (a live binding). */
export let browser: WebdriverIO.Browser;

Before(async function () {
  browser = await createIOSDriver();
});

After(async function () {
  await browser?.deleteSession();
});

/** Shorthand for the `~identifier` accessibility-id selector strategy. */
export const byId = (identifier: string) => browser.$(`~${identifier}`);

/**
 * Several step texts contain parentheses and quotes (e.g. `(if any)`,
 * `("Full payment" or "Deposit")`). Cucumber Expressions treat `()` as
 * "optional text" syntax, which misparses those literal strings. Matching with
 * an escaped RegExp instead guarantees an exact, literal match.
 */
export function exactly(stepText: string): RegExp {
  const escaped = stepText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return new RegExp(`^${escaped}$`);
}
