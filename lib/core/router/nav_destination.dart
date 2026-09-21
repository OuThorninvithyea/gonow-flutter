import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_bottom_nav.dart';

/// Routes a bottom-nav tab tap back to the shell's `/home` StatefulShellRoute,
/// preserving each tab's state (handled by the shell branch navigator).
class NavDestination {
  static void go(BuildContext context, AppNavTab tab) {
    final route = switch (tab) {
      AppNavTab.home => '/home',
      AppNavTab.map => '/map',
      AppNavTab.rentals => '/rental',
      AppNavTab.saved => '/saved',
      AppNavTab.profile => '/profile',
    };
    context.go(route);
  }
}
