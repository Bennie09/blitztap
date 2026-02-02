import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/match_history.dart';
import '../utils/app_colors.dart';
import '../services/history_service.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<MatchHistory> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _loading = true);
    final list = await _historyService.getAll();
    setState(() {
      _matches = list;
      _loading = false;
    });
  }

  Future<void> _deleteMatch(MatchHistory match) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete match?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This match will be removed from history.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _historyService.deleteMatch(match.id);
      await _loadMatches();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Match deleted')));
      }
    }
  }

  Future<void> _toggleFavourite(MatchHistory match) async {
    await _historyService.toggleFavourite(match.id);
    await _loadMatches();
  }

  void _rematch(MatchHistory match) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/settings',
      (route) => false,
      arguments: <String, dynamic>{'rematch': match},
    );
  }

  void _openDetail(MatchHistory match) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HistoryDetailScreen(
          match: match,
          onDeleted: _loadMatches,
          onFavouriteToggled: _loadMatches,
          onRematch: _rematch,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Match History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.active),
            )
          : _matches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No matches yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed games will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                return _MatchHistoryTile(
                  match: match,
                  onTap: () => _openDetail(match),
                  onDelete: () => _deleteMatch(match),
                  onToggleFavourite: () => _toggleFavourite(match),
                  onRematch: () => _rematch(match),
                );
              },
            ),
    );
  }
}

class _MatchHistoryTile extends StatelessWidget {
  final MatchHistory match;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavourite;
  final VoidCallback onRematch;

  const _MatchHistoryTile({
    required this.match,
    required this.onTap,
    required this.onDelete,
    required this.onToggleFavourite,
    required this.onRematch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${match.player1Name} vs ${match.player2Name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (match.isFavourite)
                    const Icon(Icons.star, color: AppColors.active, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                match.resultSummary,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${match.timeControlDisplay} • ${match.moveCount} moves',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onRematch();
                    },
                    icon: const Icon(
                      Icons.replay,
                      size: 18,
                      color: AppColors.active,
                    ),
                    label: const Text(
                      'Rematch',
                      style: TextStyle(color: AppColors.active),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      match.isFavourite ? Icons.star : Icons.star_border,
                      color: match.isFavourite
                          ? AppColors.active
                          : AppColors.textSecondary,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onToggleFavourite();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onDelete();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
