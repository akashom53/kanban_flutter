import 'package:drag_drop_test/models/task.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class TaskContainer {
  String title;
  String uid;
  int index;

  List<Task> tasks = [];

  TaskContainer({
    @required this.title,
    @required this.uid,
  });

  TaskContainer.fromMap(Map<String, dynamic> map) {
    this.title = map['title'];
    this.uid = map['uid'];
    this.index = map['index'];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskContainer &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
