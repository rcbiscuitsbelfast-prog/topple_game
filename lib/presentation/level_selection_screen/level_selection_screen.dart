import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/level_card_widget.dart';
import './widgets/level_preview_modal.dart';
import './widgets/level_statistics_modal.dart';
import './widgets/player_header_widget.dart';
import './widgets/search_filter_widget.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  FilterType _currentFilter = FilterType.all;
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredLevels = [];

  // Mock data for player
  final Map<String, dynamic> _playerData = {
    'name': 'Alex Johnson',
    'totalStars': 24,
    'avatarUrl':
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?fm=jpg&q=60&w=150&h=150&fit=crop',
    'completedLevels': 8,
    'totalLevels': 10,
  };

  // Mock data for levels
  final List<Map<String, dynamic>> _levelsData = [
    {
      'levelNumber': 1,
      'theme': 'dishes',
      'difficulty': 'Easy',
      'isLocked': false,
      'isCompleted': true,
      'starRating': 3,
      'bestScore': 2850,
      'averageScore': 2400,
      'timesPlayed': 5,
      'completionTime': '01:24',
      'accuracy': 0.85,
      'description':
          'Start your journey by knocking down a simple stack of colorful dishes. Perfect for learning the basics!',
      'objectives': [
        'Destroy all dishes',
        'Complete in under 2 minutes',
        'Achieve 80% accuracy'
      ],
    },
    {
      'levelNumber': 2,
      'theme': 'toys',
      'difficulty': 'Easy',
      'isLocked': false,
      'isCompleted': true,
      'starRating': 2,
      'bestScore': 1950,
      'averageScore': 1650,
      'timesPlayed': 3,
      'completionTime': '02:15',
      'accuracy': 0.72,
      'description':
          'Topple a tower of colorful toy blocks. Watch them tumble in a satisfying cascade!',
      'objectives': [
        'Knock down all toy blocks',
        'Use fewer than 5 shots',
        'Score above 1500 points'
      ],
    },
    {
      'levelNumber': 3,
      'theme': 'furniture',
      'difficulty': 'Medium',
      'isLocked': false,
      'isCompleted': true,
      'starRating': 3,
      'bestScore': 3200,
      'averageScore': 2800,
      'timesPlayed': 7,
      'completionTime': '01:45',
      'accuracy': 0.91,
      'description':
          'Navigate around furniture obstacles to reach your targets. Strategy is key!',
      'objectives': [
        'Clear all furniture',
        'Maintain 85% accuracy',
        'Complete without missing'
      ],
    },
    {
      'levelNumber': 4,
      'theme': 'buildings',
      'difficulty': 'Medium',
      'isLocked': false,
      'isCompleted': true,
      'starRating': 1,
      'bestScore': 1200,
      'averageScore': 1000,
      'timesPlayed': 2,
      'completionTime': '03:30',
      'accuracy': 0.58,
      'description':
          'Demolish a miniature city skyline. Aim for the structural weak points!',
      'objectives': [
        'Demolish all buildings',
        'Find the weak points',
        'Score above 2000 points'
      ],
    },
    {
      'levelNumber': 5,
      'theme': 'dishes',
      'difficulty': 'Medium',
      'isLocked': false,
      'isCompleted': true,
      'starRating': 2,
      'bestScore': 2650,
      'averageScore': 2200,
      'timesPlayed': 4,
      'completionTime': '02:05',
      'accuracy': 0.76,
      'description':
          'A more complex arrangement of dishes with multiple tiers. Precision required!',
      'objectives': [
        'Clear all tiers',
        'Use physics to your advantage',
        'Achieve combo destruction'
      ],
    },
    {
      'levelNumber': 6,
      'theme': 'toys',
      'difficulty': 'Hard',
      'isLocked': false,
      'isCompleted': true,
      'starRating': 3,
      'bestScore': 4100,
      'averageScore': 3500,
      'timesPlayed': 8,
      'completionTime': '01:58',
      'accuracy': 0.94,
      'description':
          'Master the art of chain reactions with this intricate toy setup!',
      'objectives': [
        'Create chain reactions',
        'Perfect accuracy run',
        'Complete under 2 minutes'
      ],
    },
    {
      'levelNumber': 7,
      'theme': 'furniture',
      'difficulty': 'Hard',
      'isLocked': false,
      'isCompleted': true,
      'starRating': 2,
      'bestScore': 3450,
      'averageScore': 2900,
      'timesPlayed': 6,
      'completionTime': '02:42',
      'accuracy': 0.81,
      'description':
          'Navigate through a furniture maze to reach hidden targets behind obstacles.',
      'objectives': [
        'Find all hidden targets',
        'Navigate the maze',
        'Minimize collateral damage'
      ],
    },
    {
      'levelNumber': 8,
      'theme': 'buildings',
      'difficulty': 'Hard',
      'isLocked': false,
      'isCompleted': true,
      'starRating': 1,
      'bestScore': 2100,
      'averageScore': 1800,
      'timesPlayed': 3,
      'completionTime': '04:15',
      'accuracy': 0.63,
      'description':
          'The ultimate demolition challenge. Bring down the entire metropolitan area!',
      'objectives': [
        'Total demolition',
        'Strategic targeting',
        'Achieve maximum destruction'
      ],
    },
    {
      'levelNumber': 9,
      'theme': 'dishes',
      'difficulty': 'Hard',
      'isLocked': false,
      'isCompleted': false,
      'starRating': 0,
      'bestScore': 0,
      'averageScore': 0,
      'timesPlayed': 0,
      'completionTime': '00:00',
      'accuracy': 0.0,
      'description':
          'The penultimate challenge featuring the most complex dish arrangement yet!',
      'objectives': [
        'Master complex physics',
        'Achieve perfect precision',
        'Unlock the final level'
      ],
    },
    {
      'levelNumber': 10,
      'theme': 'buildings',
      'difficulty': 'Hard',
      'isLocked': true,
      'isCompleted': false,
      'starRating': 0,
      'bestScore': 0,
      'averageScore': 0,
      'timesPlayed': 0,
      'completionTime': '00:00',
      'accuracy': 0.0,
      'description':
          'The ultimate finale! Only the most skilled players can conquer this legendary level.',
      'objectives': [
        'Prove your mastery',
        'Achieve legendary status',
        'Complete the journey'
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredLevels = _levelsData;
  }

  void _filterLevels() {
    setState(() {
      _filteredLevels = _levelsData.where((level) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final levelNumber = level['levelNumber'].toString();
          final theme = level['theme'] as String;
          final difficulty = level['difficulty'] as String;

          final query = _searchQuery.toLowerCase();
          if (!levelNumber.contains(query) &&
              !theme.toLowerCase().contains(query) &&
              !difficulty.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Type filter
        switch (_currentFilter) {
          case FilterType.completed:
            return level['isCompleted'] == true;
          case FilterType.incomplete:
            return level['isCompleted'] == false && level['isLocked'] == false;
          case FilterType.easy:
            return level['difficulty'] == 'Easy';
          case FilterType.medium:
            return level['difficulty'] == 'Medium';
          case FilterType.hard:
            return level['difficulty'] == 'Hard';
          case FilterType.all:
          default:
            return true;
        }
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterLevels();
  }

  void _onFilterChanged(FilterType filter) {
    _currentFilter = filter;
    _filterLevels();
  }

  void _showLevelPreview(Map<String, dynamic> levelData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => LevelPreviewModal(
          levelData: levelData,
          onPlayLevel: () => _navigateToGameplay(levelData),
        ),
      ),
    );
  }

  void _showLevelStatistics(Map<String, dynamic> levelData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.6,
        builder: (context, scrollController) => LevelStatisticsModal(
          levelData: levelData,
          onReplay: () => _navigateToGameplay(levelData),
        ),
      ),
    );
  }

  void _navigateToGameplay(Map<String, dynamic> levelData) {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/gameplay-screen', arguments: levelData);
  }

  void _navigateToSandboxMode() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/gameplay-screen',
        arguments: {'sandbox': true});
  }

  Future<void> _refreshProgress() async {
    HapticFeedback.lightImpact();
    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, this would sync with local storage or server
    setState(() {
      // Refresh data if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Player header
          PlayerHeaderWidget(playerData: _playerData),

          // Search and filter
          SearchFilterWidget(
            onSearchChanged: _onSearchChanged,
            onFilterChanged: _onFilterChanged,
            currentFilter: _currentFilter,
          ),

          // Level grid
          Expanded(
            child: _filteredLevels.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshProgress,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth > 600;
                        final crossAxisCount = isTablet ? 3 : 2;
                        final aspectRatio = isTablet ? 1.2 : 0.8;

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: _filteredLevels.length,
                          itemBuilder: (context, index) {
                            final levelData = _filteredLevels[index];
                            return LevelCardWidget(
                              levelData: levelData,
                              onTap: () => _showLevelPreview(levelData),
                              onLongPress: levelData['isCompleted'] == true
                                  ? () => _showLevelStatistics(levelData)
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      // Floating action button for sandbox mode
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToSandboxMode,
        backgroundColor: AppTheme.secondaryLight,
        foregroundColor: Colors.white,
        icon: CustomIconWidget(
          iconName: 'science',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'Sandbox',
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'search_off',
                color: theme.colorScheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No levels found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilter == FilterType.all
                  ? 'Try adjusting your search terms'
                  : 'No levels match your current filter',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                _currentFilter = FilterType.all;
                _searchQuery = '';
                _filterLevels();
              },
              child: Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
