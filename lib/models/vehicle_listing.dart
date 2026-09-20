import 'package:flutter/material.dart';

/// One selectable paint color for a vehicle (Figma: the 3-variant
/// "pngtree-modern-electric-scooter..." component — Default/Variant2/
/// Variant3 map to Silver/Black/Red).
class VehicleColorOption {
  const VehicleColorOption({
    required this.name,
    required this.swatch,
    required this.asset,
    this.available = true,
  });

  final String name;
  final Color swatch;
  final String asset;

  /// Whether this color can currently be rented. Unavailable colors are
  /// still shown in the picker (so the rider knows the option exists) but
  /// are disabled with a "Sold out" label.
  final bool available;
}

/// The three paint options every vehicle in the mock fleet ships with,
/// straight from the Figma color-variant component.
const vehicleColorOptions = <VehicleColorOption>[
  VehicleColorOption(
    name: 'Silver',
    swatch: Color(0xFFC7CACD),
    asset: 'assets/images/home/scooter.png',
  ),
  VehicleColorOption(
    name: 'Black',
    swatch: Color(0xFF1C1C1E),
    asset: 'assets/images/home/scooter_black.png',
  ),
  VehicleColorOption(
    name: 'Red',
    swatch: Color(0xFF8B1E24),
    asset: 'assets/images/home/scooter_red.png',
    available: false, // Mock: sold out until restocked.
  ),
];

/// A single rentable vehicle shown on the home feed and the full listing.
///
/// [filterTag] must match one of the labels in the home screen's filter
/// chips (`Nearby`, `Battery 80%+`, `Daily`, `Weekly`) — selecting a chip
/// swaps the featured vehicle to the one tagged with it.
///
/// [category], [distanceKm] and [batteryPercent] back the "Choose your
/// ride" browse screen (Figma: "iPhone 16 Plus - 14"), which filters by
/// category and shows live distance/charge per vehicle.
class VehicleListing {
  const VehicleListing({
    required this.id,
    required this.name,
    required this.filterTag,
    required this.range,
    required this.capacity,
    required this.price,
    required this.description,
    this.category = 'e-scooter',
    this.distanceKm = 4.2,
    this.batteryPercent = 82,
    this.colors = vehicleColorOptions,
    this.code = 'GN-024',
    this.location = 'Toul Kork, Phnom Penh',
  });

  final String id;
  final String name;
  final String filterTag;
  final String range;
  final String capacity;
  final String price;
  final String description;
  final String category;
  final double distanceKm;
  final int batteryPercent;

  /// Short unit code shown on the booking-summary/confirmation receipts
  /// (Figma "total-recipt" / "comfirm-booking": "GN-024"). Every mock
  /// vehicle currently shares the same demo unit; give each its own once
  /// there's a real fleet.
  final String code;

  /// Parking location shown on those same receipts.
  final String location;

  /// Available paint options for this vehicle, in display order. The first
  /// entry is the default shown before the rider picks a color.
  final List<VehicleColorOption> colors;
}

/// Mock fleet — swap for a real API call once the backend is available.
const vehicleListings = <VehicleListing>[
  VehicleListing(
    id: 'fortuner-gr',
    name: 'Fortuner GR',
    filterTag: 'Nearby',
    range: '> 870km',
    capacity: '50L',
    price: r'$ 7.5/day',
    description: 'Parked 200m away. Fully charged and ready to ride.',
    distanceKm: 0.2,
    batteryPercent: 100,
  ),
  VehicleListing(
    id: 'volt-cruiser',
    name: 'Volt Cruiser',
    filterTag: 'Battery 80%+',
    range: '> 60km',
    capacity: '86%',
    price: r'$ 5.0/day',
    description: 'High-capacity battery, charged above 80% and ready to go.',
    distanceKm: 1.8,
    batteryPercent: 86,
  ),
  VehicleListing(
    id: 'city-hopper',
    name: 'City Hopper',
    filterTag: 'Daily',
    range: '> 40km',
    capacity: '30L',
    price: r'$ 3.5/day',
    description: 'Compact scooter built for quick daily errands.',
    distanceKm: 4.2,
    batteryPercent: 82,
  ),
  VehicleListing(
    id: 'weekender-x',
    name: 'Weekender X',
    filterTag: 'Weekly',
    range: '> 500km',
    capacity: '45L',
    price: r'$ 18/week',
    description: 'Long-range scooter for weekly rentals and longer trips.',
    distanceKm: 6.5,
    batteryPercent: 74,
  ),
];
