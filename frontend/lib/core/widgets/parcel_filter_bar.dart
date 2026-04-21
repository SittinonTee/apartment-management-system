import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/choicechip_filter.dart';

class ParcelFilterBar extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;
  final Function(int) onChanged;

  const ParcelFilterBar({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChipFilter(
              label: filters[index],
              selected: selectedIndex == index,
              onSelected: (_) => onChanged(index),
            ),
          );
        }),
      ),
    );
  }
}
