import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Chip displaying order status with appropriate color.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case AppConstants.statusPending:
        return Colors.orange;
      case AppConstants.statusAccepted:
        return Colors.blue;
      case AppConstants.statusCooking:
        return Colors.deepOrange;
      case AppConstants.statusDelivering:
        return Colors.indigo;
      case AppConstants.statusDone:
        return AppTheme.success;
      case AppConstants.statusCanceled:
        return AppTheme.error;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
