// This file is part of fluxer.
//
// (c) Irwin Lourtet <dev@ilourt.com>
//
// For the full copyright and license information, please view the LICENSE file
// distributed with this source code
// or visit https://github.com/ilourt/fluxer

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer/fluxer.dart';
import 'package:fluxer/src/core.dart';

class MockStore extends Store<String> {
  MockStore(String state) : super(state);

  Future<String> updateString(String newState) {
    return addAction((dispatch, notify) {
      notify(newState);
      dispatch();
      return newState;
    });
  }

  Future<String> updateStringDelayed(String newState, Duration d) {
    return addAction((dispatch, notify) async {
      await Future.delayed(d);
      notify(newState);
      dispatch();
      return newState;
    });
  }

  notifyAfterDispatch() {
    return addAction((dispatch, notify) {
      dispatch();
      notify("new state");
    });
  }

  dispatchTwice() {
    return addAction((dispatch, notify) {
      dispatch();
      dispatch();
    });
  }
}

void main() {
  group('Store', () {
    late MockStore store;
    setUpAll(() => initFluxer());
    setUp(() {
      store = MockStore("initial state");
    });

    tearDown(() {
      store.dispose();
    });

    test('should notify listener on state update', () {
      var completer = Completer();
      store.listen((prevState, state) {
        completer.complete(state);
      });

      store.updateString("update");

      expect(completer.future, completion(equals("update")));
    });

    test('should remove listener by calling unlisten', () {
      var completer = Completer();

      // Define listener
      listener(prevState, state) {
        completer.complete(state);
      }

      store.listen(listener);
      store.unlisten(listener);
      store.updateString("update");

      expect(completer.isCompleted, false);
    });

    test('should remove listener by calling callback return by `listen`', () {
      var completer = Completer();

      // Define listener
      listener(prevState, state) {
        completer.complete(state);
      }

      Function unlisten = store.listen(listener);
      unlisten();
      store.updateString("update");

      expect(completer.isCompleted, false);
    });

    test('should execute actions in flux', () {
      String expected = "1";
      store.listen((prevState, state) {
        if (prevState == "initial state") {
          expect(state, expected);
          expected = "2";
          return;
        }
        if (prevState == "1") {
          expect(state, expected);
          expected = "3";
          return;
        }

        if (prevState == "2") {
          expect(state, expected);
          return;
        }
      });
      Future action1 = store.updateString("1");
      Future action2 =
          store.updateStringDelayed("2", const Duration(milliseconds: 50));
      Future action3 = store.updateString("3");

      expect(action1, completion(equals("1")));
      expect(action2, completion(equals("2")));
      expect(action3, completion(equals("3")));
    });

    test('should throw error when notify called after dispatch', () {
      expect(() => store.notifyAfterDispatch(), throwsException);
    });

    test('should throw error when dispatch is called several times', () {
      expect(() => store.dispatchTwice(), throwsException);
    });
  });
}
