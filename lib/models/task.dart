import 'package:flutter/material.dart';

class Task {
  String title;
  String text;
  String uid;
  String containerId;
  bool ghost;

  Task({
    @required this.title,
    @required this.text,
    @required this.uid,
    @required this.containerId,
  }) : ghost = false;

  Task.ghost()
      : this.title = "",
        this.text = "",
        this.uid = "",
        this.containerId = "",
        this.ghost = true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
