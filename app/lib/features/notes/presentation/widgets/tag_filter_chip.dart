import 'package:flutter/material.dart';

import '../../domain/entities/tag.dart';

/// Widget für Tag-Filter Chip
class TagFilterChip extends StatelessWidget {
  const TagFilterChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Tag tag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = tag.color != null
        ? Color(int.parse('0xFF${tag.color}'))
        : Theme.of(context).colorScheme.secondaryContainer;

    return FilterChip(
      label: Text(tag.name),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: backgroundColor.withOpacity(0.3),
      selectedColor: backgroundColor,
      checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
    );
  }
}
