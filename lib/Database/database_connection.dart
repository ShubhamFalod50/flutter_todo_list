import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseConnection
{
  setDatabase() async{
     var directory = await getApplicationDocumentsDirectory();
     var path = join(directory.path,"db_todolist.db");
    
     var database = await openDatabase(path, version: 1, onCreate: _createDatabase);
     return database;
  }

  //For creating tables
  _createDatabase(Database database, int version) async
  {
       await database.execute(
         "CREATE TABLE Listtype(id INTEGER PRIMARY KEY, name TEXT, color TEXT)"
       );
       await database.execute(
         "CREATE TABLE Task(id INTEGER PRIMARY KEY, name TEXT, listid INTEGER, day TEXT)"
       );
       await database.transaction((txn) async {
          await txn.rawInsert('INSERT INTO ListType(name,color) VALUES("All","4284955319")');
          await txn.rawInsert('INSERT INTO ListType(name,color) VALUES("Today","4284955319")');
          await txn.rawInsert('INSERT INTO ListType(name,color) VALUES("Tasks","4284955319")');
       }); 
  }
}