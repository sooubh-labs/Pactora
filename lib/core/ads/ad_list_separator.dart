// lib/core/ads/ad_list_separator.dart
import 'package:flutter/material.dart';
import 'banner_ad_widget.dart';

class AdListSeparator extends StatelessWidget {
  final int index;
  final int adInterval;
  final Widget defaultSeparator;

  const AdListSeparator({
    super.key,
    required this.index,
    this.adInterval = 5,
    this.defaultSeparator = const SizedBox(height: 16),
  });

  @override
  Widget build(BuildContext context) {
    if ((index + 1) % adInterval == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          defaultSeparator,
          const BannerAdWidget(),
          defaultSeparator,
        ],
      );
    }
    return defaultSeparator;
  }
}
