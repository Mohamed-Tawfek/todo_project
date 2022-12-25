import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import '../shared_component/shared.dart';
import '../states/states.dart';

class DoneNotesScreen extends StatefulWidget {
 const DoneNotesScreen({Key? key}) : super(key: key);

  @override
  State<DoneNotesScreen> createState() => _DoneNotesScreenState();
}

class _DoneNotesScreenState extends State<DoneNotesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoState>(
      builder: (context, state) => Scaffold(
          body: buildListOfTasks(context,
              tasks: TodoCubit.get(context).doneTasks, isDone: true)),
      listener: (context, state) {},
    );
  }
}
