import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../layout/cubit/tasks_cubit.dart';

import '../../shared/components/componants.dart';

class Done extends StatelessWidget {
  const Done({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        return showTasks(
          context,
          isDone: false,
          isEdit: false,
          isDelete: true,
        );
      },
    );
  }
}
