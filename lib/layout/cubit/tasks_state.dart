part of 'tasks_cubit.dart';

@immutable
sealed class TasksState {}

final class TasksInitial extends TasksState {}

final class DateChange extends TasksState {}

final class ScreenChange extends TasksState {}

final class TasksChange extends TasksState{}

final class AppCreateDataBase extends TasksState{}

final class GetDatabase extends TasksState{}

final class GetLateDatabase extends TasksState{}

final class AddNewTask extends TasksState{}

final class UpdateTask extends TasksState{}

final class DeleteTask extends TasksState{}


