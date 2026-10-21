import assert from 'node:assert/strict';
import { Given, When, Then } from '@cucumber/cucumber';
import { browser, byId, exactly } from '../support/driver';

// Step definitions for features/gallery.feature, following
// tests/skills/gallery-swipe-interactions.md:
//  - carousel: `gallery_carousel_container` (a paged TabView)
//  - pages:    `gallery_image_item_<index>`
//  - swipes:   the native `mobile: swipe` command on the carousel element
//
// The paged TabView only keeps the current page in the accessibility tree, so the
// visible `gallery_image_item_<n>` tells us the active index. The system page
// indicator ("page 3 of 75") is read as a cross-check and for the total count;
// it's rendered by TabView itself, so it has no identifier we can set.

const ITEM_PREFIX = 'gallery_image_item_';
const GALLERY_ITEM_TIMEOUT = 15000;

/** Each swipe takes ~0.75s; reaching the last of many photos needs extra time. */
const SWIPE_TO_END_TIMEOUT = 5 * 60 * 1000;

interface GalleryState {
  /** Indexes of every `gallery_image_item_<n>` currently visible on screen. */
  visibleIndexes: number[];
  /** Zero-based index from the page indicator, or undefined if it isn't rendered. */
  indicatorIndex?: number;
  /** Total page count from the page indicator, or undefined if it isn't rendered. */
  total?: number;
}

const carousel = () => byId('gallery_carousel_container');

async function readGalleryState(): Promise<GalleryState> {
  const items = await browser
    .$$(`-ios predicate string:name BEGINSWITH "${ITEM_PREFIX}" AND visible == 1`)
    .getElements();
  const visibleIndexes: number[] = [];
  for (const item of items) {
    const name = (await item.getAttribute('name')) ?? '';
    visibleIndexes.push(Number(name.slice(ITEM_PREFIX.length)));
  }

  const indicators = await browser.$$('-ios class chain:**/XCUIElementTypePageIndicator').getElements();
  if (indicators.length === 0) return { visibleIndexes };
  const value = String(await indicators[0].getAttribute('value')); // e.g. "page 3 of 75"
  const match = value.match(/(\d+)\D+(\d+)/);
  if (!match) return { visibleIndexes };
  return { visibleIndexes, indicatorIndex: Number(match[1]) - 1, total: Number(match[2]) };
}

/** Uses the skill sheet's native swipe command on the carousel element. */
async function swipeGallery(direction: 'left' | 'right') {
  const galleryContainer = carousel();
  await browser.execute('mobile: swipe', { direction, element: await galleryContainer.elementId });
}

/**
 * Waits for the page-change animation to settle on the expected index: exactly one
 * page visible, it's the expected one, and the page indicator agrees.
 */
async function expectActiveIndex(expected: number) {
  let last: GalleryState = { visibleIndexes: [] };
  await browser
    .waitUntil(
      async () => {
        last = await readGalleryState();
        return (
          last.visibleIndexes.length === 1 &&
          last.visibleIndexes[0] === expected &&
          (last.indicatorIndex === undefined || last.indicatorIndex === expected)
        );
      },
      { timeout: 5000, interval: 250 }
    )
    .catch(() => undefined);

  assert.deepStrictEqual(
    last.visibleIndexes,
    [expected],
    `Expected only ${ITEM_PREFIX}${expected} to be visible, got [${last.visibleIndexes.join(', ')}]`
  );
  if (last.indicatorIndex !== undefined) {
    assert.strictEqual(last.indicatorIndex, expected, 'Page indicator disagrees with the visible image');
  }
}

async function totalImages(): Promise<number> {
  const { total } = await readGalleryState();
  assert.ok(total !== undefined, 'Expected the gallery page indicator to report a total image count');
  return total;
}

// ---------------------------------------------------------------------------
// Background
// ---------------------------------------------------------------------------

Given(exactly('the charter photo gallery has loaded at least 3 images'), async function () {
  await carousel().waitForDisplayed({ timeout: GALLERY_ITEM_TIMEOUT });
  // Photos arrive with the rest of the charter data; wait for the first real page.
  await byId(`${ITEM_PREFIX}0`).waitForExist({ timeout: GALLERY_ITEM_TIMEOUT });
  const total = await totalImages();
  assert.ok(total >= 3, `Expected at least 3 gallery images, found ${total}`);
});

// ---------------------------------------------------------------------------
// Preconditions
// ---------------------------------------------------------------------------

Given(exactly('the gallery is showing image 0'), async function () {
  await expectActiveIndex(0);
});

Given(exactly('the gallery is showing the last image'), { timeout: SWIPE_TO_END_TIMEOUT }, async function () {
  const lastIndex = (await totalImages()) - 1;
  // One swipe per page, without reading state in between (reading after every
  // swipe roughly doubles the run time). Then top up a few times in case any
  // swipe didn't register.
  for (let i = 0; i < lastIndex; i++) {
    await swipeGallery('left');
  }
  for (let extra = 0; extra < 5; extra++) {
    const { indicatorIndex } = await readGalleryState();
    if (indicatorIndex === lastIndex) break;
    await swipeGallery('left');
  }
  await expectActiveIndex(lastIndex);
});

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

When(exactly('the user swipes left on the gallery'), async function () {
  await swipeGallery('left');
});

When(exactly('the user swipes right on the gallery'), async function () {
  await swipeGallery('right');
});

// ---------------------------------------------------------------------------
// Outcomes
// ---------------------------------------------------------------------------

Then(/^the gallery shows image (\d+)$/, async function (index: string) {
  await expectActiveIndex(Number(index));
});

Then(exactly('the gallery shows the last image'), async function () {
  await expectActiveIndex((await totalImages()) - 1);
});

Then(exactly('no empty page is shown past the last image'), async function () {
  const lastIndex = (await totalImages()) - 1;
  const { visibleIndexes } = await readGalleryState();
  // An overscroll into an empty zone would leave no page (or a page beyond the
  // last index) on screen, so exactly the last page must still be visible.
  assert.deepStrictEqual(visibleIndexes, [lastIndex], 'Expected the carousel to stay on the last image');
  assert.ok(await carousel().isDisplayed(), 'Expected the gallery carousel to remain on screen');
});
