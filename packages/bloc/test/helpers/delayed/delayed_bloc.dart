import 'dart:async';

import 'package:bloc/bloc.dart';

class DelayedBloc extends Bloc<int, int> {
  @override
  int get initialState => 1;

  @override
  Stream<int> mapEventToState(int event) async* {
    yield await Future.delayed(Duration(milliseconds: 100), () => event);
  }
}
