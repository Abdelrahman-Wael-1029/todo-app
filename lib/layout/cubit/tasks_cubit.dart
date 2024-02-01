import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/task/task_model.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  List<TaskModel> lateTasks = [];
  List<TaskModel> tasks = [];
  late Database database;
  DateTime selectedDate = DateTime.now();
  int currentIndex = 0;

  final List states = [
    'task',
    'done',
  ];

  TasksCubit() : super(TasksInitial()) {
    createDataBase();
  }
  // for return same object from tasks cubit
  static TasksCubit get(context) {
    return BlocProvider.of(context);
  }

  void screenChange(newIndex) {
    currentIndex = newIndex;
    emit(ScreenChange());
    getTasks(database);
  }

  void dateChange(newDate) {
    selectedDate = newDate;
    emit(DateChange());
    getTasks(database);
  }

  List<TaskModel> toTaskModel(all) {
    List<TaskModel> allTasks = [];

    for (var task in all[0] as List) {
      allTasks.add(TaskModel.fromJson(task));
    }
    return allTasks;
  }

  // Future<List<TaskModel>> getTasks(
  //   database, {
  //   where,
  //   whereArgs,
  // }) async {
  //   var all = await selectDataBase(
  //     database,
  //     'tasks',
  //     where: where,
  //     whereArgs: whereArgs,
  //   );
  //   return toTaskModel(all);
  // }

  void addNewTask({
    required String title,
    required String time,
    required String state,
  }) {
    insertDataBase('tasks', column: [
      'title',
      'date',
      'time',
      'state',
    ], values: [
      title,
      '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
      time,
      state
    ]).then((value) {
      emit(AddNewTask());
    }).then((value) {
      getTasks(database);
    }).catchError((err) {
      tasks = [];
    });
  }

  void getTasks(
    database,
  ) {
    selectDataBase(
      database,
      'tasks',
      where: 'date = ? and state = ?',
      whereArgs: [
        '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
        states[currentIndex],
      ],
    ).then((value) {
      tasks = toTaskModel(value);
      emit(GetDatabase());
    }).catchError((err) {
      tasks = [];
    });
  }

  void getLateTasks(database) {
    selectDataBase(
      database,
      'tasks',
      where: 'date < ? and state = task',
      whereArgs: [
        '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
      ],
    ).then((value) {
      lateTasks = toTaskModel(value);
      emit(GetLateDatabase());
    }).catchError((err) {
      lateTasks = [];
      debugPrint("error in late tasks");
    });
  }

  void updateTasks(
    column,
    values, {
    where,
    whereArgs,
  }) {
    updateDataBase(
      'tasks',
      column: column,
      values: values,
      where: where,
      whereArgs: whereArgs,
    ).then((value) {
      emit(UpdateTask());
      getTasks(database);
    }).catchError((err) {
      tasks = [];
    });
  }

  void deleteTask({
    required String where,
    required List whereArgs,
  }) {
    deleteDatabase(
      'tasks',
      where: where,
      whereArgs: whereArgs,
    ).then((value) {
      emit(DeleteTask());
      getTasks(database);
    }).catchError((err) {
      tasks = [];
    });
  }

  void createDataBase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (Database database, int version) {
        database.execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT null, state TEXT)',
        );
      },
      onOpen: (database) {
        getTasks(database);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDataBase());
    });
  }

  Future<List<Object?>> insertDataBase(
    String table, {
    required List column,
    required List values,
  }) async {
    var batch = database.batch();

    var mp = <String, Object?>{};
    for (int i = 0; i < column.length; i++) {
      mp[column[i]] = values[i];
    }
    batch.insert(table, mp);
    return await batch.commit();
  }

  Future<List<Object?>> updateDataBase(
    String table, {
    required List column,
    required List values,
    String? where,
    List? whereArgs,
  }) async {
    var mp = <String, Object?>{};
    for (int i = 0; i < column.length; i++) {
      mp[column[i]] = values[i];
    }
    var batch = database.batch();

    batch.update(
      table,
      mp,
      where: where,
      whereArgs: whereArgs,
    );
    return await batch.commit();
  }

  Future<List<Object?>> selectDataBase(
    Database database,
    String table, {
    List<String>? column,
    String? where,
    List? whereArgs,
  }) async {
    var batch = database.batch();
    batch.query(
      table,
      columns: column,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'time',
    );
    return await batch.commit();
  }

  Future<List<Object?>> deleteDatabase(
    String table, {
    String? where,
    List? whereArgs,
  }) async {
    var batch = database.batch();
    batch.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
    return await batch.commit();
  }
}
