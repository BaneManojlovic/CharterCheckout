# Skill Profile: Gallery Image Swipe Interactions

## Context Target
- Scope: `GalleryView.swift`, image horizontal carousels, carousel indicators, and navigation elements.

## Mobile Interaction Constraints
- Targeting: Native iOS UI gesture automation via Appium / WebdriverIO.
- Interaction Style: Horizontal carousel views. Do NOT use web-based click coordinates.
- Swipe Execution: Always utilize structural WebdriverIO touch action configurations or the native iOS mobile command script snippet:
  * Swipe Left Action: `await browser.execute('mobile: swipe', { direction: 'left', element: await galleryContainer.elementId });`
  * Swipe Right Action: `await browser.execute('mobile: swipe', { direction: 'right', element: await galleryContainer.elementId });`

## Test Verification Hooks
- Main Carousel Element: Look for `.accessibilityIdentifier("gallery_carousel_container")`.
- Media Asset Contexts: Asset indicators or structural items must follow the dynamic template `gallery_image_item_<index>`.

## Core Edge-Case Scenarios to Generate
1. Happy Path Navigation: Swipe left to advance through 3 gallery images smoothly, verifying image structural identity changes.
2. Left Boundary Restriction: Attempting to swipe right while currently active on the absolute first image (`index: 0`) must maintain index `0` cleanly.
3. Right Boundary Restriction: Attempting to swipe left while active on the absolute final available gallery asset index must safely preserve the final index state without scrolling into empty view zones.
