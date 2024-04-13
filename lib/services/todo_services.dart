import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crud/screens/add_page.dart';
import 'package:http/http.dart' as http;

class TodoService {
  static Future<bool> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';

    final response = await http.delete(Uri.parse(url));

    return response.statusCode == 200;
  }

  static Future<List?> fetchTodo() async {
    const url = "https://api.nstack.in/v1/todos?page=1&limit=10";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      return result;
    } else {
      return null;
    }
  }
}
