import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:crypto/crypto.dart';

void main() async {
  // https://github.com/flutter/flutter/pull/38464
  // Changes in Flutter v1.9.4 require you to call WidgetsFlutterBinding.ensureInitialized()
  // before using any plugins if the code is executed before runApp.
  // As a result, you will need the following line if you're using Flutter >=1.9.4.
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _cubits(
      child: BlocBuilder<BrightnessCubit, Brightness>(
        builder: (context, brightness) {
          return MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: BlocBuilder<StorageCubit, Storage>(
              builder: (context, storage) {
                if (storage == Storage.secure) {
                  return _pageSecureStorage();
                }
                return _pagePlainStorage();
              },
            ),
          );
        },
      ),
    );
  }

  HydratedScope _pageSecureStorage() {
    return HydratedScope(
      token: 'secure_scope',
      child: FutureBuilder(
        future: _openSecureStorage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return BlocProvider<CounterBloc>(
              create: (_) => CounterBloc(),
              child: CounterPage(storage: 'Secure storage'),
            );
          }
          return Container();
        },
      ),
    );
  }

  BlocProvider<CounterBloc> _pagePlainStorage() {
    return BlocProvider<CounterBloc>(
      create: (_) => CounterBloc(),
      child: CounterPage(),
    );
  }

  Future<void> _openSecureStorage() async {
    print('opening secure storage');
    const password = 'hydration';
    final byteskey = sha256.convert(utf8.encode(password)).bytes;
    final cipher = HydratedAesCipher(byteskey);
    HydratedScope.config({
      'secure_scope': await HydratedStorage.build(
        scope: 'secure',
        encryptionCipher: cipher,
      )
    });
  }

  Widget _cubits({@required Widget child}) {
    return MultiBlocProvider(child: child, providers: [
      BlocProvider(create: (_) => BrightnessCubit()),
      BlocProvider(create: (_) => StorageCubit()),
    ]);
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key key, this.storage}) : super(key: key);

  final String storage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (BuildContext context, int state) {
          return Stack(children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(storage ?? '', style: textTheme.headline2),
            ),
            Center(child: Text('$state', style: textTheme.headline2))
          ]);
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.brightness_6),
              onPressed: () {
                context.bloc<BrightnessCubit>().toggleBrightness();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: BlocBuilder<StorageCubit, Storage>(
              builder: (context, storage) {
                return FloatingActionButton(
                  child: Icon(const {
                    Storage.plain: Icons.security,
                    Storage.secure: Icons.supervised_user_circle,
                  }[storage]),
                  onPressed: () {
                    context.bloc<StorageCubit>().toggleStorage();
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                context.bloc<CounterBloc>().add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () {
                context.bloc<CounterBloc>().add(CounterEvent.decrement);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.delete_forever),
              onPressed: () async {
                final counterBloc = context.bloc<CounterBloc>();
                await counterBloc.clear();
                counterBloc.add(CounterEvent.reset);
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum CounterEvent { increment, decrement, reset }

class CounterBloc extends Bloc<CounterEvent, int> with HydratedMixin {
  CounterBloc() : super(0) {
    hydrate();
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.reset:
        yield 0;
        break;
    }
  }

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, int> toJson(int state) => {'value': state};
}

class BrightnessCubit extends HydratedCubit<Brightness> {
  BrightnessCubit() : super(Brightness.light);

  void toggleBrightness() {
    emit(state == Brightness.light ? Brightness.dark : Brightness.light);
  }

  @override
  Brightness fromJson(Map<String, dynamic> json) {
    return Brightness.values[json['brightness'] as int];
  }

  @override
  Map<String, dynamic> toJson(Brightness state) {
    return <String, int>{'brightness': state.index};
  }
}

enum Storage { plain, secure }

extension StorageExtension on Storage {
  Storage operator ~() => const {
        Storage.plain: Storage.secure,
        Storage.secure: Storage.plain,
      }[this];
}

class StorageCubit extends HydratedCubit<Storage> {
  StorageCubit() : super(Storage.plain);

  void toggleStorage() => emit(~state);

  @override
  Storage fromJson(Map<String, dynamic> json) {
    return Storage.values[json['storage'] as int];
  }

  @override
  Map<String, dynamic> toJson(Storage state) {
    return <String, int>{'storage': state.index};
  }
}
