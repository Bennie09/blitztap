import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/game_provider.dart';
import '../utils/app_colors.dart';
import '../models/time_preset.dart';
import '../widgets/countdown_overlay.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedCategory = 'Bullet';
  TimePreset? selectedPreset;
  bool isCustomMode = false;
  int customMinutes = 1;
  int customIncrement = 1;
  String customPresetName = '';
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();
  final TextEditingController customNameController = TextEditingController();
  List<TimePreset> savedCustomPresets = [];
  bool showCountdown = false;
  bool showPlayerNameOverlay = false;
  bool showCustomTimeSetter = false;

  static const List<TimePresetCategory> presetCategories = [
    TimePresetCategory(
      category: 'Bullet',
      presets: [
        TimePreset(name: '1 min', minutes: 1, increment: 0),
        TimePreset(name: '1 + 1', minutes: 1, increment: 1),
        TimePreset(name: '2 + 1', minutes: 2, increment: 1),
      ],
    ),
    TimePresetCategory(
      category: 'Blitz',
      presets: [
        TimePreset(name: '3 min', minutes: 3, increment: 0),
        TimePreset(name: '3 + 2', minutes: 3, increment: 2),
        TimePreset(name: '5 min', minutes: 5, increment: 0),
      ],
    ),
    TimePresetCategory(
      category: 'Rapid',
      presets: [
        TimePreset(name: '10 min', minutes: 10, increment: 0),
        TimePreset(name: '15 + 10', minutes: 15, increment: 10),
        TimePreset(name: '30 min', minutes: 30, increment: 0),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Restore normal system UI when entering settings screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _loadSavedPresets();
    player1Controller.text = 'Player 1';
    player2Controller.text = 'Player 2';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure UI is restored when screen becomes active (handles edge cases)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    player1Controller.dispose();
    player2Controller.dispose();
    customNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCount = prefs.getInt('custom_presets_count') ?? 0;
    final List<TimePreset> presets = [];
    for (int i = 0; i < savedCount; i++) {
      final name = prefs.getString('custom_preset_${i}_name');
      final minutes = prefs.getInt('custom_preset_${i}_minutes');
      final increment = prefs.getInt('custom_preset_${i}_increment');
      if (name != null && minutes != null && increment != null) {
        presets.add(
          TimePreset(name: name, minutes: minutes, increment: increment),
        );
      }
    }
    setState(() {
      savedCustomPresets = presets;
    });
  }

  void _randomizePlayers() {
    final random = Random();
    if (random.nextBool()) {
      // Swap player names
      final temp = player1Controller.text;
      player1Controller.text = player2Controller.text;
      player2Controller.text = temp;
    }
    Provider.of<GameProvider>(context, listen: false).randomizeFirstPlayer();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Players randomized!')));
  }

  void _onStartGamePressed() {
    // Check if a preset is selected (either from categories or custom saved preset)
    if (!isCustomMode && selectedPreset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time control')),
      );
      return;
    }
    // For custom mode, ensure a saved preset is selected
    if (isCustomMode && selectedCategory == 'Custom') {
      // Check if the current custom time matches a saved preset
      final hasMatchingPreset = savedCustomPresets.any(
        (preset) =>
            preset.minutes == customMinutes &&
            preset.increment == customIncrement,
      );
      if (!hasMatchingPreset) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a saved custom preset')),
        );
        return;
      }
    }
    setState(() {
      showPlayerNameOverlay = true;
    });
  }

  void _onFinalStart() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // Set player names
    gameProvider.setPlayerName(1, player1Controller.text);
    gameProvider.setPlayerName(2, player2Controller.text);

    // Get time settings
    int minutes = customMinutes;
    int increment = customIncrement;

    if (!isCustomMode && selectedPreset != null) {
      minutes = selectedPreset!.minutes;
      increment = selectedPreset!.increment;
    }

    // Initialize and start game
    gameProvider.initializeGame(minutes, increment);

    setState(() {
      showPlayerNameOverlay = false;
      showCountdown = true;
    });
  }

  void _onCountdownComplete() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.startGame();
    Navigator.of(context).pushReplacementNamed('/game');
  }

  @override
  Widget build(BuildContext context) {
    if (showCountdown) {
      return CountdownOverlay(onComplete: _onCountdownComplete);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with App Icon and Name
                  Row(
                    children: [
                      Image.asset(
                        'assets/app_icon2.png',
                        width: 48,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.active,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.timer,
                              color: AppColors.textPrimary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'BlitzTap',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Time Selection Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Title
                        const Center(
                          child: Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Bullet Section
                        _buildCategorySection(
                          'Bullet',
                          'assets/bullet.png',
                          presetCategories[0].presets,
                          selectedCategory == 'Bullet' ? selectedPreset : null,
                        ),
                        const SizedBox(height: 24),

                        // Blitz Section
                        _buildCategorySection(
                          'Blitz',
                          'assets/thunder.png',
                          presetCategories[1].presets,
                          selectedCategory == 'Blitz' ? selectedPreset : null,
                        ),
                        const SizedBox(height: 24),

                        // Rapid Section
                        _buildCategorySection(
                          'Rapid',
                          'assets/rapid.png',
                          presetCategories[2].presets,
                          selectedCategory == 'Rapid' ? selectedPreset : null,
                        ),
                      ],
                    ),
                  ),

                  // Custom Section Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: _buildCustomSection(),
                  ),

                  const SizedBox(height: 24),

                  // Start Game Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onStartGamePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.active,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Game',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Player Name Overlay
            if (showPlayerNameOverlay) _buildPlayerNameOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    String categoryName,
    String iconPath,
    List<TimePreset> presets,
    TimePreset? selected,
  ) {
    final isSelected = selectedCategory == categoryName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.circle,
                  size: 24,
                  color: AppColors.textSecondary,
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: presets.map((preset) {
            final isPresetSelected = selected == preset && isSelected;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = categoryName;
                      selectedPreset = preset;
                      isCustomMode = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPresetSelected
                        ? AppColors.active
                        : AppColors.inactive,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    preset.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/custom.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.settings,
                  size: 24,
                  color: AppColors.textSecondary,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Custom',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            // Plus icon to show/hide time setter
            IconButton(
              icon: Icon(
                showCustomTimeSetter ? Icons.remove : Icons.add,
                color: AppColors.active,
              ),
              onPressed: () {
                setState(() {
                  showCustomTimeSetter = !showCustomTimeSetter;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Show saved custom presets like other presets
        if (savedCustomPresets.isNotEmpty)
          Row(
            children: savedCustomPresets.map((preset) {
              final isSelected =
                  selectedCategory == 'Custom' &&
                  isCustomMode &&
                  customMinutes == preset.minutes &&
                  customIncrement == preset.increment;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onLongPress: () {
                      _showDeleteDialog(preset);
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = 'Custom';
                          customMinutes = preset.minutes;
                          customIncrement = preset.increment;
                          isCustomMode = true;
                          selectedPreset = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColors.active
                            : AppColors.inactive,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        preset.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        // Time setter (hidden by default)
        if (showCustomTimeSetter) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$customMinutes min${customIncrement > 0 ? ' + $customIncrement' : ''}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Minutes',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Slider(
                  value: customMinutes.toDouble(),
                  min: 1,
                  max: 60,
                  divisions: 59,
                  activeColor: AppColors.active,
                  inactiveColor: AppColors.inactive,
                  onChanged: (value) {
                    setState(() {
                      customMinutes = value.toInt();
                    });
                  },
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Increment (Seconds)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Slider(
                  value: customIncrement.toDouble(),
                  min: 0,
                  max: 30,
                  divisions: 30,
                  activeColor: AppColors.active,
                  inactiveColor: AppColors.inactive,
                  onChanged: (value) {
                    setState(() {
                      customIncrement = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Preset name input
                TextField(
                  controller: customNameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Preset name (e.g., My Game)',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.textSecondary,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.textSecondary,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.active,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveCustomPreset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.active,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _saveCustomPreset() async {
    if (customNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for this preset')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt('custom_presets_count') ?? 0;
    final newPreset = TimePreset(
      name: customNameController.text.trim(),
      minutes: customMinutes,
      increment: customIncrement,
    );

    // Save the preset
    await prefs.setString('custom_preset_${currentCount}_name', newPreset.name);
    await prefs.setInt(
      'custom_preset_${currentCount}_minutes',
      newPreset.minutes,
    );
    await prefs.setInt(
      'custom_preset_${currentCount}_increment',
      newPreset.increment,
    );
    await prefs.setInt('custom_presets_count', currentCount + 1);

    // Reload presets
    await _loadSavedPresets();

    // Auto-select the newly saved preset
    setState(() {
      selectedCategory = 'Custom';
      isCustomMode = true;
      selectedPreset = null;
      showCustomTimeSetter = false;
      customNameController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preset saved!')));
  }

  Future<void> _showDeleteDialog(TimePreset preset) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Preset?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${preset.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteCustomPreset(preset);
    }
  }

  Future<void> _deleteCustomPreset(TimePreset preset) async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('custom_presets_count') ?? 0;

    // Find and remove the preset
    for (int i = 0; i < count; i++) {
      final name = prefs.getString('custom_preset_${i}_name');
      final minutes = prefs.getInt('custom_preset_${i}_minutes');
      final increment = prefs.getInt('custom_preset_${i}_increment');

      if (name == preset.name &&
          minutes == preset.minutes &&
          increment == preset.increment) {
        // Remove this preset by shifting others
        for (int j = i; j < count - 1; j++) {
          final nextName = prefs.getString('custom_preset_${j + 1}_name');
          final nextMinutes = prefs.getInt('custom_preset_${j + 1}_minutes');
          final nextIncrement = prefs.getInt(
            'custom_preset_${j + 1}_increment',
          );

          if (nextName != null &&
              nextMinutes != null &&
              nextIncrement != null) {
            await prefs.setString('custom_preset_${j}_name', nextName);
            await prefs.setInt('custom_preset_${j}_minutes', nextMinutes);
            await prefs.setInt('custom_preset_${j}_increment', nextIncrement);
          }
        }

        // Remove the last one
        await prefs.remove('custom_preset_${count - 1}_name');
        await prefs.remove('custom_preset_${count - 1}_minutes');
        await prefs.remove('custom_preset_${count - 1}_increment');
        await prefs.setInt('custom_presets_count', count - 1);

        // Reload presets
        await _loadSavedPresets();

        // Reset selection if deleted preset was selected
        if (isCustomMode &&
            customMinutes == preset.minutes &&
            customIncrement == preset.increment) {
          setState(() {
            isCustomMode = false;
            selectedPreset = null;
            selectedCategory = 'Bullet';
          });
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Preset deleted')));
        break;
      }
    }
  }

  Widget _buildPlayerNameOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showPlayerNameOverlay = false;
        });
      },
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap:
                () {}, // Prevent taps on the container from closing the overlay
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Player 1
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Player 1 Name :',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.active,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/white-queen.png',
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.king_bed,
                              color: AppColors.textPrimary,
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: player1Controller,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Player 1',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textSecondary,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textSecondary,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.active,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Player 2
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Player 2 Name :',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.active,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/black-queen.png',
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.king_bed,
                              color: Colors.black,
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: player2Controller,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Player 2',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textSecondary,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textSecondary,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.active,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Dice and Start buttons
                  Row(
                    children: [
                      // Circular Dice Button
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.inactive,
                          shape: BoxShape.circle,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _randomizePlayers,
                            borderRadius: BorderRadius.circular(28),
                            child: const Icon(
                              Icons.casino,
                              color: AppColors.active,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onFinalStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.active,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
