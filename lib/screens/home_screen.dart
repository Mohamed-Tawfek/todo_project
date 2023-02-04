import 'dart:io';

 import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart'as MBS;
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/screens/undone_screen.dart';
import 'package:todo_app/states/states.dart';
import '../shared_component/shared.dart';
import 'after_screen.dart';
import 'all_notes.dart';
import 'before_screen.dart';
import 'done_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController noteTitleController = TextEditingController();

  TextEditingController noteTimeController = TextEditingController();

  TextEditingController noteDateController = TextEditingController();

  TextEditingController noteDescriptionController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? _file;

  var valueOfDate;

// valueOfDate is contain unformatted date to compression
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoState>(
        listener: (context, state) {},
        builder: (context, state) {
          IconData icon = TodoCubit.isDark == true
              ? Icons.light_mode_rounded
              : Icons.dark_mode_outlined;
           return DefaultTabController(
            length: 5,
            initialIndex: 0,
            child: Scaffold(
                appBar: AppBar(
                  title: const Text('ToDo App'),
                  actions: [
                    IconButton(
                        onPressed: () {
                          TodoCubit.get(context).changeAppMode();
                        },
                        icon: Icon(icon)),
                    IconButton(
                        onPressed: () {
                          TodoCubit.get(context).deleteAllRecords();
                        },
                        icon: Icon(Icons.delete,
                        color: Colors.red,
                        )),
                  ],
                  bottom: TabBar(
                    tabs: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:   [
                          Icon(Icons.message),
                          Text(
                            'All',
                            maxLines: 1,
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.025),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:   [
                          const Icon(Icons.error_outline_outlined),
                          Text(
                            'UnDone',
                            maxLines: 1,
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.022),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:   [
                          const Icon(Icons.done),
                          Text(
                            'Done',
                            maxLines: 1,
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.025),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:   [
                          const Icon(Icons.watch_later_outlined),
                          Text(
                            'Before',
                            maxLines: 1,
                            style: TextStyle(fontSize:MediaQuery.of(context).size.width*0.025),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:   [
                          const Icon(Icons.alarm),
                          Text(
                            'After',
                            maxLines: 1,
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.025),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                body: const TabBarView(
                  children: <Widget>[
                    AllNotesScreen(),
                    UnDoneScreen(),
                    DoneNotesScreen(),
                    BeforeScreen(),
                    AfterScreen(),
                  ],
                ),
                floatingActionButton: FloatingActionButton.small(
                  backgroundColor: Colors.cyan,
                  child: const Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    MBS.showMaterialModalBottomSheet(
                        context: context,
                        builder: (context2) {
                          return customBottomSheet(
                            context,
                          );
                        });
                  },
                )),
          );
        });
  }

  Widget customBottomSheet(context) {
    return Form(
      key: formKey,
      child: Container(
        decoration: BoxDecoration(
          color: TodoCubit.isDark == true ? Colors.cyan : Colors.white,
        ),
        height: MediaQuery.of(context).size.height * 0.83,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const Text(
                'Add Note',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              customTextFormField(
                controller: noteTitleController,
                hint: 'Note Title',
              ),
              const SizedBox(
                height: 15,
              ),
              customTextFormField(
                  controller: noteDescriptionController,
                  hint: 'Note',
                  maxLines: 5),
              const SizedBox(
                height: 15,
              ),
              const SizedBox(
                height: 15,
              ),
              customTextFormField(
                  controller: noteDateController,
                  hint: 'Select Date',
                  prefix: const Icon(
                    Icons.calendar_month,
                    color: Colors.black,
                  ),
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.parse('2010-04-04'),
                            lastDate: DateTime.parse('2100-04-04'))
                        .then((value) {
                      valueOfDate = value;
                      noteDateController.text =
                          DateFormat.yMMMMd().format(value!);
                      showTimePicker(
                              context: context, initialTime: TimeOfDay.now())
                          .then((value) {
                        noteTimeController.text = value!.format(context);
                        noteDateController.text =
                            '${noteDateController.text} - ${noteTimeController.text}';
                      });
                    });
                  },
                  keyboardType: TextInputType.none),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                      onPressed: () {
                        TodoCubit.get(context).buildColorsDialog(context);
                      },
                      child: const Text(
                        'Note Color',
                        style: TextStyle(color: Colors.black),
                      )),
                  InkWell(
                      onTap: () {
                        TodoCubit.get(context).chooseFromGallery().then((value) {
                          if (TodoCubit.get(context).pathOfImage != null) {
                            _file = File(TodoCubit.get(context).pathOfImage!);
                   TodoCubit.get(context).codeOfTheImage = TodoCubit.get(context).encodeImage(_file!);
                          } else {
                            if (kDebugMode) {
                              print('Image is null !!!');
                            }
                          }
                        });
                      },
                      child: TodoCubit.get(context).codeOfTheImage != null
                          ? Image.memory(
                              TodoCubit.get(context).decodeImage(TodoCubit.get(context).codeOfTheImage),
                              height: 100,
                              width: 100,
                            )
                          : Container(
                              height: 90,
                              width: 100,
                              color: TodoCubit.isDark == true
                                  ? Colors.white70
                                  : Colors.grey[200],
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                              ),
                            ))
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              MaterialButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {

                      await TodoCubit.get(context)
                          .insertIntoDatabase(
                              date: valueOfDate.toString(),
                              title: noteTitleController.text,
                              time: noteTimeController.text,
                              degreeOfBlue:
                                  TodoCubit.get(context).blueValue ?? 157,
                              degreeOfGreen:
                                  TodoCubit.get(context).greenValue ?? 144,
                              degreeOfRed:
                                  TodoCubit.get(context).redValue ?? 140,
                              degreeOfOpacity:
                                  TodoCubit.get(context).opacityValue ?? 1.0,
                              codeTheImage: TodoCubit.get(context).codeOfTheImage,
                              description: noteDescriptionController.text)
                          .then((value) {
                        TodoCubit.get(context).blueValue = null;
                        TodoCubit.get(context).greenValue = null;
                        TodoCubit.get(context).redValue = null;
                        TodoCubit.get(context).opacityValue = null;
                        valueOfDate = null;
                        noteTimeController.clear();
                        noteDateController.clear();
                        noteTitleController.clear();
                        noteDescriptionController.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'A task has been created successfully')));
                      });

                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
                color: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
