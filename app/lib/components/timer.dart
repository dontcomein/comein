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
      child: Center(child: Text(_timeLeft())));

  String _timeLeft() {
    final difference = widget.endTime?.difference(DateTime.now());
    if (difference == null || difference.isNegative) return "0:0:0";
    final hours = difference.inHours;
    final minutes = difference.inMinutes - hours * 60;
    final seconds = difference.inSeconds - minutes * 60 - hours * 3600;
    return "$hours:$minutes:$seconds";
  }
}
