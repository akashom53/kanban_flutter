import 'package:drag_drop_test/db/db_manager.dart';
import 'package:drag_drop_test/kanban_column.dart';
import 'package:drag_drop_test/models/task.dart';
import 'package:drag_drop_test/models/task.dart';
import 'package:drag_drop_test/models/task.dart';
import 'package:drag_drop_test/models/task.dart';
import 'package:drag_drop_test/models/task.dart';
import 'package:drag_drop_test/models/task.dart';
import 'package:drag_drop_test/models/task_container.dart';
import 'package:drag_drop_test/reorder_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  Widget buildApp() => MyHomePage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kanban Board",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapShot) {
          if (snapShot.hasError) return buildErrorPage();
          if (snapShot.connectionState == ConnectionState.done) return buildApp();
          return buuildLoading();
        },
      ),
    );
  }

  Widget buildErrorPage() => Scaffold(
        body: Center(
          child: Text("Error initializing Firebase"),
        ),
      );

  Widget buuildLoading() => Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TaskContainer> _kanbanColumns = [];

  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  void scrollRight() {
    _scrollController.animateTo(_scrollController.offset + 100,
        duration: Duration(milliseconds: 100), curve: Curves.linear);
  }

  void scrollLeft() {
    _scrollController.animateTo(_scrollController.offset - 100,
        duration: Duration(milliseconds: 100), curve: Curves.linear);
  }

  Future<TaskContainer> showCreateColumnDialog(BuildContext context) async {
    final titleController = TextEditingController();
    return showDialog<TaskContainer>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create Column"),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(hintText: "Title"),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              final uid =
                  DateTime.now().millisecond.toString() + titleController.text;
              final taskContainer =
                  TaskContainer(title: titleController.text, uid: uid);
              Navigator.of(context).pop(taskContainer);
            },
            child: Text("Create"),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                DbManager.instance.fetchColumns();
                final taskContainer = await showCreateColumnDialog(context);
                if (taskContainer == null) return;
                DbManager.instance.createTaskContainer(taskContainer);
                setState(() {
                  _kanbanColumns.add(taskContainer);
                });
              }),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        semanticChildCount: 5,
        shrinkWrap: true,
        children: _kanbanColumns
            .map((kanban) => KanbanColumn(
                  onScrollLeft: scrollLeft,
                  list1: kanban,
                  onScrollRight: scrollRight,
                  onItemInserted: (Task item, int index) {
                    setState(() {
                      kanban.tasks.insert(index, item);
                    });
                  },
                  onItemRemoved: (Task item) {
                    setState(() {
                      kanban.tasks.remove(item);
                    });
                  },
                ))
            .toList(),
      ),
    );
  }
}
