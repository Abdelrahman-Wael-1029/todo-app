import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/components/componants.dart';

import '../../modules/done/done.dart';
import '../../modules/tasks/tasks.dart';
import '../../shared/components/constants.dart';
import '../cubit/tasks_cubit.dart';

// ignore: must_be_immutable
class HomeLayout extends StatelessWidget {
  HomeLayout({super.key});

  final controllerDatePicker = DatePickerController();

  var addTaskKey = GlobalKey<FormState>();

  TextEditingController timeCtl = TextEditingController();
  TextEditingController titleCtl = TextEditingController();

  List<BottomNavigationBarItem> bottomsItem = [
    const BottomNavigationBarItem(
      icon: Icon(
        Icons.menu,
      ),
      label: "Tasks",
      activeIcon: Icon(
        Icons.menu_open,
      ),
    ),
    const BottomNavigationBarItem(
      icon: Icon(
        Icons.done_outline,
      ),
      label: "Done",
      activeIcon: Icon(
        Icons.done,
      ),
    ),
  ];
  List screens = [
    const Tasks(),
    const Done(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TasksCubit(),
      child: BlocConsumer<TasksCubit, TasksState>(
        listener: (context, state) {
          if (state is AppCreateDataBase) {
            try {
              controllerDatePicker.animateToDate(
                DateTime.now(),
              );
              // ignore: empty_catches
            } catch (e) {}
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: MAIN_COLOR,
              title: const Text(
                "Todo app",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${TasksCubit.get(context).selectedDate.year}-${TasksCubit.get(context).selectedDate.month}-${TasksCubit.get(context).selectedDate.day}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 90,
                          child: DatePicker(
                            firstDate,
                            controller: controllerDatePicker,
                            initialSelectedDate:
                                TasksCubit.get(context).selectedDate,
                            selectionColor: MAIN_COLOR,
                            selectedTextColor: Colors.white,
                            daysCount: lastDate.difference(firstDate).inDays,
                            onDateChange: (date) {
                              TasksCubit.get(context).dateChange(date);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    screens[TasksCubit.get(context).currentIndex],
                    const SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
            // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                // Navigator.push(context, MaterialPageRoute(builder:(context) => const NewTask()));
                bottomSheet(
                  context,
                  textButton: "Add Task",
                  formKey: addTaskKey,
                  titleCtl: titleCtl,
                  timeCtl: timeCtl,
                  onPressed: () {
                    if (addTaskKey.currentState!.validate()) {
                      TasksCubit.get(context).addNewTask(
                        title: titleCtl.text,
                        time: timeCtl.text,
                        state: 'task',
                      );
                      timeCtl.clear();
                      titleCtl.clear();
                      Navigator.pop(context);
                    }
                  },
                );
              },
              backgroundColor: Colors.lightBlue[900],
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: bottomsItem,
              backgroundColor: Colors.white,
              fixedColor: MAIN_COLOR,
              currentIndex: TasksCubit.get(context).currentIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (value) {
                TasksCubit.get(context).screenChange(value);
              },
            ),
          );
        },
      ),
    );
  }
}
