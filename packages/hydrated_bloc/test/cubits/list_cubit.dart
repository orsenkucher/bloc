import 'package:hydrated_bloc/hydrated_bloc.dart';

class ListCubit extends HydratedCubit<List<String>> {
  ListCubit() : super(const <String>[]);

  void addItem(String item) => emit(List.from(state)..add(item));

  @override
  Map<String, dynamic> toJson(List<String> state) {
    return <String, dynamic>{'state': state};
  }

  @override
  List<String> fromJson(Map<String, dynamic> json) {
    return json['state'] as List<String>;
  }
}

class ListCubitMap extends HydratedCubit<List<MapObject>> {
  ListCubitMap() : super(<MapObject>[]);

  void addItem(MapObject item) => emit(List.from(state)..add(item));

  @override
  Map<String, dynamic> toJson(List<MapObject> state) {
    return <String, dynamic>{'state': state};
  }

  @override
  List<MapObject> fromJson(Map<String, dynamic> json) {
    return (json['state'] as List)
        .map((dynamic x) => x as Map<String, dynamic>)
        .map(MapObject.fromJson)
        .toList();
  }
}

class ListCubitList<T> extends HydratedCubit<List<T>> {
  ListCubitList(this._fromJson) : super(<T>[]);
  final T Function(List<dynamic> json) _fromJson;

  void addItem(T item) => emit(List.from(state)..add(item));

  @override
  Map<String, dynamic> toJson(List<T> state) {
    return <String, dynamic>{'state': state};
  }

  @override
  List<T> fromJson(Map<String, dynamic> json) {
    return (json['state'] as List)
        .map((dynamic x) => x as List<dynamic>)
        .map(_fromJson)
        .toList();
  }
}

class MapObject {
  const MapObject(this.value);
  final int value;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'value': value};
  }

  static MapObject fromJson(Map<String, dynamic> map) {
    return MapObject(map['value'] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is MapObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ListObject {
  const ListObject(this.value);
  final int value;

  List<dynamic> toJson() {
    return <int>[value];
  }

  static ListObject fromJson(List<dynamic> list) {
    return ListObject(list[0] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ListObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ListMapObject {
  ListMapObject(int value) : value = MapObject(value);
  final MapObject value;

  List<dynamic> toJson() {
    return <MapObject>[value];
  }

  static ListMapObject fromJson(List<dynamic> list) {
    return ListMapObject(
      MapObject.fromJson(list[0] as Map<String, dynamic>).value,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ListMapObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ListListObject {
  ListListObject(int value) : value = ListObject(value);
  final ListObject value;

  List<dynamic> toJson() {
    return <ListObject>[value];
  }

  static ListListObject fromJson(List<dynamic> list) {
    return ListListObject(
      ListObject.fromJson(list[0] as List<dynamic>).value,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ListListObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
