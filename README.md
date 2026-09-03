# CharterCheckout

Reviewers please NOTE: 

SwiftUI implementation of the hiring task. React Native is preferred as stated in assignment but explicitly optional — I choose SwiftUI as my strongest platform, but I am fully open to React Native for the role itself.

Required components:

Part 1 — charter info, gallery, trip list, date picker, group size selector, availability tied to date/group size. 
Part 2 — customer details, payment option (full vs. deposit), card form, confirmation with booking summary. 

Both part's are implemented.

Architecture:

MVVM, 
@Observable view models, no third-party dependencies. 
One generic APIClient + APIResponse<T> wrapper handles the API's shared { data, code } envelope across all four endpoints. 
Models decode defensively — several "numeric" fields (price, id) come back as quoted strings, inconsistently across endpoints.

Key decisions:

* Location/rating shown only when present. The design references them, but the charter API doesn't return them — so I filled UI with a placeholder text.
* Unavailable trips are disabled, not hidden. The catalog and today's availability are different facts — hiding a trip throws away the actionable reason ("Min 6 people," "Too soon to book").
* Checkout is one scrollable page, not a wizard — simpler to build reliably within the time budget than a multi-step flow with state to preserve across steps.
* Visual system reused from Part 1 — same card/button styling throughout, shared TripSummaryCard on both Checkout and Confirmation.
* 20% deposit is a stated assumption — the API doesn't specify one.
* Prices always render in US format ($450) regardless of device locale — every charter/currency in this API is a US business quoting USD.
* No fabricated fallback data on load failure. Mocking is allowed as stated in assignment, but silently showing fake trips/prices ahead of a payment step felt riskier than an honest retry state.
* Submit is always tappable — an invalid attempt reveals per-field errors instead of a silently disabled button with no explanation.
* Real validation, not just "non-empty" — email format, phone digit count (with international + support), card length, expiry month range, CVV length, plus live input filtering so invalid characters can't be typed at all.
* Apple Pay skipped — requires a paid Apple Developer account for a Merchant ID, a hard gate unrelated to effort, and outside what the assignment means by "payment option."
* Two endpoints had undocumented shapes and PDF-copy typos in their URLs (charter_photos, package_availabilities) — resolved by testing directly and inspecting live responses.

Out of scope:

Full localization, 
Card expiry-date checks, 
Full phone-format validation, 
Offline persistence, 
Keyboard next/previous field navigation.

Setup:

Xcode 16+, iOS 17+ deployment target (for @Observable). 
No dependencies — just build and run.
