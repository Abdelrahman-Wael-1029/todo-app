class TaskModel {
  final int _id;
  final String _title;
  final String _time;
  final String _date;
  final String _state;

  TaskModel({
    required int id,
    required String title,
    required String time,
    required String date,
    required String state,
  })  : _id = id,
        _title = title,
        _time = time,
        _date = date,
        _state = state;

  int get id => _id;
  String get title => _title;
  String get time => _time;
  String get date => _date;
  String get state => _state;

  TaskModel.fromJson(Map<String, dynamic> json)
      : _id = json['id'],
        _title = json['title'],
        _time = json['time'],
        _date = json['date'],
        _state = json['state'];

  Map<String, dynamic> toJson() => {
        'title': _title,
        'time': _time,
        'date': _date,
        'state': _state,
      };

  @override
  String toString() {
    return '{title: $_title, time: $_time, date: $_date, state: $_state}';
  }
}
