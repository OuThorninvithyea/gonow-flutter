import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// One onboarding page, mirroring the three Figma frames
/// (`borading-1`, `boarding02`, `bording-3`).
class _OnboardingPage {
  final String image;
  final String title;
  final String body;

  /// Offset and size of the phone mockup inside the 266pt-tall dark card.
  /// Taken verbatim from Figma — each frame crops the mockup differently.
  final Rect imageRect;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.body,
    required this.imageRect,
  });
}

const _pages = [
  _OnboardingPage(
    image: 'assets/images/onboarding/pick_scooter.png',
    title: 'pick your scooter',
    body:
        'pick your scooter and explore with us , anywhere you do when ever '
        'you need',
    imageRect: Rect.fromLTWH(98, 0, 369, 276),
  ),
  _OnboardingPage(
    image: 'assets/images/onboarding/view_map.png',
    title: 'View Your map',
    body:
        'Find a nearby electric scooter on the map, scan its QR code to '
        "unlock, and you're on your way.",
    imageRect: Rect.fromLTWH(90, 0, 394, 296),
  ),
  _OnboardingPage(
    image: 'assets/images/onboarding/scooter_details.png',
    title: 'View Details your Scooter',
    body:
        'pick and view the scooter , with details display range energy and '
        'trasnimissions',
    imageRect: Rect.fromLTWH(112, 27, 307, 229),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.go('/login');

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const _Header(),
              const SizedBox(height: 31),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _OnboardingPageView(
                    page: _pages[i],
                    step: i + 1,
                    total: _pages.length,
                  ),
                ),
              ),
              _PageDots(index: _index, count: _pages.length),
              const SizedBox(height: 20),
              _ActionButton(
                label: _index == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: _next,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    // Figma insets the header row 20pt from the card's right edge.
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/images/logo_mark.svg', height: 28),
              const SizedBox(width: 8),
              const Text(
                'GoNow',
                style: TextStyle(
                  fontSize: 20,
                  height: 28 / 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.go('/login'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLink,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textLink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.page,
    required this.step,
    required this.total,
  });

  final _OnboardingPage page;
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    // The Figma spacing assumes a ~932pt-tall frame. Scrolling keeps short
    // viewports (small phones, landscape) usable instead of clipping content.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _Illustration(page: page),
          const SizedBox(height: 59),
          Text(
            'Getting started · $step of $total'.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              height: 16.5 / 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.76,
              color: AppColors.textEyebrow,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 34,
              height: 34.34 / 34,
              fontWeight: FontWeight.w600,
              letterSpacing: -2.21,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            style: const TextStyle(
              fontSize: 15,
              height: 24 / 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

/// The dark rounded card: a phone mockup bleeding off the right edge, with a
/// lime "Nearby scooter" badge pinned bottom-left.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.page});

  static const _designWidth = 390.4;
  static const _height = 266.0;

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Figma positions the mockup against a 390.4pt-wide card. Scale those
        // coordinates so the crop holds on narrower and wider screens.
        final scale = constraints.maxWidth / _designWidth;
        final rect = page.imageRect;

        return ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: _height,
            width: double.infinity,
            color: AppColors.ink,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: rect.left * scale,
                  top: rect.top * scale,
                  width: rect.width * scale,
                  height: rect.height * scale,
                  child: Image.asset(page.image, fit: BoxFit.cover),
                ),
                Positioned(
                  left: 28,
                  top: 199,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.ink,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nearby scooter',
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.ink : AppColors.dotInactive,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

/// Onboarding's primary CTA is ink, not the lime theme primary — lime is
/// reserved for accent actions (see the ride-listing screen).
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.onDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
