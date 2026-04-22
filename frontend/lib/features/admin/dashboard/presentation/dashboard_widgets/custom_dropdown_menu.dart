import 'package:flutter/material.dart';

class CustomDropdownMenu<T> extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final ValueChanged<T?>? onSelected;
  final FormFieldValidator<T>? validator;
  final bool enableFilter;
  final bool requestFocusOnTap;
  final T? initialSelection;
  final double menuHeight;

  const CustomDropdownMenu({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    required this.dropdownMenuEntries,
    this.onSelected,
    this.validator,
    this.enableFilter = false,
    this.requestFocusOnTap = false,
    this.initialSelection,
    this.menuHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        FormField<T>(
          validator: validator,
          initialValue: initialSelection,
          builder: (FormFieldState<T> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu<T>(
                  inputDecorationTheme: state.hasError
                      ? InputDecorationTheme(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      : null,
                  enableFilter: enableFilter,
                  requestFocusOnTap: requestFocusOnTap,
                  expandedInsets: EdgeInsets.zero,
                  controller: controller,
                  hintText: hintText,
                  menuHeight: menuHeight,
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  dropdownMenuEntries: dropdownMenuEntries,
                  onSelected: (value) {
                    state.didChange(value);
                    if (onSelected != null) {
                      onSelected!(value);
                    }
                  },
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
