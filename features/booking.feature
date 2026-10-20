Feature: Booking Flow
  Automated counterpart to tests/manual/booking_flow_tests.md.
  Covers trip package selection on CharterScreen, a successful booking on
  CheckoutScreen, and card validation errors on CheckoutScreen.

  Background:
    Given the application is launched

  Rule: Selecting a trip package on CharterScreen

    Background:
      Given the CharterScreen has loaded charter data

    @charter-screen
    Scenario: Charter details and packages load successfully
      When the CharterScreen finishes its initial data load
      Then the charter photo gallery is displayed
      And the charter info section shows the charter's details
      And the list of available trip packages is displayed
      And each package shows its title, price, duration in hours, and max persons (if any)

    @charter-screen
    Scenario: Selecting a date updates package availability
      Given the CharterScreen is displaying trip packages
      When the user taps the date selector
      And selects a new date in the date picker sheet
      Then the date picker sheet is dismissed
      And the selected date label updates to reflect the new date
      And package availability is re-evaluated for the new date

    @charter-screen
    Scenario: Selecting a group size updates package availability
      Given the CharterScreen is displaying trip packages
      When the user taps the guests selector
      And adjusts adults and/or children in the group size sheet
      Then the group size sheet is dismissed
      And the guests label updates to reflect the new group size
      And package availability is re-evaluated for the new group size

    @charter-screen
    Scenario: Reserving an available package navigates to Checkout
      Given a trip package is shown as available for the selected date and group size
      When the user taps the "Reserve" button on that package
      Then the app navigates to the CheckoutScreen
      And the CheckoutScreen displays the selected package, date, and group size

    @charter-screen
    Scenario: Attempting to reserve an unavailable package
      Given a trip package is shown as unavailable for the selected date or group size
      Then the package's action button displays the unavailability reason instead of "Reserve"
      And the button is disabled
      And tapping it does not navigate to the CheckoutScreen

    @charter-screen
    Scenario: Charter data fails to load
      Given the charter data request fails
      Then an error state is displayed with an error message
      And a retry action is available
      When the user triggers the retry action
      Then the app attempts to reload the initial charter data

  Rule: Completing a successful booking on CheckoutScreen

    Background:
      Given the user has navigated to the CheckoutScreen with a selected package, date, and group size
      And the booking summary section displays the selected package, date, and total price

    @checkout-success
    Scenario: Submitting a fully valid booking form
      Given the user has entered a valid first name
      And the user has entered a valid last name
      And the user has entered a valid email address
      And the user has entered a valid phone number
      And the user has selected a payment option ("Full payment" or "Deposit")
      And the user has entered a valid card number
      And the user has entered a valid expiry date
      And the user has entered a valid CVV
      And the user has entered a valid cardholder name
      When the user taps the "Confirm Booking" button
      Then the submit button shows a loading state while the submission is in progress
      And no field validation errors are displayed
      And the app navigates to the ConfirmationView on success

    @checkout-success
    Scenario: Confirmation screen reflects the completed booking
      Given the booking submission succeeded
      When the ConfirmationView is displayed
      Then a success indicator (checkmark) is shown
      And a booking confirmation message is shown
      And a booking reference number is shown
      And the trip summary card shows the package, group size, and chosen payment option
      And the back navigation button is hidden

    @checkout-success
    Scenario: Returning to the root screen from the confirmation screen
      Given the ConfirmationView is displayed after a successful booking
      When the user taps the "Done" button
      Then the app dismisses back to the root CharterScreen

    @checkout-success
    Scenario: Choosing the deposit payment option
      Given the user has filled in valid customer and card details
      When the user selects the "Deposit" payment option
      Then the deposit amount and remaining amount are displayed
      And submitting the form proceeds the same as the full payment option

  Rule: Validation errors on CheckoutScreen when card info is missing

    Background:
      Given the user is on the CheckoutScreen with a selected package, date, and group size
      And the user has entered valid customer details (first name, last name, email, phone)

    @checkout-validation
    Scenario: Submitting with an empty card number
      Given the card number field is empty
      When the user taps the "Confirm Booking" button
      Then an inline error is shown under the card number field
      And a general "fix highlighted fields" message is shown near the submit button
      And the app does not navigate to the ConfirmationView

    @checkout-validation
    Scenario: Submitting with an invalid/incomplete expiry date
      Given the card number field is valid
      And the expiry date field is empty or incomplete
      When the user taps the "Confirm Booking" button
      Then an inline error is shown under the expiry field
      And the app does not navigate to the ConfirmationView

    @checkout-validation
    Scenario: Submitting with a missing CVV
      Given the card number and expiry fields are valid
      And the CVV field is empty
      When the user taps the "Confirm Booking" button
      Then an inline error is shown under the CVV field
      And the app does not navigate to the ConfirmationView

    @checkout-validation
    Scenario: Submitting with a missing cardholder name
      Given the card number, expiry, and CVV fields are valid
      And the cardholder name field is empty
      When the user taps the "Confirm Booking" button
      Then an inline error is shown under the cardholder name field
      And the app does not navigate to the ConfirmationView

    @checkout-validation
    Scenario: Submitting with multiple missing card fields at once
      Given the card number, expiry, CVV, and cardholder name fields are all empty
      When the user taps the "Confirm Booking" button
      Then inline errors are shown under each of the invalid card fields
      And the "fix highlighted fields" message is shown
      And the app does not navigate to the ConfirmationView

    @checkout-validation
    Scenario: Correcting a previously invalid field clears its error
      Given the user has attempted to submit with an invalid card number
      And an inline error is shown under the card number field
      When the user enters a valid card number
      Then the inline error under the card number field is no longer shown on the next submit attempt
