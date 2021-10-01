// This file is part of fluxer.
//
// (c) Irwin Lourtet <dev@ilourt.com>
//
// For the full copyright and license information, please view the LICENSE file
// distributed with this source code
// or visit https://github.com/ilourt/fluxer

part of '../flutter.dart';

class MultiConsumer extends StatefulWidget {
  const MultiConsumer({
    Key? key,
    required this.storeConsumers,
    required this.build,
  }) : super(key: key);

  final Build build;
  final List<StoreConsumer> storeConsumers;

  @override
  _MultiConsumerState createState() => _MultiConsumerState();
}

class _MultiConsumerState extends State<MultiConsumer> {
  final Map<dynamic, Function> _unlistenRefs = {};

  @override
  void initState() {
    for (var storeConsumer in widget.storeConsumers) {
      _unlistenRefs[storeConsumer.ref] = storeConsumer.listenStore(this);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (var storeConsumer in widget.storeConsumers) {
      _unlistenRefs[storeConsumer.ref]!();
    }
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context);
  }
}

class StoreConsumer<T extends core.Store<U>, U> {
  StoreConsumer({required this.ref, this.buildWhen})
      : store = fluxer.of<T>(ref);

  final T store;
  final dynamic ref;
  final BuildWhen<U>? buildWhen;

  Function listenStore(_MultiConsumerState mcs) {
    return store.listen((prevState, state) {
      if (!mcs.mounted ||
          prevState == null ||
          (buildWhen != null && buildWhen!(prevState, state) == false)) return;
      mcs.refresh();
    });
  }
}
