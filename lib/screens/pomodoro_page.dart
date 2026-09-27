import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  static const _focusMinutes = 25;
  static const _breakMinutes = 5;

  Timer? _timer;
  var _isFocus = true;
  var _isRunning = false;
  var _secondsRemaining = _focusMinutes * 60;
  var _completedSessions = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining <= 1) {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          if (_isFocus) _completedSessions++;
          _isFocus = !_isFocus;
          _secondsRemaining =
              (_isFocus ? _focusMinutes : _breakMinutes) * 60;
        });
      } else {
        setState(() => _secondsRemaining--);
      }
    });
    setState(() => _isRunning = true);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isFocus = true;
      _secondsRemaining = _focusMinutes * 60;
    });
  }

  void _skipPhase() {
    _timer?.cancel();
    setState(() {
      if (_isFocus) _completedSessions++;
      _isFocus = !_isFocus;
      _isRunning = false;
      _secondsRemaining = (_isFocus ? _focusMinutes : _breakMinutes) * 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return AppShell(
      index: 0,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHeader(
            title: 'Focus timer',
            subtitle: 'Work in focused blocks and take intentional breaks.',
            showBackButton: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Icon(
                      _isFocus ? Icons.menu_book_rounded : Icons.coffee_rounded,
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isFocus ? 'Focus session' : 'Short break',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$minutes:$seconds',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: _toggleTimer,
                          icon: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(_isRunning ? 'Pause' : 'Start'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _resetTimer,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset'),
                        ),
                        TextButton.icon(
                          onPressed: _skipPhase,
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Skip'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Completed focus sessions'),
              trailing: Text(
                '$_completedSessions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Tip: choose one small task before starting a session.'),
          ),
        ],
      ),
    );
  }
}
