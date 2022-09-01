import 'package:fluxer/fluxer.dart';

class CounterStore extends Store<CounterState> {
  CounterStore() : super(CounterState(0));

  Future<int> increment() {
    // Add the callback into the action queue. It will be executed after all
    // previous action in the queue has been executed.
    //
    // `emit` is a callback which can take 2 named arguments optional:
    // - `state` which is the new instance of the updated state
    // - `dispatch` (bool) if it is true (by default) it tell that the action is
    //    finished and the state will no more update the state. If false it
    //    will allow to emit other state in the same action and will not remove
    //    current action from the queue.
    //
    // Add the end of the action if no emit has been fired, then the action will
    // automatically be removed from the action queue.
    return addAction((emit) {
      emit(state: CounterState(state.counter + 1));

      // The state is now the new state updated during the call to emit
      return state.counter;
    });
  }
}

class CounterState {
  CounterState(this.counter);

  final int counter;
}
