import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/states/states.dart';

import 'cash_helper/cash_helper.dart';
import 'cubit/observer.dart';

void main() async {
  BlocOverrides.runZoned(
        () async {
      WidgetsFlutterBinding.ensureInitialized();
      await TodoCubit.createDatabase();
      await CashHelper.init();

      TodoCubit.isDark = CashHelper.getData(key: 'isDark') ?? false;
      runApp(const TodoApp());
    },
    blocObserver: MyBlocObserver(),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (context)  {
        return   TodoCubit()
          ..getAllDataInDatabase();
      },
      child: BlocConsumer<TodoCubit, TodoState>(
        builder: (context, state) =>
            MaterialApp(
              darkTheme: ThemeData.dark(),
              theme: ThemeData.light(),
              themeMode: TodoCubit.isDark == true ? ThemeMode.dark : ThemeMode
                  .light,
              debugShowCheckedModeBanner: false,
              home: const HomeScreen(),

            ),
        listener: (context, state) {},
      ),

    );
  }
}











