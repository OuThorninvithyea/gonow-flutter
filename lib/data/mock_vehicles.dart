/// Minimal local ride-history data used by the imported profile screen.
class MockRide {
  const MockRide({
    required this.scooterName,
    required this.dateLabel,
    required this.durationLabel,
    required this.costLabel,
  });

  final String scooterName;
  final String dateLabel;
  final String durationLabel;
  final String costLabel;
}

const mockRideHistory = <MockRide>[
  MockRide(
    scooterName: 'City Hopper',
    dateLabel: 'Today · 08:14',
    durationLabel: '12 min',
    costLabel: r'$ 3.80',
  ),
  MockRide(
    scooterName: 'Volt Cruiser',
    dateLabel: 'Yesterday · 18:02',
    durationLabel: '24 min',
    costLabel: r'$ 7.40',
  ),
  MockRide(
    scooterName: 'Fortuner GR',
    dateLabel: 'Mon · 07:45',
    durationLabel: '9 min',
    costLabel: r'$ 2.95',
  ),
];
