import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../layout/cubit/tasks_cubit.dart';

import '../../shared/components/componants.dart';

class Tasks extends StatelessWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        return showTasks(
          context,
          isDone: true,
          isEdit: true,
          isDelete: true,
        );
      },
    );
  }
}
