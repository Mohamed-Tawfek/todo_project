// this file contain component is shared in all application
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/screens/edit_task_screen.dart';
import '../cubit/cubit.dart';
import '../model/database_model.dart';

Widget buildListOfTasks(context, {required List tasks, bool? isDone}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: ListView.separated(
        itemBuilder: (context, index) => buildTaskItem(
            model: tasks[index], index: index, context: context, isDone: isDone),
        separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: 1,
                width: MediaQuery.of(context).size.width,
              ),
            ),
        itemCount: tasks.length),
  );
}

Widget buildTaskItem(
    {required int index,
    required DatabaseModel model,
    required context,
    bool? isDone}) {
  return Dismissible(
    background: Container(
      color: isDone == true ? Colors.red : Colors.green,
      child: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            isDone == true ? Icons.remove : Icons.done,
            size: 40.0,
          )),
    ),
    key: UniqueKey(),
    direction: DismissDirection.endToStart,
    onDismissed: (direction) {
      if (isDone == true) {
        TodoCubit.get(context).updateRecord(
            id: model.id, updatingObject: 'status', updatedValue: 'new');
      } else {
        TodoCubit.get(context).updateRecord(
            id: model.id, updatingObject: 'status', updatedValue: 'isDone');
      }
    },
    child: InkWell(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Are You Sure?!'),
                  content: const Text('Do you want to remove this note?'),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditAndDisplayTask(
                                      model: model,
                                    )));
                      },
                      child: const Text('No'),
                    ),
                    MaterialButton(
                      onPressed: () {
                        TodoCubit.get(context)
                            .deleteASpecificRecord(id: model.id)
                            .then((value) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'The task has been successfully deleted')));
                        });
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ));
      },
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context2) => EditAndDisplayTask(
                      model: model,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          color: Color.fromRGBO(model.degreeOfRed, model.degreeOfGreen,
              model.degreeOfBlue, model.degreeOfOpacity),
          child: ListTile(
            leading: Container(
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
              ),
            ),
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.title,
                      style: const TextStyle(fontSize: 25),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ' ${model.description}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    )
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      ' ${model.formattedDate}',
                      style:   TextStyle(fontSize: MediaQuery.of(context).size.width*0.04,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ' ${model.time}',
                      style:   TextStyle(fontSize: MediaQuery.of(context).size.width*0.04,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget customTextFormField(
    {required TextEditingController controller,
    TextInputType? keyboardType,
    required String hint,
    prefix,
    fillColor,
    GestureTapCallback? onTap,
    int maxLines = 1}) {
  return Container(
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
      topRight: Radius.circular(10),
      topLeft: Radius.circular(10),
    )),
    child: TextFormField(
      style: const TextStyle(color: Colors.black),
      onTap: onTap,
      validator: (data) {
        if (data!.isEmpty) {
          return 'This Field Must Not Be Empty';
        }
        return null;
      },
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix,
        hintStyle: const TextStyle(color: Colors.black),
        fillColor: TodoCubit.isDark == true ? Colors.white70 : Colors.grey[300],
        filled: true,
      ),
    ),
  );
}
