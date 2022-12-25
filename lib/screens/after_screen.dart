import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import '../shared_component/shared.dart';
import '../states/states.dart';

class AfterScreen extends  StatelessWidget {
  const AfterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoState>(
      builder: (context, state) => Scaffold(
          body:ConditionalBuilder(
              condition: TodoCubit.get(context).dateAfter.isEmpty&&state is GetFromDatabaseStateLoading,
              builder: (context2)=>const Center(child: CircularProgressIndicator()) ,
              fallback: (context2)=>buildListOfTasks(context,
                  tasks: TodoCubit.get(context).dateAfter))),

      listener: (context, state) {},
    );
  }
  }
