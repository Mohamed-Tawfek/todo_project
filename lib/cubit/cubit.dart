import 'dart:convert';
import 'dart:io';
 import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/cash_helper/cash_helper.dart';
import 'package:todo_app/states/states.dart';
import '../model/database_model.dart';

/// A `CounterCubit` which manages an `int` as its state.

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(InitialState());

  static TodoCubit get(BuildContext context) => BlocProvider.of(context);
  int? redValue;
  int? greenValue;
  int? blueValue;
  double? opacityValue;
dynamic codeOfTheImage;
  List<Map> dataInDatabase = [];
  List<DatabaseModel> allTasks = [];
  List<DatabaseModel> doneTasks = [];
  List<DatabaseModel> undoneTasks = [];
  List<DatabaseModel> dateBefore = [];
  List<DatabaseModel> dateAfter = [];

  void filterDoneAndUndoneTasks() {
    doneTasks = [];
    undoneTasks = [];
    dataInDatabase.forEach((element) {
      if (element['status'] == 'isDone') {
        doneTasks.add(DatabaseModel.fromMap(map: element));
      } else {
        undoneTasks.add(DatabaseModel.fromMap(map: element));
      }
    });
    doneTasks = doneTasks.reversed.toList();
    undoneTasks = undoneTasks.reversed.toList();
  }

  void filterDateBeforeAndAfterTasks() {
    dateBefore = [];
    dateAfter = [];
    allTasks.forEach((element) {
      if (DateTime.parse(element.date).isBefore(DateTime.now())) {
        dateBefore.add(element);
      } else {
        dateAfter.add(element);
      }
    });
    dateBefore = dateBefore.reversed.toList();
    dateAfter = dateAfter.reversed.toList();
  }

  filterTasks() {
    filterDoneAndUndoneTasks();
    filterDateBeforeAndAfterTasks();
  }

  static Database? database;

  final ImagePicker _picker = ImagePicker();

  Future<String> pickImage({required ImageSource imageSource}) async {
    final image = await _picker.pickImage(source: imageSource);
    return image!.path;
  }

  String? pathOfImage;


  static Future<void> createDatabase() async {
    database = await openDatabase('todo.db', version: 1,
        onCreate: (Database db, int version) async {
      await db
          .execute(
              'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, title TEXT,description TEXT,'
              'degreeOfBlue INTEGER ,degreeOfRed INTEGER,degreeOfGreen INTEGER,degreeOfOpacity DOUBLE ,time TEXT, date TEXT , status TEXT,codeTheImage TEXT)')
          .then((value) {
      });
    }, onOpen: (Database db) {
     });
  }

  Future<void> insertIntoDatabase({
    required String title,
    required String date,
    required String time,
    required String description,
    required String? codeTheImage,
    required int? degreeOfBlue,
    required int? degreeOfRed,
    required int? degreeOfGreen,
    required double? degreeOfOpacity,
  }) async {
    database!.insert('Tasks', {
      'title': title,
      'date': date,
      'description': description,
      'degreeOfBlue': degreeOfBlue,
      'degreeOfRed': degreeOfRed,
      'degreeOfGreen': degreeOfGreen,
      'degreeOfOpacity': degreeOfOpacity,
      'status': 'new',
      'time': time,
      'codeTheImage': codeTheImage
    }).then((value) async {

      codeOfTheImage=null;

      emit(InsertIntoDatabaseState());
       await getAllDataInDatabase();

    });
  }

   Future<void> getAllDataInDatabase() async {
    allTasks = [];
    doneTasks = [];
    undoneTasks = [];
    dateBefore = [];
    dateAfter = [];
    emit(GetFromDatabaseStateLoading());

    dataInDatabase = await database!.rawQuery('SELECT * FROM Tasks');
    for (var element in dataInDatabase) {
      allTasks.add(DatabaseModel.fromMap(map: element));

    }
      filterTasks();
       allTasks = allTasks.reversed.toList();
      emit(GetFromDatabaseStateSuccess());



  }

  Future updateRecord(
      {required int id, required updatingObject, required updatedValue}) async {
    await database!
        .rawUpdate('UPDATE Tasks SET "$updatingObject" = ? WHERE id = "$id"', [
      updatedValue,
    ]).then((value) {
   codeOfTheImage=null;
      emit(UpdateInDatabaseState());
      getAllDataInDatabase();
      return value;
    });
  }

  Future deleteAllRecords() async {
    await database!.rawDelete('DELETE FROM Tasks').then((value) {
      emit(DeleteFromState());
      getAllDataInDatabase();
    });

  }

  Future deleteASpecificRecord({required id}) async {

    await database!.rawDelete('DELETE FROM Tasks WHERE id = ?', ['$id']).then((value){
      emit(DeleteFromState());
      getAllDataInDatabase();
    } );

  }
  Future<void> chooseFromGallery()async{
  await pickImage(imageSource: ImageSource.gallery)
      .then((value) {
    pathOfImage = value;
});
  }
  Future<void> closeDatabase() async {
    await database!.close();
  }

  String encodeImage(File file) {


    return base64Encode(file.readAsBytesSync());
  }

  Uint8List decodeImage(String code) {

    return base64Decode(code);
  }

  buildColorsDialog(context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: ColorPicker(
                  onColorChanged: (color) {
                    redValue = color.red;
                    greenValue = color.green;
                    blueValue = color.blue;
                    opacityValue = color.opacity;
                  },
                  pickerColor: const Color.fromRGBO(202, 210, 242, 1.0),
                ),
              ),
              actions: [
                Center(
                    child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blue,
                ))
              ],
            ));
  }
static  bool? isDark;
  changeAppMode( ){
   isDark=!isDark!;
    if (kDebugMode) {
      print('Mode The app is : $isDark');
    }
  CashHelper.setData(key: 'isDark',value:isDark ).then((value) {
    emit(ChangeModeState());
   });
  }
}

