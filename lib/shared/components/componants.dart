import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/components/constants.dart';
import '../../layout/cubit/tasks_cubit.dart';

import '../../models/task/task_model.dart';

Widget showTasks(
  context, {
  required bool isDone,
  required bool isEdit,
  required bool isDelete,
}) {
  return ConditionalBuilder(
    condition: TasksCubit.get(context).tasks.isNotEmpty,
    builder: (context) => ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: TasksCubit.get(context).tasks.length,
      itemBuilder: (context, index) {
        return buildTask(
          TasksCubit.get(context).tasks[index],
          context,
          isDone: isDone,
          isEdit: isEdit,
          isDelete: isDelete,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        height: 10,
      ),
    ),
    fallback: (context) => const Center(
      child: Text(
        "No tasks yet",
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    ),
  );
}

Widget buildTask(
  TaskModel taskModel,
  context, {
  required bool isDone,
  required bool isEdit,
  required bool isDelete,
}) {
  String time = taskModel.time;
  String title = taskModel.title;
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              ConditionalBuilder(
                condition: time.isNotEmpty,
                builder: (context) => Text(
                  "due $time",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                fallback: null,
              ),
            ],
          ),
        ),
        ConditionalBuilder(
          condition: isEdit,
          builder: (context) => IconButton(
            onPressed: () {
              var editKey = GlobalKey<FormState>();
              TextEditingController timeCtl = TextEditingController();
              TextEditingController titleCtl = TextEditingController();
              titleCtl.text = taskModel.title;
              timeCtl.text = taskModel.time;

              bottomSheet(
                context,
                formKey: editKey,
                titleCtl: titleCtl,
                timeCtl: timeCtl,
                textButton: "Save",
                onPressed: () {
                  if (editKey.currentState!.validate()) {
                    TasksCubit.get(context).updateTasks(
                      [
                        'title',
                        'time',
                      ],
                      [
                        titleCtl.text,
                        timeCtl.text,
                      ],
                      where: 'id = ?',
                      whereArgs: [taskModel.id],
                    );
                    Navigator.pop(context);
                  }
                },
              );
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.grey,
            ),
          ),
          fallback: null,
        ),
        ConditionalBuilder(
          condition: isDone,
          builder: (context) => IconButton(
            onPressed: () {
              TasksCubit.get(context).updateTasks(
                ['state'],
                ['done'],
                where: 'id = ?',
                whereArgs: [taskModel.id],
              );
            },
            icon: const Icon(
              Icons.check_box,
              color: Colors.green,
            ),
          ),
          fallback: null,
        ),
        ConditionalBuilder(
          condition: isDelete,
          builder: (context) => IconButton(
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text('Are you sure?'),
                  content: const Text(
                      'This action will permanently delete this task'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (result != null && result) {
                // ignore: use_build_context_synchronously
                TasksCubit.get(context).deleteTask(
                  where: 'id = ?',
                  whereArgs: [taskModel.id],
                );
              }
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
          fallback: null,
        ),
      ],
    ),
  );
}

void bottomSheet(
  context, {
  required formKey,
  required titleCtl,
  required timeCtl,
  required String textButton,
  required Function()? onPressed,
}) async {
  await showModalBottomSheet(
    backgroundColor: Colors.white,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context1) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Form(
          key: formKey,
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: titleCtl,
                  maxLength: 50,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    label: Text('title'),
                    counterText: "",
                    border: OutlineInputBorder(),
                    floatingLabelStyle: TextStyle(),
                    prefixIcon: Icon(
                      Icons.title_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value == '') {
                      return "title is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: timeCtl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Time",
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MAIN_COLOR,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.watch_later_outlined,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.delete,
                      ),
                      onPressed: () {
                        timeCtl.clear();
                      },
                    ),
                  ),
                  onTap: () async {
                    var time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: MAIN_COLOR,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                              tertiary: MAIN_COLOR,
                              onTertiary: Colors.white,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Colors.blue, // button text color
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      timeCtl.text =
                          "${time.period.index == 0 ? 0 : ""}${time.hour}:${time.minute} ${time.period.index == 0 ? "AM" : "PM"}";
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  minWidth: double.infinity,
                  textColor: Colors.white,
                  color: MAIN_COLOR,
                  onPressed: onPressed,
                  child: Text(textButton),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).whenComplete(() {});
}
