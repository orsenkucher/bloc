import 'dart:async';

import 'package:bloc/bloc.dart';

class BlocBreakerBloc extends Bloc<Object, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(Object event) async* {
    yield 0;
    yield 1;
    yield 2;
    yield 1;
    yield 1;
  }
}
