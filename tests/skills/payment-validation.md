# Skill Profile: Payment Form Input Validation Testing

## Context Target
- Scope: CheckoutView input validation logic, error alert banners, and security parameters.

## Explicit Test Data Profiles
- When executing negative validation flows, always use these exact test parameters:
  * Invalid Email Scenario: Use "tester_at_domain.com" (should fail regex validation)
  * Short CVV Scenario: Use "12" (should trigger length warning label)
  * Expired Card Scenario: Use "01/22" (should trigger date restriction label)

## Verification Logic Constraints
- Always assert against the specific text components (`card_number_error`, `email_error`) rather than generic global forms.
