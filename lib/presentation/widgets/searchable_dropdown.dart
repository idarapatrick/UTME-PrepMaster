import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> options;
  final String? value;
  final Function(String?) onChanged;
  final String label;
  final String? Function(String?)? validator;

  const SearchableDropdown({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.label,
    this.validator,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  List<String> filtered = [];
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    filtered = widget.options;
  }

  @override
  void didUpdateWidget(SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      filtered = widget.options;
    }
  }

  void _filterOptions(String query) {
    setState(() {
      filtered = widget.options
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return FormField<String>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isOpen = !isOpen;
                  if (isOpen) {
                    filtered = widget.options;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: state.hasError
                        ? Colors.red
                        : (isDark
                              ? AppColors.darkBorderMedium
                              : AppColors.borderMedium),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.value ?? widget.label,
                        style: TextStyle(
                          color: widget.value == null
                              ? (isDark
                                    ? AppColors.darkTextLight
                                    : AppColors.textLight)
                              : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            if (isOpen)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorderMedium
                        : AppColors.borderMedium,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: _filterOptions,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.darkTextLight
                                : AppColors.textLight,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark
                                ? AppColors.darkTextLight
                                : AppColors.textLight,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          return ListTile(
                            title: Text(
                              option,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            onTap: () {
                              widget.onChanged(option);
                              state.didChange(option);
                              setState(() {
                                isOpen = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
