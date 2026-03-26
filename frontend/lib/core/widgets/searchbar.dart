import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';

class SearchWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final String buttonLabel;
  final void Function(String)? onSearch;
  final void Function(String)? onChanged;

  const SearchWidget({
    super.key,
    this.controller,
    this.hintText = 'ค้นหาผู้เช่าด้วย เลขห้อง หรือชื่อผู้เช่า...',
    this.buttonLabel = 'ค้นหา',
    this.onSearch,
    this.onChanged,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late final TextEditingController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleSearch() {
    FocusScope.of(context).unfocus();
    widget.onSearch?.call(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      hintText: widget.hintText,
      maxLines: 1,
      prefixIcon: Icons.search,
      onChanged: widget.onChanged,
      onFieldSubmitted: (_) => _handleSearch(),
      suffixIcon: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
          child: CustomButton(
            text: widget.buttonLabel,
            onPressed: _handleSearch,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            width: 80,
          ),
        ),
      ),
    );
  }
}
