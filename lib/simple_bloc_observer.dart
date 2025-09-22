import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    developer.log('$event', name: bloc.runtimeType.toString());
    super.onEvent(bloc, event);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    developer.log('$error',
        name: bloc.runtimeType.toString(), error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    developer.log('$change', name: bloc.runtimeType.toString());
    super.onChange(bloc, change);
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    developer.log('$transition', name: bloc.runtimeType.toString());
    super.onTransition(bloc, transition);
  }
}
