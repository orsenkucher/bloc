import 'dart:async';

void main() {
  final ints = StreamController<int>.broadcast();
  var d = ints.stream.distinct();
  d = ints.stream;
  d.listen(print);
  d.listen(print);
  d.listen(print);
  ints.add(1);
  ints.add(1);
  ints.add(2);
  ints.add(2);
}
