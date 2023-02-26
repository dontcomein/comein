import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  const Timer(this.endTime, {super.key});
  final DateTime? endTime;
  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            _timeLeft(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
      );

  String _timeLeft() {
    final difference = widget.endTime?.difference(DateTime.now());
    if (difference == null || difference.isNegative) return "0:00:00";
    final hours = difference.inHours;
    final minutes = difference.inMinutes - hours * 60;
    final seconds = difference.inSeconds - minutes * 60 - hours * 3600;
    final paddedMins = (minutes < 10) ? "0$minutes" : "$minutes";
    final paddedSecs = (seconds < 10) ? "0$seconds" : "$seconds";
    return "$hours:$paddedMins:$paddedSecs";
  }
}
