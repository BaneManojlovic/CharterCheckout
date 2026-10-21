@gallery
Feature: Charter photo gallery swipe interactions
  Covers horizontal swiping through the photo carousel at the top of
  CharterScreen (GalleryView), including both edge boundaries.
  Built from tests/skills/gallery-swipe-interactions.md.

  Background:
    Given the application is launched
    And the charter photo gallery has loaded at least 3 images

  @gallery-swipe
  Scenario: Swiping left advances through the first 3 gallery images
    Given the gallery is showing image 0
    When the user swipes left on the gallery
    Then the gallery shows image 1
    When the user swipes left on the gallery
    Then the gallery shows image 2

  @gallery-boundary
  Scenario: Swiping right on the first image stays on the first image
    Given the gallery is showing image 0
    When the user swipes right on the gallery
    Then the gallery shows image 0

  @gallery-boundary
  Scenario: Swiping left on the last image stays on the last image
    Given the gallery is showing the last image
    When the user swipes left on the gallery
    Then the gallery shows the last image
    And no empty page is shown past the last image
