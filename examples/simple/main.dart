import 'package:flutter/material.dart';
import 'package:fluxer/fluxer.dart';
import './counter_store.dart';
import './auth_store.dart';

void main() {
  // Initialize fluxer
  initFluxer();

  // Create an instance of AuthStore globally accessible using the ref (which is
  // of type dynamic so it can be whatever you want)
  fluxer.addRef(authRef, AuthStore());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Fluxer demo'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // listen to change to the store and call the specified callback
    fluxer.of<AuthStore>(authRef).listen(onAuthStateUpdate);
    super.initState();
  }

  @override
  void dispose() {
    // unlisten the store when the widget is disposed to avoid memory leak
    fluxer.of<AuthStore>(authRef).unlisten(onAuthStateUpdate);
    super.dispose();
  }

  /// Callback called when AuthStore change.
  /// It receives the previous state and the current state
  void onAuthStateUpdate(AuthState? prevState, AuthState state) {
    if (prevState == null) return;

    if (prevState.isLogged != state.isLogged) {
      print("User login status has changed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Consumer<AuthStore, AuthState>(
        ref: authRef,
        build: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: Text("Loading"),
            );
          }

          if (state.isLogged == false) {
            return Center(
              child: ElevatedButton(
                child: const Text("Log in"),
                onPressed: () {
                  // Get the global instance of auth store using its ref
                  var authStore = fluxer.of<AuthStore>(authRef);

                  // Call action of the auth store.
                  authStore.login("email", "password");
                },
              ),
            );
          }

          return const Counter();
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider allow yo create a store locally and to make it available to its
    // child tree. The create store is automatically remove when the provider is
    // disposed.
    return Provider(
      create: () => CounterStore(),
      ref: "counterRef",
      child: Consumer<CounterStore, CounterState>(
        ref: "counterRef",
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
  }
}
