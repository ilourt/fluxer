// This file is part of fluxer.
//
// (c) Irwin Lourtet <dev@ilourt.com>
//
// For the full copyright and license information, please view the LICENSE file
// distributed with this source code
// or visit https://github.com/ilourt/fluxer

part of '../flutter.dart';

class Consumer<T extends core.Store<U>, U> extends StatefulWidget {
  const Consumer({
    Key? key,
    required this.ref,
    required this.build,
    this.buildWhen,
  }) : super(key: key);

  final dynamic ref;
  final BuildWhen<U>? buildWhen;
  final BuildWithState<U> build;

  @override
  _ConsumerState<T, U> createState() => _ConsumerState<T, U>();
}

class _ConsumerState<T extends core.Store<U>, U> extends State<Consumer<T, U>> {
  late final T _store;

  @override
  void initState() {
    _store = fluxer.of<T>(widget.ref);
    _store.listen(update);
    super.initState();
  }

  void update(U? prevState, U state) {
    if (!mounted ||
        prevState == null ||
        (widget.buildWhen != null &&
            widget.buildWhen!(prevState, state) == false)) return;
    setState(() {});
  }

  @override
  void dispose() {
    _store.unlisten(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, _store.state);
  }
}
