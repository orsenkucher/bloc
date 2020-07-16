import 'package:hydrated_bloc/hydrated_bloc.dart';

class ListCubit<T> extends HydratedCubit<List<T>> {
  ListCubit() : super(<T>[]);

  void addItem(T item) => emit(List.from(state)..add(item));

  @override
  Map<String, dynamic> toJson(List<T> state) {
    return <String, dynamic>{'state': state};
  }

  @override
  List<T> fromJson(Map<String, dynamic> json) {
    return json['state'] as List<T>;
  }
}

class ToMapObject {
  const ToMapObject(this.value);
  final int value;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'value': value};
  }

  ToMapObject fromJson(Map<String, dynamic> map) {
    return ToMapObject(map['value'] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ToMapObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ToListObject {
  const ToListObject(this.value);
  final int value;

  List<dynamic> toJson() {
    return <int>[value];
  }

  ToListObject fromJson(List<dynamic> list) {
    return ToListObject(list[0] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ToListObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
