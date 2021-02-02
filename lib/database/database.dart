 // database.dart

 // required package imports
 import 'dart:async';
 import 'package:floor/floor.dart';
 import 'package:sqflite/sqflite.dart' as sqflite;

 import 'dao/user_dao.dart';
 import 'entity/user.dart';

 part 'database.g.dart'; // the generated code will be there

 @Database(version: 1, entities: [User])
 abstract class AppDatabase extends FloorDatabase {
   UserDao get userDao;
 }