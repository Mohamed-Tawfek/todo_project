import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:todo_app/model/database_model.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/states/states.dart';

import '../cubit/cubit.dart';
import '../shared_component/shared.dart';

class EditAndDisplayTask extends StatelessWidget {
  DatabaseModel model;

  EditAndDisplayTask({Key? key, required this.model}) : super(key: key);

  TextEditingController noteTitleController = TextEditingController();

  TextEditingController noteTimeController = TextEditingController();

  TextEditingController noteDateController = TextEditingController();

  TextEditingController noteDescriptionController = TextEditingController();

  File? _file;

  var valueOfDay;

// valueOfDay is contain unformatted date to compression
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoState>(
        builder: (context2, state) {
          late Uint8List image;
          if (model.codeTheImage != null) {
            image = TodoCubit.get(context2).decodeImage(model.codeTheImage);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(model.title),
              actions: [
                IconButton(
                    onPressed: () {
                      showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              customBottomSheet(context2, context));
                    },
                    icon: const Icon(Icons.edit))
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: model.codeTheImage != null
                      ? Image.memory(
                          image,
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 0.8,
                        )
                      : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                            'assets/picture.png',


                          ),
                      ),
                ),
                Expanded(
                  child: Text(
                    model.description,
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),

              ],
            ),
          );
        },
        listener: (context, state) {});
  }

  Widget customBottomSheet(context2, context) {
    noteTitleController.text = model.title;
    noteDescriptionController.text = model.description;

    String viewDateAndTime = '${model.formattedDate} - ${model.time}';
    noteDateController.text = viewDateAndTime;

    return Container(
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
              style: TextStyle(fontSize: 25.0, color: Colors.black),
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
                fillColor: Colors.white,
                prefix: const Icon(
                  Icons.calendar_month,
                  color: Colors.black,
                ),
                onTap: () {
                  showDatePicker(
                          context: context2,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.parse('2010-04-04'),
                          lastDate: DateTime.parse('2100-04-04'))
                      .then((value) {
                    valueOfDay = value;
                    noteDateController.text =
                        DateFormat.yMMMMd().format(value!);
                    showTimePicker(
                            context: context2, initialTime: TimeOfDay.now())
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
                        if (TodoCubit.get(context2).pathOfImage != null) {
                          _file = File(TodoCubit.get(context2).pathOfImage!);
                          TodoCubit.get(context).codeOfTheImage =
                              TodoCubit.get(context2).encodeImage(_file!);
                        } else {
                          if (kDebugMode) {
                            print('Image is null !!!');
                          }
                        }
                      });
                    },
                    child: TodoCubit.get(context).codeOfTheImage != null
                        ? Image.memory(
                            TodoCubit.get(context2).decodeImage(
                                TodoCubit.get(context).codeOfTheImage),
                            height: 100,
                            width: 100,
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                            ),
                          ))
              ],
            ),
            MaterialButton(
              onPressed: () async {
                if (TodoCubit.get(context).codeOfTheImage != null) {
                  await TodoCubit.get(context2)
                      .updateRecord(
                          id: model.id,
                          updatingObject: 'codeTheImage',
                          updatedValue: TodoCubit.get(context).codeOfTheImage)
                      .then((value) {
                    TodoCubit.get(context).codeOfTheImage = null;
                  });
                }

                if (noteTitleController.text.isNotEmpty) {
                  await TodoCubit.get(context2)
                      .updateRecord(
                          id: model.id,
                          updatingObject: 'title',
                          updatedValue: noteTitleController.text)
                      .then((value) {
                    noteTitleController.clear();
                  });
                }

                if (valueOfDay != null) {
                  await TodoCubit.get(context2)
                      .updateRecord(
                          id: model.id,
                          updatingObject: 'date',
                          updatedValue: valueOfDay.toString())
                      .then((value) {
                    noteTitleController.clear();
                  });
                }
                if (noteTimeController.text.isNotEmpty) {
                  await TodoCubit.get(context2)
                      .updateRecord(
                          id: model.id,
                          updatingObject: 'time',
                          updatedValue: noteTimeController.text)
                      .then((value) {
                    noteTimeController.clear();
                  });
                }

                if (noteDescriptionController.text.isNotEmpty) {
                  await TodoCubit.get(context2)
                      .updateRecord(
                          id: model.id,
                          updatingObject: 'description',
                          updatedValue: noteDescriptionController.text)
                      .then((value) {
                    noteTitleController.clear();
                  });
                }

                if (TodoCubit.get(context2).opacityValue != null) {
                  await TodoCubit.get(context2)
                      .updateRecord(
                          id: model.id,
                          updatingObject: 'degreeOfOpacity',
                          updatedValue: TodoCubit.get(context2).opacityValue)
                      .then((value) {
                    TodoCubit.get(context2).opacityValue = null;
                  });
                }

                if (TodoCubit.get(context2).redValue != null) {
                  await TodoCubit.get(context2)
                      .updateRecord(
                          id: model.id,
                          updatingObject: 'degreeOfRed',
                          updatedValue: TodoCubit.get(context2).redValue)
                      .then((value) {
                    TodoCubit.get(context2).redValue = null;
                  });
                }
                if (TodoCubit.get(context2).greenValue != null) {
                  await TodoCubit.get(context2)
                      .updateRecord(
                          id: model.id,
                          updatingObject: 'degreeOfGreen',
                          updatedValue: TodoCubit.get(context2).greenValue)
                      .then((value) {
                    TodoCubit.get(context2).greenValue = null;
                  });
                }
                if (TodoCubit.get(context2).blueValue != null) {
                  await TodoCubit.get(context2)
                      .updateRecord(
                          id: model.id,
                          updatingObject: 'degreeOfBlue',
                          updatedValue: TodoCubit.get(context2).blueValue)
                      .then((value) {
                    TodoCubit.get(context2).blueValue = null;
                  });
                }
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('The task has been successfully edited')));
              },
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
              color: Colors.teal,
            )
          ],
        ),
      ),
    );
  }

// Widget customTextFormField(
//     {required TextEditingController controller,
//     TextInputType? keyboardType,
//     required String hint,
//     prefix,
//     fillColor,
//     GestureTapCallback? onTap,
//     int maxLines = 1}) {
//   return Container(
//     decoration: const BoxDecoration(
//         borderRadius: BorderRadius.only(
//       topRight: Radius.circular(10),
//       topLeft: Radius.circular(10),
//     )),
//     child: TextFormField(
//       style: const TextStyle(color: Colors.black),
//       onTap: onTap,
//       validator: (data) {
//         if (data!.isEmpty) {
//           return 'This Field Must Not Be Empty';
//         }
//         return null;
//       },
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixIcon: prefix,
//         hintStyle: const TextStyle(color: Colors.black),
//         fillColor:
//             TodoCubit.isDark == true ? Colors.white70 : Colors.grey[300],
//         filled: true,
//       ),
//     ),
//   );
// }
}
