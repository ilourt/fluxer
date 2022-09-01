A store inpired by the flux pattern. Its aim is to be easy to use.
## Features

It can be used as a singleton globally available or scoped to a branch of widgets.


## Getting started

Add fluxer to `pubspec.yaml`

```dart
dependencies:
  # State
  fluxer:
    git:
      url: https://github.com/ilourt/fluxer
      ref: 0.4.0
```

## Usage

For more detailled example check in the `examples` folder.

### Initialize fluxer

```dart
import 'package:fluxer/fluxer.dart';

void main() async {
  // Init fluxer
  initFluxer();

  // add a globally accessible store
  fluxer.addRef(authRef, AuthStore());
}
```

### Create a store

``` dart
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
```

### Consume a store inside a widget

```dart

Consumer<MyStore, MyState>(
  ref: "myStoreRef",
  build: (context, state) {
    // In state you have access to the state of the store
    // If in the state you have a string property myText you can:
    return Text(state.myText);
  }
)

```

### Provide a store locally

You can create a store only accessible in a specified widget tree. This store
will be destroyed when the `Provider` is no more in the tree.

```dart
Provider(
  create: () => CounterStore(),
  ref: "counterRefLocal",
  child: Consumer<CounterStore, CounterState>(
    ref: "counterRefLocal",
    build: (context, state) => Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(state.counter.toString()),
            ElevatedButton(
              onPressed: () {
                fluxer.of<CounterStore>("counterRef").increment();
              },
              child: const Text("increment"),
            )
          ]),
    ),
  ),
);
```
