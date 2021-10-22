// This file is part of fluxer.
//
// (c) Irwin Lourtet <dev@ilourt.com>
//
// For the full copyright and license information, please view the LICENSE file
// distributed with this source code
// or visit https://github.com/ilourt/fluxer

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer/fluxer.dart';

class MockStore extends Store<String> {
  MockStore(String state) : super(state);
}

void main() {
  var myRef = "myRef";

  setUp(() => initFluxer());

  group('Provider', () {
    testWidgets('should manage ref/store with fluxer',
        (WidgetTester tester) async {
      // Create the widget by telling the tester to build it.
      await tester.pumpWidget(Provider(
        child: Container(),
        create: () => MockStore("initial state"),
        ref: myRef,
      ));

      expect(fluxer.of(myRef).runtimeType, MockStore);

      var updatedRef = "updatedRef";
      await tester.pumpWidget(Provider(
        child: Container(),
        create: () => MockStore("second store"),
        ref: updatedRef,
      ));

      expect(() => fluxer.of(myRef), throwsException);
      expect(fluxer.of(updatedRef).runtimeType, MockStore);
    });
  });

  testWidgets('Consumer should rebuild on store update',
      (WidgetTester tester) async {
    var store = MockStore("initial state");
    fluxer.addRef(myRef, store);

    await tester.pumpWidget(Consumer<MockStore, String>(
      ref: myRef,
      build: (BuildContext context, state) => Text(
        state,
        textDirection: TextDirection.ltr,
      ),
    ));

    var textFind = find.text(store.state);
    expect(textFind, findsOneWidget);

    var updatedState = "updated state";
    await store.addAction((emit) {
      emit(state: updatedState, dispatch: true);
    });

    await tester.pump();
    var updatedTextFind = find.text(updatedState);
    expect(updatedTextFind, findsOneWidget);
  });

  testWidgets('Consumer should rebuild using `buildWhen`',
      (WidgetTester tester) async {
    var store = MockStore("initial state");
    var stateForRebuild = "state for rebuild";
    fluxer.addRef(myRef, store);

    await tester.pumpWidget(Consumer<MockStore, String>(
      ref: myRef,
      buildWhen: (prevState, state) => state == stateForRebuild,
      build: (BuildContext context, state) => Text(
        state,
        textDirection: TextDirection.ltr,
      ),
    ));

    var textFind = find.text(store.state);
    expect(textFind, findsOneWidget);

    var updatedState = "updated state";
    await store.addAction((emit) {
      emit(state: updatedState, dispatch: true);
    });

    await tester.pump();
    textFind = find.text(updatedState);
    expect(textFind, findsNothing);

    await store.addAction((emit) {
      emit(state: stateForRebuild, dispatch: true);
    });

    await tester.pump();
    textFind = find.text(stateForRebuild);
    expect(textFind, findsOneWidget);
  });

  testWidgets('MultiConsumer should listen several store',
      (WidgetTester tester) async {
    var ref1 = "ref1";
    var ref2 = "ref2";
    var store1 = MockStore("initial state1");
    var store2 = MockStore("initial state2");
    var stateForRebuild = "state for rebuild";
    fluxer.addRef(ref1, store1);
    fluxer.addRef(ref2, store2);

    await tester.pumpWidget(MultiConsumer(
      storeConsumers: [
        StoreConsumer<MockStore, String>(ref: ref1),
        StoreConsumer<MockStore, String>(
            ref: ref2,
            buildWhen: (prevState, state) => state == stateForRebuild),
      ],
      build: (context) {
        var state1 = fluxer.stateOf(ref1);
        var state2 = fluxer.stateOf(ref2);

        return Row(textDirection: TextDirection.ltr, children: [
          Text(
            "store1: $state1",
            textDirection: TextDirection.ltr,
          ),
          Text(
            "store2: $state2",
            textDirection: TextDirection.ltr,
          ),
        ]);
      },
    ));

    var text1Find = find.text("store1: ${store1.state}");
    var text2Find = find.text("store2: ${store2.state}");
    expect(text1Find, findsOneWidget);
    expect(text2Find, findsOneWidget);

    var store1NewState = "new state";
    await store1.addAction((emit) {
      emit(state: store1NewState, dispatch: true);
    });

    await tester.pump();
    text1Find = find.text("store1: ${store1.state}");
    text2Find = find.text("store2: ${store2.state}");
    expect(text1Find, findsOneWidget);
    expect(text2Find, findsOneWidget);

    await store2.addAction((emit) {
      emit(state: "state do not provoke a rebuild", dispatch: true);
    });

    await tester.pump();
    text1Find = find.text("store1: ${store1.state}");
    text2Find = find.text("store2: ${store2.state}");
    expect(text1Find, findsOneWidget);
    expect(text2Find, findsNothing);

    await store2.addAction((emit) {
      emit(state: stateForRebuild, dispatch: true);
    });

    await tester.pump();
    text1Find = find.text("store1: ${store1.state}");
    text2Find = find.text("store2: ${store2.state}");
    expect(text1Find, findsOneWidget);
    expect(text2Find, findsOneWidget);
  });
}
