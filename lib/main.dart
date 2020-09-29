import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drag_drop_test/db/db_manager.dart';
import 'package:drag_drop_test/kanban_column.dart';
import 'package:drag_drop_test/models/task.dart';
import 'package:drag_drop_test/models/task_container.dart';
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
          if (snapShot.connectionState == ConnectionState.done)
            return buildApp();
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
  ScrollController _scrollController;
  int _listSize = 0;

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
    Future.delayed(Duration(seconds: 1), () {
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final taskContainer = await showCreateColumnDialog(context);
                if (taskContainer == null) return;
                DbManager.instance
                    .createTaskContainer(taskContainer, _listSize);
              }),
        ],
      ),
      body: StreamBuilder<List<TaskContainer>>(
          stream: DbManager.instance.allTaskColumnsStream,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Container();
            _listSize = snapshot.data.length;
            // return Center(
            //   child: FlatButton(child: Text("DElete"),onPressed: () async {
            //     for (var data in snapshot.data) {
            //       DbManager.instance.deleteAllTaskContainers(data.id);
            //     }
            //   },),
            // );
            return ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              semanticChildCount: snapshot.data.length,
              shrinkWrap: true,
              children: snapshot.data
                  .map((kanban) => KanbanColumn(
                        onScrollLeft: scrollLeft,
                        list1: kanban,
                        onScrollRight: scrollRight,
                        onItemInserted: (Task item, int index) {
                          setState(() {
                            // kanban.tasks.insert(index, item);
                            item.containerId = kanban.uid;
                            print("Added: ${item.uid} to ${kanban.uid} at $index");
                            DbManager.instance.createTask(item, index);
                          });
                        },
                        onItemRemoved: (Task item) {
                          setState(() {
                            print("Removed: ${item.uid}");
                            // kanban.tasks.remove(item);
                            DbManager.instance.deleteTask(item.uid);
                          });
                        },
                      ))
                  .toList(),
            );
          }),
    );
  }
}
