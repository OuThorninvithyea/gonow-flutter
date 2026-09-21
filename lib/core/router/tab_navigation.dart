import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_bottom_nav.dart';

const _duration = Duration(milliseconds: 300);
const _curve = Curves.easeOut;

/// How far the screen underneath shifts while the top one slides — the
/// same parallax a native push/pop has.
const _parallax = 0.3;

const _edgeShadow = BoxDecoration(
  boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 16)],
);

/// Route `extra` for a [goWithSlide] switch.
class TabTransition {
  const TabTransition({required this.reverse, this.snapshot});
  final bool reverse;
  final ui.Image? snapshot;
}

void goToTab(BuildContext context, AppNavTab tab, {required AppNavTab from}) {
  final path = '/${tab.name}';
  if (GoRouterState.of(context).uri.path == path) return;
  goWithSlide(
    context,
    path,
    reverse: tab == AppNavTab.home || tab.index < from.index,
  );
}

void goWithSlide(BuildContext context, String path, {required bool reverse}) {
  context.go(
    path,
    extra: TabTransition(reverse: reverse, snapshot: _snapshot(context)),
  );
}

/// Captures the page [context] sits in — [slidePage] wraps each page in the
/// [RepaintBoundary] this finds.
ui.Image? _snapshot(BuildContext context) {
  final boundary = context
      .findAncestorRenderObjectOfType<RenderRepaintBoundary>();
  if (boundary == null || !boundary.hasSize) return null;
  return boundary.toImageSync(
    pixelRatio: MediaQuery.devicePixelRatioOf(context),
  );
}

/// Page for a route reached via [goWithSlide] (the nav bar tabs, and
/// Login ↔ Register).
///
/// A [goWithSlide] switch plays over a snapshot of the previous screen
/// (see [TabTransition]); any other entry — deep link, "Start Navigation",
/// onboarding — simply slides in from the right.
Page<void> slidePage(GoRouterState state, Widget child) {
  final extra = state.extra;
  final transition = extra is TabTransition ? extra : null;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: RepaintBoundary(child: child),
    transitionDuration: _duration,
    reverseTransitionDuration: _duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final t = CurvedAnimation(parent: animation, curve: _curve);
      Widget slide(Widget w, Offset begin, Offset end) => SlideTransition(
        position: Tween(begin: begin, end: end).animate(t),
        child: w,
      );

      // The snapshot only belongs on the way in; once the transition is
      // done (or on a later pop) it's stale, so it drops out. The tree
      // shape stays fixed either way so the screen's state survives.
      final snapshot = transition?.snapshot;
      final Widget previous =
          snapshot != null && animation.status == AnimationStatus.forward
          ? RawImage(image: snapshot, fit: BoxFit.fill)
          : const SizedBox.shrink();

      return Stack(
        fit: StackFit.expand,
        children: transition?.reverse ?? false
            ? [
                // New tab eases in from the left, underneath…
                slide(child, const Offset(-_parallax, 0), Offset.zero),
                // …as the previous one slides out to the right.
                slide(
                  DecoratedBox(decoration: _edgeShadow, child: previous),
                  Offset.zero,
                  const Offset(1, 0),
                ),
              ]
            : [
                // Previous tab eases off to the left, underneath…
                slide(previous, Offset.zero, const Offset(-_parallax, 0)),
                // …as the new one slides in from the right.
                slide(
                  DecoratedBox(decoration: _edgeShadow, child: child),
                  const Offset(1, 0),
                  Offset.zero,
                ),
              ],
      );
    },
  );
}
