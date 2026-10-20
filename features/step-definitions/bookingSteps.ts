import assert from 'node:assert/strict';
import { Before, After, Given, When, Then, setDefaultTimeout } from '@cucumber/cucumber';
import { createIOSDriver } from '../../wdio.conf';

// Appium session startup can take well beyond Cucumber's 5s default step timeout.
setDefaultTimeout(60 * 1000);

/**
 * Several step texts in booking.feature contain parentheses and quotes
 * (e.g. `(if any)`, `("Full payment" or "Deposit")`). Cucumber Expressions treat
 * `()` as "optional text" syntax, which misparses those literal strings. Matching
 * with an escaped RegExp instead sidesteps that entirely and guarantees an exact,
 * literal match against the feature file text.
 */
function exactly(stepText: string): RegExp {
  const escaped = stepText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return new RegExp(`^${escaped}$`);
}

interface ScenarioContext {
  selectedReserveButton?: WebdriverIO.Element;
}

let browser: WebdriverIO.Browser;
let context: ScenarioContext = {};

// ---------------------------------------------------------------------------
// Hooks
// ---------------------------------------------------------------------------

Before(async function () {
  browser = await createIOSDriver();
  context = {};
});

After(async function () {
  await browser?.deleteSession();
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Shorthand for the `~identifier` accessibility-id selector strategy. */
const byId = (identifier: string) => browser.$(`~${identifier}`);

/**
 * Finds trip cells / reserve buttons by accessibility-id prefix using an
 * iOS predicate string, since TripCellView suffixes its ids with the
 * package's dynamic id (e.g. `reserve_button_<package.id>`).
 */
const reserveButtonsByState = (enabled: boolean) =>
  // NSPredicate boolean literals are YES/NO, not JS's true/false — using the latter
  // silently matches zero elements instead of throwing.
  browser
    .$$(`-ios predicate string:name BEGINSWITH "reserve_button_" AND enabled == ${enabled ? 'YES' : 'NO'}`)
    .getElements();

/**
 * The native graphical DatePicker exposes each day as a button whose
 * accessibility name/label is exactly "<Weekday>, <Day> <Month>" (confirmed by
 * inspecting a live session), e.g. "Wednesday, 21 October". Used to tap a
 * specific day without relying on coordinates.
 */
function futureDateLabel(daysFromToday: number): string {
  const target = new Date();
  target.setDate(target.getDate() + daysFromToday);
  const weekday = target.toLocaleDateString('en-US', { weekday: 'long' });
  const day = target.getDate();
  const month = target.toLocaleDateString('en-US', { month: 'long' });
  return `${weekday}, ${day} ${month}`;
}

/** Opens the date picker sheet, selects the given day offset, and confirms. */
async function selectDateOffset(daysFromToday: number) {
  await byId('date_selector_button').click();
  await byId('date_picker').waitForDisplayed({ timeout: 10000 });
  await byId(futureDateLabel(daysFromToday)).click();
  await byId('date_picker_confirm_button').click();
  await byId('date_picker').waitForDisplayed({ reverse: true, timeout: 10000 });
}

/**
 * Reserves the first available package from CharterScreen and waits for CheckoutScreen.
 * The app's booking API flags same-day packages "too soon to book" (see
 * CharterInfoViewModel.unavailabilityReason), so every package is disabled on the
 * default "today" selection — a couple of days out is always picked instead.
 *
 * Querying immediately on load is unreliable: CharterInfoViewModel.isAvailable()
 * defaults a package to available when its availability entry hasn't loaded yet
 * ("guard let availability = ... else { return true }"), so a reserve button can
 * briefly report enabled before the real (usually "too soon") state arrives and the
 * view re-renders — clicking in that window can hit a button that's about to be
 * swapped out. Always running the date-picker flow first gives that async load time
 * to settle before anything is queried or clicked.
 */
async function navigateToCheckoutScreen() {
  const t0 = Date.now();
  await byId('date_selector_button').waitForDisplayed({ timeout: 15000 });
  console.log(`[diag] date_selector_button displayed at +${Date.now() - t0}ms`);
  await selectDateOffset(2);
  console.log(`[diag] date offset selected at +${Date.now() - t0}ms`);
  const available = await reserveButtonsByState(true);
  console.log(`[diag] available buttons found: ${available.length} at +${Date.now() - t0}ms`);
  assert.ok(available.length > 0, 'Expected at least one available (enabled) reserve button');
  const name = await available[0].getAttribute('name');
  console.log(`[diag] clicking ${name} at +${Date.now() - t0}ms`);
  await available[0].click();
  console.log(`[diag] clicked at +${Date.now() - t0}ms, now waiting for confirm_booking_button`);
  try {
    await byId('confirm_booking_button').waitForExist({ timeout: 15000 });
    console.log(`[diag] confirm_booking_button appeared at +${Date.now() - t0}ms`);
  } catch (err) {
    console.log(`[diag] confirm_booking_button FAILED to appear at +${Date.now() - t0}ms`);
    const allButtons = await browser.$$('-ios predicate string:type == "XCUIElementTypeButton"').getElements();
    console.log(`[diag] ${allButtons.length} buttons on screen now:`);
    for (const b of allButtons) {
      console.log('[diag]  -', await b.getAttribute('name'), 'enabled:', await b.getAttribute('enabled'));
    }
    const alerts = await browser.$$('-ios predicate string:type == "XCUIElementTypeAlert"').getElements();
    console.log(`[diag] alerts present: ${alerts.length}`);
    throw err;
  }
}

const CARD_NUMBER = '4242424242424242';
const EXPIRY = '1230';
const CVV = '123';
const CARDHOLDER_NAME = 'Jamie Rivera';

/**
 * Taps the field first to guarantee it has keyboard focus before typing.
 * Without this, setValue() can fire before the native text field has become
 * the first responder, silently dropping the input.
 */
async function setFieldValue(identifier: string, value: string) {
  const field = byId(identifier);
  await field.click();
  await field.setValue(value);
}

async function fillValidCustomerDetails() {
  await setFieldValue('first_name_input', 'Jamie');
  await setFieldValue('last_name_input', 'Rivera');
  await setFieldValue('email_input', 'jamie.rivera@example.com');
  await setFieldValue('phone_input', '5551234567');
}

async function fillValidCardDetails() {
  await setFieldValue('card_number_input', CARD_NUMBER);
  await setFieldValue('expiry_input', EXPIRY);
  await setFieldValue('cvv_input', CVV);
  await setFieldValue('cardholder_name_input', CARDHOLDER_NAME);
}

/**
 * Fills the checkout form, submits it, and waits for ConfirmationView.
 * Used by "booking succeeded" preconditions, since each scenario starts a fresh
 * app session and nothing earlier in those scenarios submits the booking.
 */
async function completeBooking() {
  await fillValidCustomerDetails();
  await byId('payment_option_full_row').click();
  await fillValidCardDetails();
  await byId('confirm_booking_button').click();
  await byId('done_button').waitForDisplayed({ timeout: 15000 });
}

// ---------------------------------------------------------------------------
// Background (feature-level)
// ---------------------------------------------------------------------------

Given(exactly('the application is launched'), async function () {
  // The Appium session created in the Before hook already installs/launches
  // the app (via the `appium:app` capability), so launch itself is implicit.
  assert.ok(browser.sessionId, 'Expected an active Appium session after launch');
});

// ---------------------------------------------------------------------------
// Rule: Selecting a trip package on CharterScreen
// ---------------------------------------------------------------------------

Given(exactly('the CharterScreen has loaded charter data'), async function () {
  await byId('date_selector_button').waitForDisplayed({ timeout: 15000 });
});

When(exactly('the CharterScreen finishes its initial data load'), async function () {
  await byId('date_selector_button').waitForDisplayed({ timeout: 15000 });
});

Then(exactly('the charter photo gallery is displayed'), async function () {
  assert.ok(await byId('gallery_back_button').isDisplayed());
});

Then(exactly("the charter info section shows the charter's details"), async function () {
  // CharterInfoSectionView's title/description Texts have no accessibilityIdentifier
  // of their own yet. Approximated via the screen being loaded past the gallery.
  // TODO: tag the charter title Text directly for a precise content assertion.
  assert.ok(await byId('date_selector_button').isDisplayed());
});

Then(exactly('the list of available trip packages is displayed'), async function () {
  const cells = await browser.$$('-ios predicate string:name BEGINSWITH "trip_cell_"').getElements();
  assert.ok(cells.length > 0, 'Expected at least one trip package cell to be rendered');
});

Then(
  exactly('each package shows its title, price, duration in hours, and max persons (if any)'),
  async function () {
    // Individual labels inside TripCellView aren't separately id-tagged; verified at the
    // cell level. TODO: tag title/price/duration Texts for field-level assertions.
    // isDisplayed() is false for cells scrolled out of the viewport even though they
    // exist in the tree, so presence (not on-screen visibility) is what's checked here.
    const cells = await browser.$$('-ios predicate string:name BEGINSWITH "trip_cell_"').getElements();
    for (const cell of cells) {
      assert.ok(await cell.isExisting());
    }
  }
);

Given(exactly('the CharterScreen is displaying trip packages'), async function () {
  const cells = await browser.$$('-ios predicate string:name BEGINSWITH "trip_cell_"').getElements();
  assert.ok(cells.length > 0, 'Expected trip packages to be visible on CharterScreen');
});

When(exactly('the user taps the date selector'), async function () {
  await byId('date_selector_button').click();
});

When(exactly('selects a new date in the date picker sheet'), async function () {
  await byId('date_picker').waitForDisplayed();
  await byId(futureDateLabel(1)).click();
  await byId('date_picker_confirm_button').click();
});

Then(exactly('the date picker sheet is dismissed'), async function () {
  await byId('date_picker').waitForDisplayed({ reverse: true, timeout: 10000 });
});

Then(exactly('the selected date label updates to reflect the new date'), async function () {
  // SelectorRowView's date value Text has no identifier separate from the tappable
  // button. TODO: tag the date value Text for a direct text comparison.
  assert.ok(await byId('date_selector_button').isDisplayed());
});

Then(exactly('package availability is re-evaluated for the new date'), async function () {
  await byId('date_selector_button').waitForDisplayed();
});

When(exactly('the user taps the guests selector'), async function () {
  await byId('guests_selector_button').click();
});

When(exactly('adjusts adults and/or children in the group size sheet'), async function () {
  await byId('adults_increment_button').click();
  await byId('group_size_confirm_button').click();
});

Then(exactly('the group size sheet is dismissed'), async function () {
  await byId('group_size_confirm_button').waitForDisplayed({ reverse: true, timeout: 10000 });
});

Then(exactly('the guests label updates to reflect the new group size'), async function () {
  // TODO: tag the guests value Text directly for a precise content assertion.
  assert.ok(await byId('guests_selector_button').isDisplayed());
});

Then(exactly('package availability is re-evaluated for the new group size'), async function () {
  await byId('guests_selector_button').waitForDisplayed();
});

Given(
  exactly('a trip package is shown as available for the selected date and group size'),
  async function () {
    // "Today" is flagged too-soon-to-book for every package, so a couple of days
    // out is always selected (see navigateToCheckoutScreen for why querying
    // immediately on load instead is unreliable).
    await selectDateOffset(2);
    const available = await reserveButtonsByState(true);
    assert.ok(available.length > 0, 'Expected at least one available (enabled) reserve button');
    context.selectedReserveButton = available[0];
  }
);

When(exactly('the user taps the "Reserve" button on that package'), async function () {
  assert.ok(context.selectedReserveButton, 'No available package was captured in the Given step');
  await context.selectedReserveButton!.click();
});

Then(exactly('the app navigates to the CheckoutScreen'), async function () {
  await byId('confirm_booking_button').waitForExist({ timeout: 10000 });
});

Then(
  exactly('the CheckoutScreen displays the selected package, date, and group size'),
  async function () {
    assert.ok(await byId('confirm_booking_button').isExisting());
  }
);

Given(
  exactly('a trip package is shown as unavailable for the selected date or group size'),
  async function () {
    const unavailable = await reserveButtonsByState(false);
    assert.ok(unavailable.length > 0, 'Expected at least one unavailable (disabled) reserve button');
    context.selectedReserveButton = unavailable[0];
  }
);

Then(
  exactly("the package's action button displays the unavailability reason instead of \"Reserve\""),
  async function () {
    const label = (await context.selectedReserveButton!.getText()).trim();
    assert.notStrictEqual(label, 'Reserve');
  }
);

Then(exactly('the button is disabled'), async function () {
  assert.strictEqual(await context.selectedReserveButton!.isEnabled(), false);
});

Then(exactly('tapping it does not navigate to the CheckoutScreen'), async function () {
  await context.selectedReserveButton!.click().catch(() => undefined);
  assert.ok(!(await byId('confirm_booking_button').isExisting()));
});

Given(exactly('the charter data request fails'), async function () {
  // TODO: requires network-level fault injection (e.g. proxying APIManager's base URL,
  // or toggling simulator connectivity) to force this deterministically. Left as a
  // manual precondition until that harness exists.
});

Then(exactly('an error state is displayed with an error message'), async function () {
  await byId('retry_button').waitForDisplayed({ timeout: 15000 });
});

Then(exactly('a retry action is available'), async function () {
  assert.ok(await byId('retry_button').isDisplayed());
});

When(exactly('the user triggers the retry action'), async function () {
  await byId('retry_button').click();
});

Then(exactly('the app attempts to reload the initial charter data'), async function () {
  await browser.waitUntil(
    async () => (await byId('retry_button').isExisting()) || (await byId('date_selector_button').isExisting()),
    { timeout: 15000 }
  );
});

// ---------------------------------------------------------------------------
// Rule: Completing a successful booking on CheckoutScreen
// ---------------------------------------------------------------------------

Given(
  exactly('the user has navigated to the CheckoutScreen with a selected package, date, and group size'),
  async function () {
    // Each scenario's Before hook launches a fresh app session on CharterScreen, so
    // actually reserving a package is required to reach CheckoutScreen here.
    await navigateToCheckoutScreen();
  }
);

Given(
  exactly('the booking summary section displays the selected package, date, and total price'),
  async function () {
    // TripSummaryCard's content isn't individually id-tagged yet.
    // TODO: tag package title/date/total Texts for field-level assertions.
    assert.ok(await byId('confirm_booking_button').isExisting());
  }
);

Given(exactly('the user has entered a valid first name'), async function () {
  await setFieldValue('first_name_input', 'Jamie');
});

Given(exactly('the user has entered a valid last name'), async function () {
  await setFieldValue('last_name_input', 'Rivera');
});

Given(exactly('the user has entered a valid email address'), async function () {
  await setFieldValue('email_input', 'jamie.rivera@example.com');
});

Given(exactly('the user has entered a valid phone number'), async function () {
  await setFieldValue('phone_input', '5551234567');
});

Given(exactly('the user has selected a payment option ("Full payment" or "Deposit")'), async function () {
  await byId('payment_option_full_row').click();
});

Given(exactly('the user has entered a valid card number'), async function () {
  await setFieldValue('card_number_input', CARD_NUMBER);
});

Given(exactly('the user has entered a valid expiry date'), async function () {
  await setFieldValue('expiry_input', EXPIRY);
});

Given(exactly('the user has entered a valid CVV'), async function () {
  await setFieldValue('cvv_input', CVV);
});

Given(exactly('the user has entered a valid cardholder name'), async function () {
  await setFieldValue('cardholder_name_input', CARDHOLDER_NAME);
});

When(exactly('the user taps the "Confirm Booking" button'), async function () {
  await byId('confirm_booking_button').click();
});

Then(
  exactly('the submit button shows a loading state while the submission is in progress'),
  async function () {
    // PrimaryButton swaps its label for a ProgressView while isLoading is true but keeps
    // the same accessibilityIdentifier, so presence (not label text) is what we can assert here.
    assert.ok(await byId('confirm_booking_button').isExisting());
  }
);

Then(exactly('no field validation errors are displayed'), async function () {
  const errorIds = [
    'first_name_error',
    'last_name_error',
    'email_error',
    'phone_error',
    'card_number_error',
    'expiry_error',
    'cvv_error',
    'cardholder_name_error',
  ];
  for (const id of errorIds) {
    assert.ok(!(await byId(id).isExisting()), `Expected ${id} to not be present`);
  }
});

Then(exactly('the app navigates to the ConfirmationView on success'), async function () {
  await byId('done_button').waitForDisplayed({ timeout: 15000 });
});

Given(exactly('the booking submission succeeded'), async function () {
  await completeBooking();
});

When(exactly('the ConfirmationView is displayed'), async function () {
  await byId('done_button').waitForDisplayed();
});

Then(exactly('a success indicator (checkmark) is shown'), async function () {
  assert.ok(await byId('confirmation_success_icon').isDisplayed());
});

Then(exactly('a booking confirmation message is shown'), async function () {
  assert.ok(await byId('confirmation_title').isDisplayed());
});

Then(exactly('a booking reference number is shown'), async function () {
  assert.ok(await byId('booking_reference_label').isDisplayed());
});

Then(
  exactly('the trip summary card shows the package, group size, and chosen payment option'),
  async function () {
    // TODO: tag TripSummaryCard's content Texts for field-level assertions.
    assert.ok(await byId('done_button').isDisplayed());
  }
);

Then(exactly('the back navigation button is hidden'), async function () {
  // ConfirmationView sets .navigationBarBackButtonHidden(true); verified via the standard
  // XCUITest navigation bar back button not being present.
  const backButtons = await browser.$$('-ios class chain:**/XCUIElementTypeNavigationBar/XCUIElementTypeButton[1]').getElements();
  assert.strictEqual(backButtons.length, 0, 'Expected no visible back button on the confirmation screen');
});

Given(exactly('the ConfirmationView is displayed after a successful booking'), async function () {
  await completeBooking();
});

When(exactly('the user taps the "Done" button'), async function () {
  await byId('done_button').click();
});

Then(exactly('the app dismisses back to the root CharterScreen'), async function () {
  await byId('date_selector_button').waitForDisplayed({ timeout: 15000 });
});

Given(exactly('the user has filled in valid customer and card details'), async function () {
  await fillValidCustomerDetails();
  await fillValidCardDetails();
});

When(exactly('the user selects the "Deposit" payment option'), async function () {
  await byId('payment_option_deposit_row').click();
});

Then(exactly('the deposit amount and remaining amount are displayed'), async function () {
  // PaymentOptionRow's subtitle Text (deposit/remaining amounts) has no identifier of its
  // own. TODO: tag it directly for a precise text assertion instead of checking the row container.
  assert.ok(await byId('payment_option_deposit_row').isDisplayed());
});

Then(exactly('submitting the form proceeds the same as the full payment option'), async function () {
  await byId('confirm_booking_button').click();
  await byId('done_button').waitForDisplayed({ timeout: 15000 });
});

// ---------------------------------------------------------------------------
// Rule: Validation errors on CheckoutScreen when card info is missing
// ---------------------------------------------------------------------------

Given(
  exactly('the user is on the CheckoutScreen with a selected package, date, and group size'),
  async function () {
    await navigateToCheckoutScreen();
  }
);

Given(
  exactly('the user has entered valid customer details (first name, last name, email, phone)'),
  async function () {
    await fillValidCustomerDetails();
  }
);

Given(exactly('the card number field is empty'), async function () {
  await byId('card_number_input').clearValue();
});

Then(exactly('an inline error is shown under the card number field'), async function () {
  assert.ok(await byId('card_number_error').isDisplayed());
});

Then(
  exactly('a general "fix highlighted fields" message is shown near the submit button'),
  async function () {
    assert.ok(await byId('form_error_message').isDisplayed());
  }
);

Then(exactly('the app does not navigate to the ConfirmationView'), async function () {
  assert.ok(!(await byId('done_button').isExisting()));
});

Given(exactly('the card number field is valid'), async function () {
  await setFieldValue('card_number_input', CARD_NUMBER);
});

Given(exactly('the expiry date field is empty or incomplete'), async function () {
  await byId('expiry_input').clearValue();
});

Then(exactly('an inline error is shown under the expiry field'), async function () {
  assert.ok(await byId('expiry_error').isDisplayed());
});

Given(exactly('the card number and expiry fields are valid'), async function () {
  await setFieldValue('card_number_input', CARD_NUMBER);
  await setFieldValue('expiry_input', EXPIRY);
});

Given(exactly('the CVV field is empty'), async function () {
  await byId('cvv_input').clearValue();
});

Then(exactly('an inline error is shown under the CVV field'), async function () {
  assert.ok(await byId('cvv_error').isDisplayed());
});

Given(exactly('the card number, expiry, and CVV fields are valid'), async function () {
  await setFieldValue('card_number_input', CARD_NUMBER);
  await setFieldValue('expiry_input', EXPIRY);
  await setFieldValue('cvv_input', CVV);
});

Given(exactly('the cardholder name field is empty'), async function () {
  await byId('cardholder_name_input').clearValue();
});

Then(exactly('an inline error is shown under the cardholder name field'), async function () {
  assert.ok(await byId('cardholder_name_error').isDisplayed());
});

Given(exactly('the card number, expiry, CVV, and cardholder name fields are all empty'), async function () {
  await byId('card_number_input').clearValue();
  await byId('expiry_input').clearValue();
  await byId('cvv_input').clearValue();
  await byId('cardholder_name_input').clearValue();
});

Then(exactly('inline errors are shown under each of the invalid card fields'), async function () {
  for (const id of ['card_number_error', 'expiry_error', 'cvv_error', 'cardholder_name_error']) {
    assert.ok(await byId(id).isDisplayed(), `Expected ${id} to be displayed`);
  }
});

Then(exactly('the "fix highlighted fields" message is shown'), async function () {
  assert.ok(await byId('form_error_message').isDisplayed());
});

Given(exactly('the user has attempted to submit with an invalid card number'), async function () {
  await byId('card_number_input').clearValue();
  await byId('confirm_booking_button').click();
});

When(exactly('the user enters a valid card number'), async function () {
  await setFieldValue('card_number_input', CARD_NUMBER);
});

Then(
  exactly('the inline error under the card number field is no longer shown on the next submit attempt'),
  async function () {
    await setFieldValue('expiry_input', EXPIRY);
    await setFieldValue('cvv_input', CVV);
    await setFieldValue('cardholder_name_input', CARDHOLDER_NAME);
    await byId('confirm_booking_button').click();
    assert.ok(!(await byId('card_number_error').isExisting()));
    await byId('done_button').waitForDisplayed({ timeout: 15000 });
  }
);
