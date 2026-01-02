import 'package:flutter/material.dart';

class PhaseRecord {
 final String stageName;
 final int amount;
 final String uid;
 final DateTime startDate;
 final DateTime endDate;
 final Color color;
 PhaseRecord({required this.stageName, required this.amount, required this.uid, required this.startDate, required this.endDate, required this.color});
}
final List<PhaseRecord> records = [
  PhaseRecord(
    stageName: 'Phase 1',
    amount: 100,
    uid: 'abc123',
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    color: Colors.blue,
  ),
  PhaseRecord(
    stageName: 'Phase 2',
    amount: 200,
    uid: 'def456',
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    color: Colors.red,
  ),
];
