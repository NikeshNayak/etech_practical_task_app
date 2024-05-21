import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate : ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange : ${bloc.runtimeType}, change: $change');
    print("Current State: ${change.currentState}");
    print("Next State: ${change.nextState}");
    print(change.runtimeType);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- view_model: ${bloc.runtimeType}, transition: $transition');
    print("Event: ${transition.event}");
    print("Current State: ${transition.currentState}");
    print("Next State: ${transition.nextState}");
    print(transition.runtimeType);
    print('onTransition ${transition.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError : ${bloc.runtimeType}, error: $error');
    print("Error: ${error.runtimeType}");
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose ${bloc.runtimeType}');
  }
}
