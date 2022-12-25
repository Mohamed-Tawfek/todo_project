import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../shared_component/shared.dart';
import '../states/states.dart';




class UnDoneScreen extends StatefulWidget {
  const UnDoneScreen({Key? key,}) : super(key: key) ;

  @override
  State<UnDoneScreen> createState() => _UnDoneScreenState();
}

class _UnDoneScreenState extends State<UnDoneScreen> {



  @override
  Widget build(BuildContext context)  {
    return BlocConsumer<TodoCubit, TodoState>(
      builder: (context, state) => Scaffold(
               body: ConditionalBuilder(
                              condition: TodoCubit.get(context).undoneTasks.isEmpty&&state is GetFromDatabaseStateLoading,
                              builder: (context2)=>const Center(child: CircularProgressIndicator()) ,
                              fallback: (context2)=> buildListOfTasks(context,
                              tasks: TodoCubit.get(context).undoneTasks)),



      ),
      listener: (context, state) {},
    );
  }
  }

