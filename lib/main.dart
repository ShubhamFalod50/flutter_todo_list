import 'package:flutter/material.dart';
import 'package:todo_list/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
          colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple,
              onBackground: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.white,
           ),
           dialogBackgroundColor: Colors.black,
           textButtonTheme: TextButtonThemeData(
               style: TextButton.styleFrom(primary: Colors.deepPurple)
           )
          ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Todo List'),
    );
}}