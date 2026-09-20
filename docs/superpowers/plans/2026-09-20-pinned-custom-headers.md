# Pinned Custom Headers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the duplicate standard app bars with the existing dark custom headers and keep those headers pinned while screen content scrolls.

**Architecture:** Convert Profile, Notifications, and Rental History to sliver-based scrolling. Each screen owns one pinned `SliverAppBar` whose flexible content is the existing custom header layout, while page-specific content is rendered through `SliverToBoxAdapter` or `SliverList`. Preserve routes, back behavior, bottom navigation, colors, and screen-specific state.

**Tech Stack:** Flutter, Dart, Material slivers, go_router, provider, flutter_test

---

## File Structure

- Modify `lib/screens/home/profile_screen.dart`: remove the duplicate `Scaffold.appBar`, convert body scrolling to slivers, and make the profile header pinned.
- Modify `lib/screens/home/notification_screen.dart`: remove the duplicate `Scaffold.appBar`, pin the custom notification header, and render filters/feed below it.
- Modify `lib/screens/home/rental_history_screen.dart`: remove the duplicate `Scaffold.appBar`, pin the rental-history header, and render summary/history content below it.
- Modify `test/profile_screen_test.dart`: assert one title/header, pinned sliver presence, scrolling behavior, and existing actions.
- Modify `test/notification_screen_test.dart`: assert one title, pinned sliver presence, scrolling behavior, filters, feed, and back navigation.
- Modify `test/rental_history_screen_test.dart`: assert one title, pinned sliver presence, scrolling behavior, summary/list, and navigation.

### Task 1: Add failing pinned-header tests

**Files:**
- Modify: `test/profile_screen_test.dart`
- Modify: `test/notification_screen_test.dart`
- Modify: `test/rental_history_screen_test.dart`

- [ ] **Step 1: Add a Profile pinned-header test**

Add a test that pumps `_wrap()`, expects `find.byType(SliverAppBar)` once, expects `find.text('Profile')` zero times because Profile's designed header identifies the user rather than duplicating a title, drags `find.byType(CustomScrollView)`, and verifies `find.text('Rider')` and the Back semantics remain present.

```dart
testWidgets('uses one pinned custom header while content scrolls', (tester) async {
  await tester.pumpWidget(_wrap());
  await tester.pumpAndSettle();

  final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
  expect(appBar.pinned, isTrue);
  expect(find.text('Profile'), findsNothing);

  await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
  await tester.pumpAndSettle();

  expect(find.text('Rider'), findsOneWidget);
  expect(find.bySemanticsLabel('Back'), findsOneWidget);
});
```

- [ ] **Step 2: Add a Notification pinned-header test**

Change the existing title expectation from `findsWidgets` to `findsOneWidget`, then add a test that verifies a pinned `SliverAppBar`, scrolls the `CustomScrollView`, and confirms the title and Back semantics remain present.

```dart
testWidgets('pins the only notification header while the feed scrolls', (tester) async {
  await tester.pumpWidget(_wrap());
  await tester.pumpAndSettle();

  final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
  expect(appBar.pinned, isTrue);
  expect(find.text('Notification'), findsOneWidget);

  await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
  await tester.pumpAndSettle();

  expect(find.text('Notification'), findsOneWidget);
  expect(find.bySemanticsLabel('Back'), findsOneWidget);
});
```

Update feed scroll helpers to target `CustomScrollView` instead of `ListView`.

- [ ] **Step 3: Add a Rental History pinned-header test**

Add a test in `test/rental_history_screen_test.dart` that asserts `Rental history` appears once, the `SliverAppBar` is pinned, and scrolling does not remove the title or Back semantics.

```dart
testWidgets('pins the only rental history header while records scroll', (tester) async {
  await tester.pumpWidget(_wrap());
  await tester.pumpAndSettle();

  final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
  expect(appBar.pinned, isTrue);
  expect(find.text('Rental history'), findsOneWidget);

  await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
  await tester.pumpAndSettle();

  expect(find.text('Rental history'), findsOneWidget);
  expect(find.bySemanticsLabel('Back'), findsOneWidget);
});
```

- [ ] **Step 4: Run tests and confirm they fail before implementation**

Run:

```bash
flutter test test/profile_screen_test.dart test/notification_screen_test.dart test/rental_history_screen_test.dart
```

Expected: failures because the screens still use standard `AppBar`, no `SliverAppBar` exists, Notification renders its title twice, and current scrollables are `SingleChildScrollView`/`ListView`.

- [ ] **Step 5: Commit failing tests**

```bash
git add test/profile_screen_test.dart test/notification_screen_test.dart test/rental_history_screen_test.dart
git commit -m "Test pinned custom screen headers"
```

### Task 2: Pin the Profile custom header

**Files:**
- Modify: `lib/screens/home/profile_screen.dart`
- Test: `test/profile_screen_test.dart`

- [ ] **Step 1: Remove the standard Profile AppBar**

Delete `Scaffold.appBar`. Replace the body `Column` plus `Expanded(SingleChildScrollView(...))` with a `CustomScrollView`.

- [ ] **Step 2: Render the existing Profile header inside a pinned sliver**

Use a pinned `SliverAppBar` with `toolbarHeight: 0`, `expandedHeight` sized to the existing header, dark background, no implied leading control, and `FlexibleSpaceBar(background: _Header(...))`.

```dart
SliverAppBar(
  pinned: true,
  automaticallyImplyLeading: false,
  toolbarHeight: 0,
  expandedHeight: 176,
  backgroundColor: AppColors.ink,
  surfaceTintColor: Colors.transparent,
  flexibleSpace: FlexibleSpaceBar(
    collapseMode: CollapseMode.pin,
    background: _Header(
      name: name,
      email: email,
      initials: initials,
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
    ),
  ),
),
```

