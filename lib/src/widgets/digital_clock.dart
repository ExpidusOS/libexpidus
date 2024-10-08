import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef ClockPulseCallback = DateTime Function(BuildContext context);

DateTime _defaultClockPulse(BuildContext _) => DateTime.now();

class DigitalClock extends StatefulWidget {
  const DigitalClock.periodic({
    super.key,
    this.duration = const Duration(seconds: 1),
    this.format,
    ClockPulseCallback onPulse = _defaultClockPulse,
  })  : dateTime = null,
        this.onPulse = onPulse;

  const DigitalClock.fixed({
    super.key,
    this.format,
    required DateTime dateTime,
  })  : duration = null,
        onPulse = null,
        this.dateTime = dateTime;

  final Duration? duration;
  final DateFormat? format;
  final DateTime? dateTime;
  final ClockPulseCallback? onPulse;

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  Timer? _pulse;
  DateTime? _time;

  DateTime? get time => widget.dateTime ?? _time;

  @override
  void initState() {
    super.initState();

    if (widget.duration != null) {
      _pulse = Timer.periodic(widget.duration!, (_) {
        setState(() {
          _time = widget.onPulse!(context);
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (_pulse != null) {
      _pulse!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) => time != null
      ? Text((widget.format ?? DateFormat.jms()).format(time!))
      : const SizedBox();
}
