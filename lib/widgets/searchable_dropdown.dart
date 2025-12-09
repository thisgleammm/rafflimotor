import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final Future<List<T>> future;
  final String hintText;
  final String labelText;
  final T? initialSelection;
  final Function(T?) onSelected;
  final String Function(T) itemAsString;
  final FormFieldValidator<T>? validator;

  const SearchableDropdown({
    super.key,
    required this.future,
    required this.hintText,
    required this.labelText,
    this.initialSelection,
    required this.onSelected,
    required this.itemAsString,
    this.validator,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelection;
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelection != oldWidget.initialSelection) {
      _selectedValue = widget.initialSelection;
    }
  }

  Future<void> _showSearchDialog() async {
    final items = await widget.future;

    if (!mounted) return;

    final result = await showDialog<T>(
      context: context,
      builder: (context) => _SearchDialog<T>(
        items: items,
        itemAsString: widget.itemAsString,
        title: widget.labelText.isEmpty ? widget.hintText : widget.labelText,
        initialSelection: _selectedValue,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
      });
      widget.onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Text('Error loading ${widget.labelText}');
        }

        return FormField<T>(
          initialValue: _selectedValue,
          validator: widget.validator,
          builder: (formFieldState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: _showSearchDialog,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: formFieldState.hasError
                          ? Border.all(color: Colors.red, width: 1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedValue != null
                                ? widget.itemAsString(_selectedValue as T)
                                : widget.hintText,
                            style: TextStyle(
                              color: _selectedValue != null
                                  ? const Color(0xFF2D3748)
                                  : Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          LucideIcons.search,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (formFieldState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 8),
                    child: Text(
                      formFieldState.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SearchDialog<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemAsString;
  final String title;
  final T? initialSelection;

  const _SearchDialog({
    required this.items,
    required this.itemAsString,
    required this.title,
    this.initialSelection,
  });

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
              (item) => widget
                  .itemAsString(item)
                  .toLowerCase()
                  .contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFDA1818),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari...',
                  prefixIcon: const Icon(LucideIcons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onChanged: _filterItems,
              ),
            ),
            // Items list
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada hasil',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item == widget.initialSelection;

                        return ListTile(
                          title: Text(
                            widget.itemAsString(item),
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFDA1818)
                                  : const Color(0xFF2D3748),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  LucideIcons.check,
                                  color: Color(0xFFDA1818),
                                )
                              : null,
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
