import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LifeAtStudyScreen extends StatefulWidget {
  const LifeAtStudyScreen({super.key});

  @override
  State<LifeAtStudyScreen> createState() => _LifeAtStudyScreenState();
}

class _LifeAtStudyScreenState extends State<LifeAtStudyScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _pulseController;
  
  final int _pomodoroMinutes = 25;
  final int _breakMinutes = 5;
  int _currentSeconds = 0;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedSessions = 0;
  
  String _selectedMusic = 'None';
  String _selectedBackground = 'Default';
  
  final List<String> _musicOptions = [
    'None',
    'Rain Sounds',
    'White Noise',
    'Forest Ambience',
    'Cafe Sounds',
    'Ocean Waves',
  ];
  
  final List<String> _backgroundOptions = [
    'Default',
    'Forest',
    'Mountain',
    'Ocean',
    'Cafe',
    'Library',
  ];

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _timerController.addListener(() {
      if (_isRunning) {
        setState(() {
          if (_currentSeconds > 0) {
            _currentSeconds--;
          } else {
            _handleTimerComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTimerComplete() {
    if (_isBreak) {
      // Break completed, start work session
      setState(() {
        _isBreak = false;
        _currentSeconds = _pomodoroMinutes * 60;
        _completedSessions++;
      });
    } else {
      // Work session completed, start break
      setState(() {
        _isBreak = true;
        _currentSeconds = _breakMinutes * 60;
      });
    }
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
        if (_currentSeconds == 0) {
          _currentSeconds = _pomodoroMinutes * 60;
        }
      });
      _timerController.repeat();
    }
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timerController.stop();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _currentSeconds = _pomodoroMinutes * 60;
    });
    _timerController.stop();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text(
          'LifeAt Study',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Timer Section
            _buildTimerSection(),
            const SizedBox(height: 24),
            
            // Controls Section
            _buildControlsSection(),
            const SizedBox(height: 24),
            
            // Settings Section
            _buildSettingsSection(),
            const SizedBox(height: 24),
            
            // Statistics Section
            _buildStatisticsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.dominantPurple,
            AppColors.dominantPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.dominantPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _isBreak ? 'Break Time' : 'Focus Time',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Text(
                  _formatTime(_currentSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _isBreak ? 'Take a short break' : 'Stay focused and productive',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _isRunning ? _pauseTimer : _startTimer,
          icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
          label: Text(_isRunning ? 'Pause' : 'Start'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRunning ? Colors.orange : AppColors.dominantPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _resetTimer,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Music Selection
          Row(
            children: [
              Icon(Icons.music_note, color: AppColors.dominantPurple),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMusic,
                  decoration: const InputDecoration(
                    labelText: 'Background Music',
                    border: OutlineInputBorder(),
                  ),
                  items: _musicOptions.map((music) {
                    return DropdownMenuItem(
                      value: music,
                      child: Text(music),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMusic = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Background Selection
          Row(
            children: [
              Icon(Icons.image, color: AppColors.dominantPurple),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedBackground,
                  decoration: const InputDecoration(
                    labelText: 'Study Background',
                    border: OutlineInputBorder(),
                  ),
                  items: _backgroundOptions.map((bg) {
                    return DropdownMenuItem(
                      value: bg,
                      child: Text(bg),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBackground = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed Sessions',
                  _completedSessions.toString(),
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Focus Time',
                  '${(_completedSessions * _pomodoroMinutes)} min',
                  Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.dominantPurple, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 