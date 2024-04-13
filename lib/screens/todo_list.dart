import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crud/screens/add_page.dart';
import 'package:flutter_crud/services/todo_services.dart';
import 'package:flutter_crud/utils/snackbar_helper.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];

  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                "No todo items",
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        item['title'],
                      ),
                      subtitle: Text(
                        item['description'],
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            navigateToEditPage(item);
                          } else if (value == 'delete') {
                            deleteById(id);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text("Edit"),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text("Delete"),
                            )
                          ];
                        },
                      ),
                    ),
                  );
                }),
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToAddPage();
        },
        label: const Text('Add Todo'),
      ),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route =
        MaterialPageRoute(builder: (context) => AddTodoPage(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => AddTodoPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    final success = await TodoService.deleteById(id);

    if (success) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage(context, message:'Error deleting');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchTodo() async {
    final response = await TodoService.fetchTodo();

    if (response != null) {
      setState(() {
        items = response;
      });
    } else {
      showErrorMessage(context, message: "Something went wrong");
    }

    setState(() {
      isLoading = false;
    });
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


}
