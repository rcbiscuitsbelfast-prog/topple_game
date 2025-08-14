import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum FilterType { all, completed, incomplete, easy, medium, hard }

class SearchFilterWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(FilterType) onFilterChanged;
  final FilterType currentFilter;

  const SearchFilterWidget({
    super.key,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.currentFilter,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isSearchExpanded
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: _isSearchExpanded ? 2 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    onTap: () {
                      setState(() {
                        _isSearchExpanded = true;
                      });
                    },
                    onSubmitted: (_) {
                      setState(() {
                        _isSearchExpanded = false;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search levels...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CustomIconWidget(
                          iconName: 'search',
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          size: 20,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                widget.onSearchChanged('');
                                setState(() {
                                  _isSearchExpanded = false;
                                });
                              },
                              icon: CustomIconWidget(
                                iconName: 'clear',
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                                size: 20,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter button
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: widget.currentFilter != FilterType.all
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.currentFilter != FilterType.all
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showFilterOptions(context);
                  },
                  icon: CustomIconWidget(
                    iconName: 'filter_list',
                    color: widget.currentFilter != FilterType.all
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // Active filter indicator
          if (widget.currentFilter != FilterType.all)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getFilterDisplayName(widget.currentFilter),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onFilterChanged(FilterType.all);
                          },
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onFilterChanged(FilterType.all);
                      _searchController.clear();
                      widget.onSearchChanged('');
                    },
                    child: Text(
                      'Clear All',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Filter Levels',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Filter options
            _buildFilterOption(
                context, FilterType.all, 'All Levels', Icons.apps_rounded),
            _buildFilterOption(context, FilterType.completed, 'Completed',
                Icons.check_circle_rounded),
            _buildFilterOption(context, FilterType.incomplete, 'Incomplete',
                Icons.radio_button_unchecked_rounded),

            const SizedBox(height: 16),

            Text(
              'Difficulty',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            _buildFilterOption(context, FilterType.easy, 'Easy',
                Icons.sentiment_satisfied_rounded),
            _buildFilterOption(context, FilterType.medium, 'Medium',
                Icons.sentiment_neutral_rounded),
            _buildFilterOption(context, FilterType.hard, 'Hard',
                Icons.sentiment_very_dissatisfied_rounded),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, FilterType filterType,
      String title, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = widget.currentFilter == filterType;

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon.codePoint.toString(),
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? CustomIconWidget(
              iconName: 'check',
              color: theme.colorScheme.primary,
              size: 20,
            )
          : null,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onFilterChanged(filterType);
        Navigator.pop(context);
      },
    );
  }

  String _getFilterDisplayName(FilterType filter) {
    switch (filter) {
      case FilterType.all:
        return 'All Levels';
      case FilterType.completed:
        return 'Completed';
      case FilterType.incomplete:
        return 'Incomplete';
      case FilterType.easy:
        return 'Easy';
      case FilterType.medium:
        return 'Medium';
      case FilterType.hard:
        return 'Hard';
    }
  }
}
