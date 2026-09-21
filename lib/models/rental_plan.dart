enum RentalPlan {
  daily(
    title: 'Daily',
    subtitle: 'A flexible 24-hour rental',
    amount: r'$5',
    unit: '/ day',
    duration: Duration(days: 1),
  ),
  weekly(
    title: 'Weekly',
    subtitle: 'Save on a seven-day ride',
    amount: r'$28',
    unit: '/ week',
    duration: Duration(days: 7),
  ),
  monthly(
    title: 'Monthly',
    subtitle: 'Best for everyday mobility',
    amount: r'$95',
    unit: '/ month',
    duration: Duration(days: 30),
  );

  const RentalPlan({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.unit,
    required this.duration,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String unit;

  /// How long the rental runs; drives the "Return by" line.
  final Duration duration;
}