Adjust `_Header` so it does not add a second top SafeArea inset inside the sliver. Keep its current padding, avatar, identity data, verification badge, and Back semantics.

- [ ] **Step 3: Move Profile content into `SliverToBoxAdapter`**

Wrap the existing padded content column in one `SliverToBoxAdapter`. Keep bottom navigation unchanged.

- [ ] **Step 4: Update Profile scroll helpers**

Replace `find.byType(SingleChildScrollView)` with `find.byType(CustomScrollView)` in Profile tests and preserve all existing content, toggle, logout, and route assertions.

- [ ] **Step 5: Run Profile tests**

```bash
flutter test test/profile_screen_test.dart
```

Expected: all Profile tests pass with no overflow at 320×568, 360×640, and 431×996.

- [ ] **Step 6: Commit Profile implementation**

```bash
git add lib/screens/home/profile_screen.dart test/profile_screen_test.dart
git commit -m "Pin the Profile custom header"
```

### Task 3: Pin the Notification custom header

**Files:**
- Modify: `lib/screens/home/notification_screen.dart`
- Test: `test/notification_screen_test.dart`

- [ ] **Step 1: Remove the standard Notification AppBar**

Delete `Scaffold.appBar` and replace the body `Column`/nested `ListView` with one `CustomScrollView`.

- [ ] **Step 2: Render the custom Notification header as a pinned sliver**

Create a pinned dark `SliverAppBar` with `toolbarHeight: 0`, an expanded height matching the current designed header, and `_Header` in `FlexibleSpaceBar.background`. Keep Back behavior, title, subtitle, and count unchanged.

```dart
SliverAppBar(
  pinned: true,
  automaticallyImplyLeading: false,
  toolbarHeight: 0,
  expandedHeight: 206,
  backgroundColor: AppColors.ink,
  surfaceTintColor: Colors.transparent,
  flexibleSpace: FlexibleSpaceBar(
    collapseMode: CollapseMode.pin,
    background: _Header(
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      count: _notifications.length,
    ),
  ),
),
```

- [ ] **Step 3: Convert filters and feed to slivers**

Render `_FilterBar` through `SliverToBoxAdapter`. Render notifications through `SliverPadding` and `SliverList.separated`, preserving 17px horizontal padding, 12px gaps, and 24px bottom padding.

- [ ] **Step 4: Run Notification tests**

```bash
flutter test test/notification_screen_test.dart
```

Expected: all tests pass, Notification title appears once, all feed items are reachable, and filter/back interactions remain functional.

- [ ] **Step 5: Commit Notification implementation**

```bash
git add lib/screens/home/notification_screen.dart test/notification_screen_test.dart
git commit -m "Pin the Notification custom header"
```

### Task 4: Pin the Rental History custom header

**Files:**
- Modify: `lib/screens/home/rental_history_screen.dart`
- Test: `test/rental_history_screen_test.dart`

- [ ] **Step 1: Remove the standard Rental History AppBar**

Delete `Scaffold.appBar` and replace the body `Column` plus `SingleChildScrollView` with `CustomScrollView`.

- [ ] **Step 2: Render the custom Rental History header as a pinned sliver**

Use the same pinned sliver structure with the existing `_Header`, dark background, no duplicate title, and unchanged Back behavior.

```dart
SliverAppBar(
  pinned: true,
  automaticallyImplyLeading: false,
  toolbarHeight: 0,
  expandedHeight: 207,
  backgroundColor: AppColors.ink,
  surfaceTintColor: Colors.transparent,
  flexibleSpace: FlexibleSpaceBar(
    collapseMode: CollapseMode.pin,
    background: _Header(
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
    ),
  ),
),
```

- [ ] **Step 3: Move summary and rental rows into sliver content**

Wrap the existing padded content column in `SliverToBoxAdapter`. Preserve month picking, totals, receipt rows, empty state, and bottom navigation.

- [ ] **Step 4: Update and run Rental History tests**

Update scroll finders to `CustomScrollView`, then run:

```bash
flutter test test/rental_history_screen_test.dart
```

Expected: all Rental History tests pass, including month selection, receipt behavior, bottom navigation, pinned header, and narrow-layout checks.

- [ ] **Step 5: Commit Rental History implementation**

```bash
git add lib/screens/home/rental_history_screen.dart test/rental_history_screen_test.dart
git commit -m "Pin the Rental History custom header"
```

### Task 5: Full verification

**Files:**
- Verify all modified files

- [ ] **Step 1: Format modified Dart files**

```bash
dart format lib/screens/home/profile_screen.dart lib/screens/home/notification_screen.dart lib/screens/home/rental_history_screen.dart test/profile_screen_test.dart test/notification_screen_test.dart test/rental_history_screen_test.dart
```

Expected: formatter exits successfully.

- [ ] **Step 2: Run focused tests together**

```bash
flutter test test/profile_screen_test.dart test/notification_screen_test.dart test/rental_history_screen_test.dart test/home_screen_test.dart
```

Expected: all tests pass, including the Home-to-Notification and Home-to-Profile navigation tests.

- [ ] **Step 3: Run static analysis**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Inspect the final diff**

```bash
git diff --check
git status --short
git log -6 --oneline
```

Expected: no whitespace errors and only intended changes remain.

- [ ] **Step 5: Commit any final formatting-only changes**

If formatting changed tracked files after the task commits:

```bash
git add lib/screens/home/profile_screen.dart lib/screens/home/notification_screen.dart lib/screens/home/rental_history_screen.dart test/profile_screen_test.dart test/notification_screen_test.dart test/rental_history_screen_test.dart
git commit -m "Polish pinned screen headers"
```
