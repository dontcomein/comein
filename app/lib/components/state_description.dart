import 'package:comein/components/timer.dart';
import 'package:comein/main.dart';
import 'package:comein/models/room_state.dart';
import 'package:flutter/material.dart';

class StateDescription extends StatelessWidget {
  const StateDescription(this.state, {super.key});
  final RoomState? state;
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            state?.name ?? unknown,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (state?.isComeIn != true) Timer(state?.endTime),
          Text(
            state?.description ?? unknown,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
}
