# AI Agent Instructions for Testing

## Project Tech Stack
- Frontend: iOS Native (SwiftUI)
- Language: Swift 6 / iOS 18+

## Testing Framework Architecture
- Framework: Appium with Cucumber.js (BDD Gherkin)
- Language: TypeScript / JavaScript
- Rule: Do NOT use web-based Playwright commands. Always write Appium selectors targeting native iOS elements.

## UI Element Selection Rules
- All SwiftUI Views must have explicit `.accessibilityIdentifier("id_name")` modifiers.
- The automation tests must look for elements using `by.accessibilityId()` or the `~` prefix.

## Specialized Feature Testing
- Before writing, editing, or modifying tests for a specific feature, check if a matching feature instruction sheet exists under the `tests/skills/` directory.
- If a skill sheet is present, read its context constraints and prioritize those definitions over generic layouts.
