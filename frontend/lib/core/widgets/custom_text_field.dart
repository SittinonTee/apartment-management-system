import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? suffixText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final String? initialValue;
  final bool enabled;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.initialValue,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
    this.isRequired = false,
    this.maxLength,
    this.buildCounter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50), // AppColors.textPrimary
                fontFamily: 'Prompt',
              ),
              children: [
                TextSpan(text: labelText),
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'กรุณากรอก$labelText';
            }
            if (validator != null) {
              return validator!(value);
            }
            return null;
          },
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          initialValue: initialValue,
          enabled: enabled,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onTap: onTap,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          buildCounter: buildCounter,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            suffixText: suffixText,
            suffixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
