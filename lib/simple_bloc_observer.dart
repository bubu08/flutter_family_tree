import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    print(change);
    super.onChange(bloc, change);
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }
}
