# Pinned Custom Headers Design

## Goal

Remove the duplicate standard Flutter `AppBar` shown above the designed dark headers. The existing Figma-style dark header becomes the screen's only app bar and remains pinned while content scrolls.

## Scope

Apply the change to:

- Profile
- Notifications
- Rental History

The Home screen is excluded because its lightweight account row is page content rather than a full dark page header.

## Design

Each affected screen will use a `CustomScrollView` with a pinned `SliverAppBar` or equivalent pinned sliver header. The dark custom header retains its current visual content:

- Profile: back control, avatar, user name, email, and verification badge
- Notifications: back control, title, subtitle, and notification count
- Rental History: back control, eyebrow label, and title

The standalone `Scaffold.appBar` will be removed from these screens so titles are not displayed twice. Header background and system status-bar styling will remain dark and visually continuous.

Screen-specific content will move into sliver content while preserving existing spacing, filter controls, scrolling behavior, bottom navigation, and routes. Notification filters will remain directly below the pinned header and scroll normally with the feed.

## Interaction

- The full custom header remains pinned and does not collapse.
- Back controls retain their existing behavior: pop when possible, otherwise navigate home.
- Bottom navigation remains fixed at the bottom.
- Scrolling affects only page content beneath the header.

## Testing

Widget tests will verify:

- No duplicate standard AppBar title is rendered.
- Each screen contains one pinned sliver app bar/header.
- Content can scroll while the header remains mounted and visible.
- Existing back navigation, Profile navigation, notification navigation, and bottom navigation continue to work.
- Profile and Notification screens continue rendering without overflow at narrow device sizes.

## Non-goals

- Collapsing or shrinking headers
- Redesigning header contents
- Changing navigation routes
- Changing Home screen layout
- Adding persistence or backend behavior
